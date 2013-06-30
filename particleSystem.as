package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;
	import flash.errors.IOError;
	import flash.filesystem.*;
	import particleData;

	public class particleSystem extends Sprite
	{
		private var motion:Array = new Array  ;
		private var particleLib:Array = new Array  ;
		private const libAmount:int = 20;
		private var particlePoint:int = 0;
		private var runFrame:int = 0;

		private const layerWidth:int = 480 - 40;
		private const layerHeight:int = 700;
		private const chickHeight:int = 570;

		public var hitZone:MovieClip;
		public var basicSpeed:int = 7;

		public var caught:int = 0;
		public var bomb:int = 0;
		public var miss:int = 0;
		public var combo:int = 0;
		public var maxcombo:int = 0;
		
		private var file:File = File.applicationStorageDirectory;
		private var fileStream:FileStream = new FileStream();

		public function particleSystem()
		{
			this.mouseEnabled = false;
		}
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
		public function generate(normal:int,totalTime:int,bombs:int,golden:int,threshold:Number,imaSpeed:int)
		{
			var totalFrame:int = totalTime * 24;
			var deltaFrame:Number  = 0;
			var beginFrame:int = int(chickHeight / basicSpeed);
			var deltaX:int = 0;
			var ut:Number = (totalFrame - beginFrame)/ normal;
			deltaFrame = beginFrame;
			for (var i:int = 0; i < normal; i++)
			{
				deltaFrame += ut;
				motion.push(new particleData  );
				motion[i].dropFrame = int(deltaFrame);
			}
			for (i = 0; i < normal; i++)
			{
				if (i == 0)
				{
					motion[i].targetX = int((layerWidth / 2));
				}
				else
				{
					deltaX = (Math.random() * (1 - threshold) + threshold) * imaSpeed * deltaFrame;
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
				motion[i].vy = Math.random() * 12 + basicSpeed;
				if (i < normal - 1)
				{
					deltaFrame = motion[i + 1].dropFrame - motion[i].dropFrame;
				}
				motion[i].dropFrame -= int(chickHeight / motion[i].vy);
			}
			var temp:particleData;
			for (i=0; i<bombs; i++)
			{
				temp = new particleData  ;
				temp.vy = Math.random() * 12 + basicSpeed;
				temp.dropFrame = Math.random() * (totalFrame - beginFrame) + beginFrame - int(chickHeight / temp.vy);
				temp.type = "bomb";
				temp.targetX = Math.random() * layerWidth;
				motion.push(temp);
			}
			for (i=0; i<golden; i++)
			{
				temp = new particleData  ;
				temp.vy = Math.random() * 8 + basicSpeed + 5;
				temp.dropFrame = Math.random() * (totalFrame - beginFrame) + beginFrame - int(chickHeight / temp.vy);
				temp.targetX = Math.random() * layerWidth;
				temp.type = "gold";
				motion.push(temp);
			}
		}
		public function loadLocal(path:String = "level.dat"):void
		{
			file = File.applicationStorageDirectory.resolvePath(path);
			try
			{
				fileStream.open(file, FileMode.READ);
				motion = fileStream.readObject();
				fileStream.close();
			}
			catch (error:IOError)
			{
			}
		}
		public function saveLevel():void
		{
			var k:int = Math.random() * 1000;
			file = File.applicationStorageDirectory.resolvePath("custom"+String(k)+".txt");
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(motion);
			fileStream.close();
		}
		private function particle_motion(event:Event):void
		{
			runFrame++;
			if (runFrame % 24 == 0)
			{
				MovieClip(this.parent).gameTimer();
			}
			for (var i:int = 0; i < motion.length; i++)
			{
				if (runFrame > motion[i].dropFrame && motion[i].used == false)
				{
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
						motion[i].dropFrame = 10000;
						//motion[i].p = null;
					}
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
						motion[i].used = true;
						//motion[i].p = null;
					}
					else
					{
						motion[i].p.y +=  motion[i].vy;
					}
				}
				else if (runFrame == motion[i].dropFrame)
				{
					particlePoint++;
					//trace("release",i,particlePoint % libAmount);
					motion[i].p = particleLib[particlePoint % libAmount];
					motion[i].p.x = motion[i].targetX;
					motion[i].p.y = -30;
					motion[i].p.visible = true;
					switch (motion[i].type)
						{
							case "bomb" :
								motion[i].p.gotoAndStop(3);
								break;
								case "gold":
								motion[i].p.gotoAndStop(2);
								break;
						}
				}
			}
		}
		public function resetStats():void
		{
			combo = 0;
			maxcombo = 0;
			miss = 0;
			bomb = 0;
			caught = 0;
			motion.length = 0;
			runFrame = 0;
			particlePoint = 0;
			for (var i = 0; i < libAmount; i++)
			{
				particleLib[i].visible = false;
				particleLib[i].gotoAndStop(1);
			}
		}
		private function get_apple():void
		{
			combo++;
			caught++;
			maxcombo = combo > maxcombo ? combo:maxcombo;
			if (combo>=3)
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
		public function addMotion():void
		{
			this.addEventListener(Event.ENTER_FRAME,particle_motion);
		}
		public function stopMotion():void
		{
			this.removeEventListener(Event.ENTER_FRAME,particle_motion);
		}
	}

}