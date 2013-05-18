package 
{

	import flash.display.MovieClip;
	import flash.events.TouchEvent;
	import flash.events.TimerEvent;
	import particleSystem;
	import fpsCatcher;
	import gameData;
	import flash.utils.Timer;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.Event;
	import flash.desktop.NativeApplication;

	public class pickApple extends MovieClip
	{
		public var parsys:particleSystem = new particleSystem();
		public const timeMode_time:int = 40;
		public var chickSpeed:int = 9;
		public var c_chickSpeed:int = 0;
		public var basicSpeed:int = 5;
		public var score:int = 0;
		public var remainTime:int = 10;
		public var gameTimer:Timer = new Timer(1000,1000);
		public var currentMode:String = "harmony";
		public var papple:apple = new apple();
		public var fpsCat:fpsCatcher = new fpsCatcher();
		public var gamedata:gameData = new gameData();

		public function pickApple()
		{
			fpsCat.y = 520;
			addChild(parsys);
			gameTimer.addEventListener(TimerEvent.TIMER,gameTimerHandler);
			addChild(fpsCat);
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		/*
		functions for buttons
		*/
		public function returnHome(Event:TouchEvent)
		{
			gotoAndStop(2);
		}
		public function returnLevel(Event:TouchEvent)
		{
			parsys.hideParticle();
			gamedata.addRankResult(scoreUI.name_txt.text,score);
			score = 0;
			gotoAndStop(3);
		}
		public function selectLevel(Event:TouchEvent)
		{
			gotoAndStop(3);
		}
		public function showRank(Event:TouchEvent)
		{
			gotoAndStop(6);
		}
		public function exitProgram(Event:TouchEvent)
		{
			gamedata.writeRanklist();
			NativeApplication.nativeApplication.exit();
		}
		public function endGame(Event:TouchEvent)
		{
			gameOver();
		}
		public function resumeGame(Event:TouchEvent)
		{
			if (currentMode == "time")
			{
				gameTimer.start();
			}
			add_game_motion();
			addChickenListener();
			gameUI.gotoAndStop(1);
		}
		public function pauseGame(Event:TouchEvent)
		{
			if (currentMode == "time")
			{
				gameTimer.stop();
			}
			stop_game_motion();
			removeChickenListener();
			gameUI.gotoAndStop(2);
		}
		/*
		basic function for game
		*/
		public function add_score(value:int):void
		{
			score +=  value;
			gameUI.tscore.text = String(score);
		}
		public function add_time(value:int):void
		{
			remainTime +=  value;
			gameUI.ttime.text = stomin(remainTime);
		}
		public function timeMode(Event:TouchEvent)
		{
			currentMode = "time";
			parsys.addParticle(5,papple);
			add_game_motion();
			chickSpeed = 12;
			basicSpeed = 8;
			gotoAndStop(4);
			gameUI.tscore.text = String(score);
			remainTime = timeMode_time;
			gameUI.ttime.text = stomin(remainTime);
			gameTimer.start();
			addChickenListener();
		}
		public function gameOver()
		{
			gotoAndStop(5);
			removeChild(parsys);
			removeChild(gameUI);
			scoreUI.tscore.text = String(score);
			c_chickSpeed = 0;
			stop_game_motion();
			gameTimer.stop();
			gameTimer.reset();
		}
		public function gameTimerHandler(event:TimerEvent):void
		{
			if (remainTime>0)
			{
				remainTime--;
				gameUI.ttime.text = stomin(remainTime);
			}
			else
			{
				gameOver();
			}
		}
		public function add_game_motion():void
		{
			addEventListener(Event.ENTER_FRAME,game_motion);
			parsys.addMotion();
		}
		public function stop_game_motion():void
		{
			removeEventListener(Event.ENTER_FRAME,game_motion);
			parsys.stopMotion();
		}
		public function game_motion(event:Event):void
		{
			if ((c_chickSpeed > 0 && chicken.x < 480 - chicken.width) ||(c_chickSpeed < 0 && chicken.x > 0) )
			{
				chicken.x +=  c_chickSpeed;
			}
		}
		public function stomin(second:int)
		{
			var min:int = second / 60;
			var se:int = second - min * 60;
			var re:String = "";
			if (min<10)
			{
				if (se<10)
				{
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
					re = min + ":0" + se;
				}
				else
				{
					re =  +  min + ":" + se;
				}
			}
			return re;
		}
		/*
		for chicken
		*/
		public function addChickenListener():void
		{
			gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_BEGIN, motionLeft_BeginHandler);
			gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_END, motionLeft_EndHandler);
			gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_ROLL_OUT, motionLeft_EndHandler);
			gameUI.leftBtn.addEventListener(TouchEvent.TOUCH_OVER, motionLeft_BeginHandler);
			gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_BEGIN, motionRight_BeginHandler);
			gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_END, motionRight_EndHandler);
			gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_ROLL_OUT, motionRight_EndHandler);
			gameUI.rightBtn.addEventListener(TouchEvent.TOUCH_OVER, motionRight_BeginHandler);
		}
		public function removeChickenListener():void
		{
			gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, motionLeft_BeginHandler);
			gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_END, motionLeft_EndHandler);
			gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, motionLeft_EndHandler);
			gameUI.leftBtn.removeEventListener(TouchEvent.TOUCH_OVER, motionLeft_BeginHandler);
			gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_BEGIN, motionRight_BeginHandler);
			gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_END, motionRight_EndHandler);
			gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_ROLL_OUT, motionRight_EndHandler);
			gameUI.rightBtn.removeEventListener(TouchEvent.TOUCH_OVER, motionRight_BeginHandler);
		}
		public function motionLeft_BeginHandler(event:TouchEvent):void
		{
			c_chickSpeed =  -  chickSpeed;
		}
		public function motionLeft_EndHandler(event:TouchEvent):void
		{
			if (c_chickSpeed<0)
			{
				c_chickSpeed = 0;
			}
		}
		public function motionRight_BeginHandler(event:TouchEvent):void
		{
			c_chickSpeed = chickSpeed;
		}
		public function motionRight_EndHandler(event:TouchEvent):void
		{
			if (c_chickSpeed>0)
			{
				c_chickSpeed = 0;
			}
		}
	}

}