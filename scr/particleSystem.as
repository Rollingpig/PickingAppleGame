package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.errors.IOError;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import particleData;
	import flash.events.TouchEvent;

	/**
	 * "particleSystem"用于显示元件运动
	 * 每当进入帧的时候，程序根据一个运动序列的信息
	 * 重新安排元件的位置，并判断是否触发某些事件
	 * "particleSystem" displays objects 
	 * by reading a sequence which is loaded or 
	 * generated when enter frames.
	 *
	 * 在本程序中用于显示游戏界面中的下落物体
	 * Used to display the falling items in the game
	*/
	public class particleSystem extends Sprite
	{
		/**
		 * "motion"用于存储下落物体的位置、速度、
		 * 类型等信息，详见"particleData"类
		 * "motion" is used to save the
		 * motion data of the objects
		*/
		private var motion:Array = new Array;
		/**
		 * "particleLib" 是苹果元件的库
		 * 通过这个库，元件可以循环使用
		 * "particleLib" is a library of 
		 * the objects, these objects will be reused.
		 * 
		 * libAmount指particleLib的元件总数
		*/
		private var particleLib:Vector.<MovieClip> = new Vector.<MovieClip>  ;
		private const libAmount:int = 30;
		private var rear:int = 0;
		private var head:int = 0;
		private var libStack:Vector.<int> = new Vector.<int>;
		private var stackPoint:int = -1;
		
		//记录运动序列已经进行到第几帧
		private var runFrame:int = 0;

		//the size of displaying area
		private const layerWidth:int = 480 - 40;
		private const layerHeight:int = 700;
		private const chickHeight:int = 488+75;

		public var hitZone:MovieClip;
		//物品元件的基本下落速度
		//the basic speed of the falling object.
		public var basicSpeed:int = 7;
		
		private var file:File = File.documentsDirectory;
		private var fileStream:FileStream = new FileStream();
		
		private var endFrame:int = 0;
		private var frameSpan:int = 2 * 24;
		private var viewhead:int = 0;
		private var viewrear:int = 0;
		private var background:Sprite = new Sprite();
		public var editType:String = "n";
		public var lock:Boolean = true;
		private var forbid:Boolean = false;
		private const delY:int = 80;
		private const maskHeight:int = 540;
		private var main:MovieClip;
		
		public function particleSystem(mainscr:MovieClip):void
		{
			this.mouseEnabled = false;
			background.graphics.beginFill(0x336699,0);
			background.graphics.drawRect(0,delY,480,maskHeight + 40);
			background.graphics.endFill();
			background.visible = false;
			this.addChild(background);
			main = mainscr;
		}
		/**
		 * "initParticle" 初始化函数
		 * 将实例化的元件加入particleLib
		*/
		public function initParticle(apple:Object,special:Object = null):void
		{
			particleLib.length = 0;
			libStack.length = 0;
			if (special !== null)
			{
				special = new special.constructor;
			}			
			for (var i = 0; i < libAmount; i++)
			{
				var particle:MovieClip = new apple.constructor();
				particleLib.push(particle);
				particle.visible = false;
				this.addChild(particle);
				libStack.push(i);
			}
		}
		private function resetLib():void
		{
			stackPoint = libAmount-1;
			for (var i:int = 0; i < libAmount; i++)
			{
				particleLib[i].visible = false;
				particleLib[i].gotoAndStop(1);
				libStack[i] = i;
			}
		}
		/**
		 * "loadLocal"函数将读取物品元件下落的序列"motion"。
		*/
		public function loadLocal(lev:Object):void
		{
			motion = lev.sequence;
		}
		/**
		 * "saveLevel"函数将返回
		 * 存储物品元件下落的序列"motion"
		*/
		public function saveLevel(time:int = 10000):Array
		{
			motion.sortOn("dropFrame",Array.NUMERIC);
			var endFrame:int = time * 24;
			var i:int = 0;
			while((i+1) <= motion.length && motion[i].reachFrame < endFrame) i++;
			//trace(endFrame,i,motion.length);
			if((i+1) < motion.length) motion.splice(i);
			//trace(motion.length);
			return motion;
		}
		private function popStack():MovieClip
		{
			var p:MovieClip;
			if(stackPoint >= 0)
			{
				p = particleLib[libStack[stackPoint]];
				stackPoint--;
			}
			else
			{
				p = null;
			}
			return p;
		}
		private function pushStack(p:MovieClip):void
		{
			stackPoint++;
			libStack[stackPoint] = particleLib.indexOf(p);
		}
		//"addParticle"函数将一个新的元件加入到motion数组中
		public function addParticle(type:String,x,dropFrame,reachFrame:int,vy:int):int
		{
			var i:int = 0;
			var p:particleData = new particleData();
			p.dropFrame = dropFrame;
			p.reachFrame = reachFrame;
			p.type = type;
			p.targetX = x;
			p.vy = vy;
			viewrear++;
			for(i = 0;i < motion.length;i++)
			{
				if(motion[i].reachFrame > reachFrame)
				{
					motion.splice(i,0,p);
					break;
				}
			}
			if (i == motion.length) motion.push(p);
			return i;
		}
		//"deleteParticle"函数将一个元件从motion数组中删除
		public function deleteParticle(index:int):void
		{
			motion.splice(index,1);
			viewrear--;
		}
		public function showParticle(index:int):void
		{
			motion[index].p = popStack();
			switch (motion[index].type)
			{
				case "bomb" :
					motion[index].p.gotoAndStop(3);
					break;
				case "gold":
					motion[index].p.gotoAndStop(2);
					break;
			}
			motion[index].p.visible = true;
			motion[index].p.x = motion[index].targetX;
			motion[index].p.y = (endFrame - motion[index].reachFrame)/frameSpan * maskHeight + delY;
			motion[index].p.addEventListener(TouchEvent.TOUCH_TAP,touchDel);
			//trace("show: index",index," p",motion[index].p," lib_index",i," reachFrame",motion[index].reachFrame," y",motion[index].p.y);
			forbid = viewrear - viewhead + 1 >= (libAmount - 10);
			//trace(forbid);
		}
		public function hideParticle(index:int):void
		{
			pushStack(motion[index].p);
			motion[index].p.visible = false;
			motion[index].p.gotoAndStop(1);
			motion[index].p = null;
			forbid = false;
		}
		public function touchAdd(event:TouchEvent):void
		{
			if (! forbid)
			{
				var touchX:int = event.localX - 25;
				var touchY:int = event.localY - 25;
				var vy:int = basicSpeed;
				vy = lock ? vy + 6 : vy + Math.random() * 12;
				var reachFrame:int = endFrame - (touchY -delY) / maskHeight * frameSpan;
				//trace(editType," x",touchX," reachFrame",reachFrame);
				showParticle(addParticle(editType,touchX,reachFrame - int(chickHeight/vy),reachFrame,vy));
			}
		}
		public function touchDel(event:TouchEvent):void
		{
			for(var i:int = viewhead;i <= viewrear;i++)
			{
				if(event.target == motion[i].p) break;
			}
			hideParticle(i);
			deleteParticle(i);
		}
		public function enterEdit():void
		{
			motion.sortOn("reachFrame",Array.NUMERIC);
			resetLib();
			endFrame = frameSpan;
			viewhead = 0;
			viewrear = -1;
			for(var i:int = viewhead;i < motion.length && motion[i].reachFrame <= endFrame;i++)
			{
				viewrear ++;
				showParticle(i);
			}
			background.visible = true;
			background.addEventListener(TouchEvent.TOUCH_TAP,touchAdd);
			//trace(viewrear,endFrame);
		}
		public function exitEdit():void
		{
			resetLib();
			background.visible = false;
			background.removeEventListener(TouchEvent.TOUCH_TAP,touchAdd);
		}
		public function switchPage(dir:int):void
		{
			var i:int = 0;
			if(dir>0)
			{
				//trace(endFrame,endFrame-frameSpan);
				endFrame += frameSpan;
				for(i = viewhead;i <= viewrear;i++)
				{
					hideParticle(i);
				}
				viewhead = viewrear >= 0 ? viewrear + 1:0;
				for(i = viewhead;i < motion.length && motion[i].reachFrame < endFrame;i++)
				{
					viewrear ++;
					showParticle(i);
				}
			}
			else
			{
				endFrame -= frameSpan;
				for(i = viewhead;i <= viewrear;i++)
				{
					hideParticle(i);
				}
				viewrear = viewhead - 1;
				for(i = viewrear;i >= 0 && motion[i].reachFrame > endFrame-frameSpan;i--)
				{
					viewhead --;
					showParticle(i);
				}
			}
		}
		/**
		 * "particle_motion"在进入帧时被触发，
		 * 根据物品元件下落的序列"motion"重新安排
		 * 物品元件的位置。
		*/
		private function particle_motion(event:Event):void
		{
			runFrame++;
			/**
			 * 每走过24帧，调用主程序的
			 * "gameTimer"函数一次
			*/
			if (runFrame % 24 == 0)
			{
				main.game.gameTimer();
				//trace(rear-head,stackPoint);
			}
			/*
			 * 如果运行帧数大于等于元件的出发帧数
			 * 则从particleLib中
			 * 分配一个实例给motion[rear].p
			 * 并把尾指针rear加1
			*/
			while (rear < motion.length && runFrame >= motion[rear].dropFrame)
			{
				motion[rear].p = popStack();
				if(motion[rear].p !== null)
				{
					motion[rear].p.x = motion[rear].targetX;
					motion[rear].p.y = -30;
					motion[rear].p.visible = true;
					switch (motion[rear].type)
					{
						case "bomb" :
							motion[rear].p.gotoAndStop(3);
							break;
						case "gold":
							motion[rear].p.gotoAndStop(2);
							break;
					}
				}
				rear++;
			}
			while (head < rear && motion[head].p == null)
			{
				head++;
			}
			//遍历motion数组显示队列的每一个元素
			for (var i:int = head; i < rear; i++)
			{
				/*
				 * 如果motion的p非空
				 *
				 * motion[i]的p用于引用particleLib
				 * 中的元件实例，当motion[i]不用的时候
				 * motion[i].p为null
				*/
				if (motion[i].p !== null)
				{
					/**
					 * 如果元件与hitZone碰撞，则
					 * 加减相应分数与游戏数据，
					 * 并隐藏元件，把motion中的p置null
					 * 以此取消对元件的引用
					*/
					if (motion[i].p.hitTestObject(hitZone))
					{
						switch (motion[i].type)
						{
							case "gold" :
								motion[i].p.gotoAndStop(1);
								break;
							case "bomb" :
								motion[i].p.gotoAndStop(1);
								break;
						}
						main.game.gameEvent(motion[i].type,motion[i].targetX);
						motion[i].p.visible = false;
						pushStack(motion[i].p);
						motion[i].p = null;
					}
					/*
					 * 如果元件掉出屏幕，则
					 * 隐藏元件，把motion中的p置null
					 * 以此取消对元件的引用
					*/
					else if (motion[i].p.y > layerHeight)
					{
						switch (motion[i].type)
						{
							case "n" :
								main.game.gameEvent("miss");
								break;
							case "gold" :
							case "bomb" :
								motion[i].p.gotoAndStop(1);
								break;
						}
						motion[i].p.visible = false;
						pushStack(motion[i].p);
						motion[i].p = null;
					}
					/*
					 * 如果都不是，则元件下移vy个单位
					*/
					else
					{
						motion[i].p.y +=  motion[i].vy;
					}
				}
			}
		}
		//清空游戏数据
		public function resetStats():void
		{
			runFrame = 0;
			rear = 0;
			head = 0;
			resetLib();
		}
		//清空motion数据
		public function clearMotion():void
		{
			motion.length = 0;
		}
		//开始动画
		public function addMotion():void
		{
			this.addEventListener(Event.ENTER_FRAME,particle_motion);
		}
		//停止动画
		public function stopMotion():void
		{
			this.removeEventListener(Event.ENTER_FRAME,particle_motion);
		}
	}

}