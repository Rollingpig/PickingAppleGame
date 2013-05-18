package 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.display.DisplayObject;

	public class particleSystem extends Sprite
	{
		public var particleActive:int = 0;
		public var particleAmount:int = 0;
		public var particles:Array = new Array  ;
		public var motion:Array = new Array  ;
		public var layerWidth:int = 480;
		public var layerHeight:int = 700;
		public var hitZone:MovieClip;

		public function particleSystem()
		{
			this.mouseEnabled = false;
			// constructor code
		}
		public function addParticle(quantity:int,target:Object):void
		{
			particleActive +=  quantity;
			if (particleAmount < particleActive)
			{
				var newAmount:int = particleActive - particleAmount;
				for (var i = 0; i <= newAmount - 1; i++)
				{
					var particle:MovieClip = new target.constructor();
					particles.push(particle);
					motion.push(new Object());
					this.addChild(particle);
					particleAmount = particles.length - 1;
					set_particle_motion(particles[particleAmount],motion[particleAmount]);
				}
			}
			trace(particles.length);
		}
		public function hideParticle()
		{
			for (var i = 0; i <= particleActive - 1; i++)
			{
				set_particle_motion(particles[i],motion[i]);
			}
			particleActive = 0;
		}
		public function set_particle_motion(particle:MovieClip,motion:Object):void
		{
			particle.x = Math.random() * (layerWidth - 60) + 30;
			particle.y = 0 - Math.random() * 150 - 45;
			motion.vy = Math.random() * 10 + 5;
			//5: basicSpeed
			particle.gotoAndStop(1);
			motion.type = "n";
			particle.visible = false;
			var k:int = Math.random() * 15;
			if (k == 6)
			{
				mutation_particle(particle,motion);
			}
		}
		public function mutation_particle(particle:MovieClip,motion:Object):void
		{
			particle.gotoAndStop(2);
			motion.type = "time";
		}
		public function normal_particle(particle:MovieClip,motion:Object):void
		{
			particle.gotoAndStop(1);
			motion.type = "n";
		}
		public function addMotion():void
		{
			this.addEventListener(Event.ENTER_FRAME,particle_motion);
		}
		public function stopMotion():void
		{
			this.removeEventListener(Event.ENTER_FRAME,particle_motion);
		}
		private function solve_particle(particle:MovieClip,motion:Object):void
		{
			if (motion.type == "time")
			{
				MovieClip(this.parent).add_time(3);
				normal_particle(particle,motion);
				set_particle_motion(particle,motion);
			}
			else
			{
				MovieClip(this.parent).add_score(1);
				set_particle_motion(particle,motion);
			}
		}
		private function particle_motion(event:Event):void
		{
			for (var i = 0; i <= particleActive - 1; i++)
			{
				if (particles[i].y > -45)
				{
					particles[i].visible = true;
				}
				if (particles[i].y > 500)
				{
					if (particles[i].hitTestObject(hitZone))
					{
						solve_particle(particles[i],motion[i]);
					}
					else if (particles[i].y > layerHeight)
					{
						set_particle_motion(particles[i],motion[i]);
					}
					else
					{
						particles[i].y +=  motion[i].vy;
					}
				}
				else
				{
					particles[i].y +=  motion[i].vy;
				}
			}
		}

	}

}