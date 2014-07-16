package  {
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TouchEvent;
	
	public class gameControl {
		
		public var levData:Object = new Object();
		
		public var stats:Object = new Object();
		public var chickSpeed:int = 9;
		private var c_chickSpeed:int = 0;
		public var score:int = 0;
		public var remainTime:int = 10;
		
		public var main:MovieClip;
		
		public function gameControl(mainTimeline:MovieClip):void
		{
			main = mainTimeline;
			resetGameStats();
		}
		public function gameEvent(event:String,targetX:int = 0):void
		{
			switch(event)
			{
				case "miss":
					stats.combo = 0;
					stats.miss++;
					main.gameUI.tcombo.text = "";
					break;
				case "n" :
					stats.combo++;
					stats.caught++;
					stats.maxcombo = stats.combo > stats.maxcombo ? stats.combo:stats.maxcombo;
					if (stats.combo >= 3)
					{
						main.gameUI.tcombo.text = "combo " + stats.combo + "x";
					}
					var incr:int = stats.combo / 3 + 1;
					incr = incr >10 ? 10:incr;
					add_score(incr);
					setGadget(main.gadgets.plusx,targetX,incr);
					break;
				case "gold" :
					add_score(7);
					setGadget(main.gadgets.plusx,targetX,7);
					break;
				case "bomb" :
					add_time(-3);
					stats.bomb++;
					set_bomb(targetX);
					setGadget(main.gadgets.dectime,targetX);
					break;
			}
		}
		public function add_score(value:int):void
		{
			score +=  value;
			main.gameUI.tscore.text = String(score);
		}
		public function add_time(value:int):void
		{
			remainTime +=  value;
			main.gameUI.ttime.text = stomin(remainTime);
		}
		public function setGadget(target:MovieClip,tarX:int,value:int = 0):void
		{
			target.y = 440;
			target.x = tarX;
			switch(target.name)
			{
				case "plusx":
					target.tas.text = "+" + value;
					break;
			}
			main.effectLayer.addChild(target);
			target.gotoAndPlay(2);
		}
		public function set_bomb(tx:Number)
		{
			main.effectLayer.addChild(main.pbomb);
			main.chicken.gotoAndPlay(2);
			main.pbomb.x = tx;
			main.pbomb.y = 500;
			main.pbomb.gotoAndPlay(1);
		}
		public function resetGameStats():void
		{
			stats["combo"] = 0;
			stats["maxcombo"] = 0;
			stats["miss"] = 0;
			stats["bomb"] = 0;
			stats["caught"] = 0;
			c_chickSpeed = 0;
			score = 0;
		}
		public function loadLevelData():void
		{
			chickSpeed = levData.chickspeed;
			remainTime = levData.time;
		}
		public function fillBlankLevelData():void
		{
			levData["chickspeed"] = 12;
			levData["background"] = "native/level1.png";
			levData["time"] = 30;
			levData["title"] = "自定义";
			if (levData["sequence"] == null)
			{
				levData["sequence"]= new Array();
			}else{
				levData["sequence"].length = 0;
			}
		}
		public function refreshDataBoard():void
		{
			main.gameUI.tscore.text = String(score);
			main.gameUI.ttime.text = stomin(remainTime);
			main.gameUI.tcombo.text = "";
		}
		public function gameAnalyze():String
		{
			var result:String = score + "\r";
			var bonus:int = 0;
			result +=  String(stats.caught) + "/" + String(stats.miss + stats.caught) + "\r";
			//var ratio:Number = stats.caught/(stats.miss + stats.caught);
			//bonus = ratio > 0.8 ? bonus + int(ratio * 250) - 200:bonus;
			//bonus +=  int(stats.maxcombo * 0.6);
			result +=  String(stats.maxcombo) + "\r" + String(bonus);
			score +=  bonus;
			return result;
		}
		public function gameTimer():void
		{
			if (remainTime>0)
			{
				remainTime--;
				main.gameUI.ttime.text = stomin(remainTime);
			}
			else
			{
				main.gameOver();
			}
		}
		public function addMotion():void
		{
			main.addEventListener(Event.ENTER_FRAME,game_motion);
			main.parsys.addMotion();
			addChickenListener();
		}
		public function stopMotion():void
		{
			main.removeEventListener(Event.ENTER_FRAME,game_motion);
			main.parsys.stopMotion();
			removeChickenListener();
		}
		public function game_motion(event:Event):void
		{
			if ((c_chickSpeed > 0 && main.chicken.x < 480 - main.chicken.width) ||(c_chickSpeed < 0 && main.chicken.x > 0) )
			{
				main.chicken.x +=  c_chickSpeed;
			}
		}
		private function stomin(second:int)
		{
			var min:int = second / 60;
			var se:int = second - min * 60;
			var re:String = "";
			if (min<10)
			{
				if (se<10)
				{
					if (se < 0) se = 0;
					re = "0" + min + ":0" + se;
				}
				else
				{
					re = "0" + min + ":" + se;
				}
			}
			else
			{
				if (se<10)
				{
					if (se < 0) se = 0;
					re = min + ":0" + se;
				}
				else
				{
					re =  +  min + ":" + se;
				}
			}
			return re;
		}
		private function addChickenListener():void
		{
			main.gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_BEGIN, motionLeft_BeginHandler);
			main.gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_END, motionLeft_EndHandler);
			main.gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_ROLL_OUT, motionLeft_EndHandler);
			main.gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_OVER, motionLeft_BeginHandler);
			main.gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_BEGIN, motionRight_BeginHandler);
			main.gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_END, motionRight_EndHandler);
			main.gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_ROLL_OUT, motionRight_EndHandler);
			main.gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_OVER, motionRight_BeginHandler);
		}
		private function removeChickenListener():void
		{
			main.gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, motionLeft_BeginHandler);
			main.gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_END, motionLeft_EndHandler);
			main.gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, motionLeft_EndHandler);
			main.gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_OVER, motionLeft_BeginHandler);
			main.gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, motionRight_BeginHandler);
			main.gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_END, motionRight_EndHandler);
			main.gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, motionRight_EndHandler);
			main.gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_OVER, motionRight_BeginHandler);
		}
		public function motionLeft_BeginHandler(event:TouchEvent):void
		{
			c_chickSpeed =  - chickSpeed;
		}
		public function motionLeft_EndHandler(event:TouchEvent):void
		{
			if (c_chickSpeed<0)
				c_chickSpeed = 0;
		}
		public function motionRight_BeginHandler(event:TouchEvent):void
		{
			c_chickSpeed = chickSpeed;
		}
		public function motionRight_EndHandler(event:TouchEvent):void
		{
			if (c_chickSpeed > 0)
				c_chickSpeed = 0;
		}
		
	}
	
}
