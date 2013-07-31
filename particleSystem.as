package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.errors.IOError;
	import flash.filesystem.*;
	import particleData;

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
		private var motion:Vector.<Object >  = new Vector.<Object >   ;
		/**
		 * "particleLib" 是元件的库
		 * 通过这个库，元件可以循环使用
		 * "particleLib" is a library of 
		 * the objects, these objects will be reused.
		 * 
		 * libAmount指particleLib的元件总数
		*/
		private var particleLib:Array = new Array  ;
		private const libAmount:int = 20;
		private var particlePoint:int = 0;
		
		//记录运动序列已经进行到第几帧
		private var runFrame:int = 0;

		//the size of displaying area
		private const layerWidth:int = 480 - 40;
		private const layerHeight:int = 700;
		private const chickHeight:int = 570;

		public var hitZone:MovieClip;
		//物品元件的基本下落速度
		//the basic speed of the falling object.
		public var basicSpeed:int = 7;

		//游戏数据 Stats of the game
		public var caught:int = 0;
		public var bomb:int = 0;
		public var miss:int = 0;
		public var combo:int = 0;
		public var maxcombo:int = 0;

		private var file:File = File.documentsDirectory;
		private var fileStream:FileStream = new FileStream();

		public function particleSystem()
		{
			this.mouseEnabled = false;
		}
		/**
		 * "initParticle" 初始化函数
		 * 将实例化的元件加入particleLib
		*/
		public function initParticle(target:Object):void
		{
			particleLib.length = 0;
			for (var i = 0; i < libAmount; i++)
			{
				var particle:MovieClip = new target.constructor();
				particleLib.push(particle);
				particle.visible = false;
				this.addChild(particle);
			}
		}
		/**
		 * "generate"函数根据以下参数，生成物品元件下落的序列"motion"
		 * 在游戏进行中，会读取这一序列，显示元件下落的动画
		 * 
		 * normal 普通元件（苹果）的数量
		 * totalTime 下落过程的总时间
		 * bombs 炸弹的数量
		 * golden 金色星星的数量
		 * threshold 每个苹果之间的距离与小鸡能达到的最大距离之比
		 * imaSpeed 小鸡的速度
		*/
		public function generate(normal:int,totalTime:int,bombs:int,golden:int,threshold:Number,imaSpeed:int)
		{
			var totalFrame:int = totalTime * 24;
			var deltaFrame:Number = 0;
			var beginFrame:int = int(chickHeight / basicSpeed);
			var deltaX:int = 0;
			var ut:Number = (totalFrame - beginFrame) / normal;
			deltaFrame = beginFrame;
			//使苹果随时间均匀分布
			for (var i:int = 0; i < normal; i++)
			{
				deltaFrame += ut;
				motion.push(new particleData  );
				motion[i].dropFrame = int(deltaFrame);
			}
			for (i = 0; i < normal; i++)
			{
				//第一个苹果的下落位置是显示区正中间
				if (i == 0)
				{
					motion[i].targetX = int((layerWidth / 2));
				}
				else
				{
					//随机生成第i+1个苹果与第i个苹果的位置偏移量
					deltaX = Math.random() * (1 - threshold) + threshold * imaSpeed * deltaFrame;
					/** 
					 * 如果第i+1个苹果的位置超出显示区，则重新安排位置。
					 * 如果未超出，则随机确定偏移量的正负。
					*/
					if (motion[i - 1].targetX > layerWidth - 80)
					{
						motion[i].targetX = motion[i - 1].targetX - deltaX;
					}
					else if (motion[i - 1].targetX < 80)
					{
						motion[i].targetX = motion[i - 1].targetX + deltaX;
					}
					else
					{
						motion[i].targetX = motion[i - 1].targetX + deltaX * (int(Math.random() * 2) * 2 - 1);
					}
					motion[i].targetX = motion[i].targetX > layerWidth ? layerWidth:motion[i].targetX;
					motion[i].targetX = motion[i].targetX < 0 ? 0:motion[i].targetX;
				}
				//随机生成第i+1个苹果下落速度
				motion[i].vy = Math.random() * 12 + basicSpeed;
				//算出第i+1个苹果下次间隔的时长
				if (i < normal - 1)
				{
					deltaFrame = motion[i + 1].dropFrame - motion[i].dropFrame;
				}
				//由速度倒推出第i+1个苹果实际开始下落的时间
				motion[i].dropFrame -=  int(chickHeight / motion[i].vy);
			}
			var temp:particleData;
			for (i = 0; i < bombs; i++)
			{
				temp = new particleData  ;
				temp.vy = Math.random() * 12 + basicSpeed;
				temp.dropFrame = Math.random() * (totalFrame - beginFrame) + beginFrame - int(chickHeight / temp.vy);
				temp.type = "bomb";
				temp.targetX = Math.random() * layerWidth;
				motion.push(temp);
			}
			for (i = 0; i < golden; i++)
			{
				temp = new particleData  ;
				temp.vy = Math.random() * 8 + basicSpeed + 5;
				temp.dropFrame = Math.random() * (totalFrame - beginFrame) + beginFrame - int(chickHeight / temp.vy);
				temp.targetX = Math.random() * layerWidth;
				temp.type = "gold";
				motion.push(temp);
			}
		}
		/**
		 * "loadLocal"函数将从文档位置（SD卡）
		 * 读取物品元件下落的序列"motion"。
		*/
		public function loadLocal(path:String="level.dat"):void
		{
			file = File.documentsDirectory.resolvePath(path);
			//path has included "pickapple/" prefix;
			try
			{
				fileStream.open(file,FileMode.READ);
				motion = fileStream.readObject();
				fileStream.close();
			}
			catch (error:IOError)
			{
			}
		}
		/**
		 * "saveLevel"函数将在文档位置（SD卡）
		 * 存储物品元件下落的序列"motion"，
		 * 并返回新生成的文件名。
		*/
		public function saveLevel(label:int):String
		{
			var path:String = "pickapple/custom" + String(label + 1) + ".dat";
			file = File.documentsDirectory.resolvePath(path);
			fileStream.open(file,FileMode.WRITE);
			fileStream.writeObject(motion);
			fileStream.close();
			return path;
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
				MovieClip(this.parent).gameTimer();
			}
			//遍历motion数组的每一个元素
			for (var i:int = 0; i < motion.length; i++)
			{
				/*
				 * 如果运行帧数大于元件的出发帧数
				 * 而且motion的p非空
				 *
				 * motion[i]的p用于引用particleLib
				 * 中的元件实例，当motion[i]不用的时候
				 * motion[i].p为null
				*/
				if (runFrame > motion[i].dropFrame && motion[i].p !== null)
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
							case "n" :
								get_apple();
								break;
							case "gold" :
								motion[i].p.gotoAndStop(1);
								MovieClip(this.parent).add_score(7);
								break;
							case "bomb" :
								MovieClip(this.parent).add_time(-5);
								bomb++;
								motion[i].p.gotoAndStop(1);
								MovieClip(this.parent).set_bomb(motion[i].targetX);
								break;
						}
						motion[i].p.visible = false;
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
								miss_apple();
								break;
							case "gold" :
							case "bomb" :
								motion[i].p.gotoAndStop(1);
								break;
						}
						motion[i].p.visible = false;
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
				/*
				 * 如果运行帧数恰好等于元件的出发帧数
				 * 则从particleLib中
				 * 分配一个实例给motion[i].p
				*/
				else if (runFrame == motion[i].dropFrame)
				{
					particlePoint++;
					motion[i].p = particleLib[particlePoint % libAmount];
					motion[i].p.x = motion[i].targetX;
					motion[i].p.y = -30;
					motion[i].p.visible = true;
					switch (motion[i].type)
					{
						case "bomb" :
							motion[i].p.gotoAndStop(3);
							break;
						case "gold" :
							motion[i].p.gotoAndStop(2);
							break;
					}
				}
			}
		}
		//清空游戏数据
		public function resetStats():void
		{
			combo = 0;
			maxcombo = 0;
			miss = 0;
			bomb = 0;
			caught = 0;
			runFrame = 0;
			particlePoint = 0;
			for (var i = 0; i < libAmount; i++)
			{
				particleLib[i].visible = false;
				particleLib[i].gotoAndStop(1);
			}
		}
		//清空motion数据
		public function clearMotion():void
		{
			motion.length = 0;
		}
		//接到苹果时调用的函数
		private function get_apple():void
		{
			combo++;
			caught++;
			maxcombo = combo > maxcombo ? combo:maxcombo;
			if (combo >= 3)
			{
				MovieClip(this.parent).gameUI.tcombo.text = "combo " + combo + "x";
				if (combo >= 5)
				{
					MovieClip(this.parent).add_score(3);
				}
				else
				{
					MovieClip(this.parent).add_score(1);
				}
			}
			else
			{
				MovieClip(this.parent).add_score(1);
			}
		}
		//错过苹果时调用的函数
		private function miss_apple()
		{
			combo = 0;
			miss++;
			try
			{
				MovieClip(this.parent).gameUI.tcombo.text = "";
			}
			catch (error:IOError)
			{
			}
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