package 
{

	import flash.display.MovieClip;
	import flash.events.TouchEvent;
	import flash.events.TimerEvent;
	import particleSystem;
	import gameData;
	import flash.utils.Timer;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	import flash.net.URLRequest;
	import flash.net.URLLoader;

	public class pickApple extends MovieClip
	{
		public var parsys:particleSystem = new particleSystem();
		public var chickSpeed:int = 9;
		private var c_chickSpeed:int = 0;
		public var score:int = 0;
		public var remainTime:int = 10;
		public var leveldat:Object = {time:0,chickspeed:0};
		
		private var papple:apple = new apple();
		private var pbomb:bomb = new bomb();
		public var gamedata:gameData = new gameData();
		public var currentLevel:int = 1;

		public var levelIcons:Array = new Array  ;

		public var levelUI:level_ui = new level_ui();
		public var menuUI:menu_ui = new menu_ui();
		public var rankUI:rank_ui = new rank_ui();
		public var aboutUI:about_ui = new about_ui();
		private var uis:Array = new Array(menuUI,levelUI,rankUI,aboutUI);

		public function pickApple()
		{
			stop();
			addChild(parsys);
			parsys.initParticle(papple);
			levelSettingHandler();
			showUI("menuUI");
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		function levelSettingHandler():void
		{
			var total:int = 0;
			var cy:int = 130;
			for each (var prop:XML in gamedata.leveldata.level)
			{
				total++;
				var p:levelIcon = new levelIcon();
				p.high_txt.text = gamedata.getHighest(total);
				p.label_txt.text = String(total);
				p.title_txt.text = prop.title;
				p.rank_btn.addEventListener(TouchEvent.TOUCH_TAP,showRank);
				p.level_btn.addEventListener(TouchEvent.TOUCH_TAP,startLevel);
				p.x = (480-400)/2;
				p.y = cy;
				cy +=  90;
				levelIcons.push(p);
			}
		}
		private function showUI(tname:String):void
		{
			for (var i:int = 0; i< uis.length; i++)
			{
				uis[i].visible = false;
				topLayer.addChild(uis[i]);
			}
			switch (tname)
			{
				case "levelUI" :
					levelUI.visible = true;
					levelUI.home_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					for (var j:int = 0; j<levelIcons.length; j++)
					{
						if (! levelUI.contains(levelIcons[j]))
						{
							levelUI.addChild(levelIcons[j]);
						}
						levelIcons[j].high_txt.text = gamedata.getHighest(j+1);
					}
					break;
				case "rankUI" :
					rankUI.visible = true;
					rankUI.home_btn.addEventListener(TouchEvent.TOUCH_TAP,exitRank);
					rankUI.rank_txt.text = gamedata.getFullRank(currentLevel);
					rankUI.title_txt.text = "Lawn - " + String(currentLevel);
					break;
				case "aboutUI" :
					aboutUI.visible = true;
					aboutUI.home_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					aboutUI.backdoor_btn.addEventListener(TouchEvent.TOUCH_TAP,backdoor);
					break;
				case "menuUI" :
					menuUI.visible = true;
					menuUI.select_btn.addEventListener(TouchEvent.TOUCH_TAP,Object(root).selectLevel);
					menuUI.about_btn.addEventListener(TouchEvent.TOUCH_TAP,Object(root).goAbout);
					menuUI.exit_btn.addEventListener(TouchEvent.TOUCH_TAP,Object(root).exitProgram);
					break;
			}
		}
		/*
		functions for buttons
		*/
		public function returnHome(Event:TouchEvent)
		{
			showUI("menuUI");
			gotoAndStop(1);
		}
		public function goAbout(Event:TouchEvent)
		{
			showUI("aboutUI");
			gotoAndStop(2);
		}
		public function returnLevel(Event:TouchEvent)
		{
			parsys.resetStats();
			gamedata.addRankResult(scoreUI.name_txt.text,score,currentLevel);
			gotoAndStop(2);
			showUI("levelUI");
		}
		public function selectLevel(Event:TouchEvent)
		{
			showUI("levelUI");
			gotoAndStop(2);
		}
		public function showRank(event:TouchEvent)
		{
			currentLevel = levelIcons.indexOf(event.target.parent) + 1;
			showUI("rankUI");
			gotoAndStop(2);
		}
		public function exitRank(event:TouchEvent)
		{
			showUI("levelUI");
			gotoAndStop(2);
		}
		public function exitProgram(Event:TouchEvent)
		{
			gamedata.writeRanklist();
			NativeApplication.nativeApplication.exit();
		}
		public function endGame(Event:TouchEvent)
		{
			removeChild(parsys);
			removeChild(gameUI);
			stop_game_motion();
			parsys.resetStats();
			gotoAndStop(2);
			showUI("levelUI");
		}
		public function resumeGame(Event:TouchEvent)
		{
			add_game_motion();
			addChickenListener();
			gameUI.gotoAndStop(1);
		}
		public function pauseGame(Event:TouchEvent)
		{
			stop_game_motion();
			removeChickenListener();
			gameUI.gotoAndStop(2);
		}
		public function backdoor(Event:TouchEvent)
		{
			var s:String = aboutUI.back_txt.text;
			var command:Array = s.split("#");
			switch(command[0])
			{
				case "clearlevel":
				gamedata.clearLevelResult(int(command[1]));
				break;
				case "deletelevel":
				gamedata.deleteLevel(int(command[1]));
				break;
				case "tl":
				trace(gamedata.leveldata);
				break;
			}
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
		public function set_bomb(tx:Number)
		{
			this.addChild(pbomb);
			pbomb.x = tx;
			pbomb.y = 500;
			pbomb.gotoAndPlay(1);
		}
		public function startLevel(event:TouchEvent)
		{
			c_chickSpeed = 0;
			score = 0;
			currentLevel = levelIcons.indexOf(event.target.parent) + 1;
			var lev:XML = gamedata.leveldata.level[currentLevel - 1];
			if(lev.random == true)
			{
				parsys.basicSpeed = lev.basicspeed;
				parsys.generate(lev.normal,lev.time,lev.bomb,lev.golden,lev.threshold,lev.imaginespeed);
			}else{
				parsys.loadLocal(lev.path);
			}
			chickSpeed = lev.chickspeed;
			remainTime = lev.time;
			leveldat.time = remainTime;
			leveldat.chickspeed = chickSpeed;
			gotoAndStop(3);
			parsys.hitZone = Object(root).chicken.hitBasket;
			addChild(parsys);
			addChild(gameUI);
			gameUI.tscore.text = String(score);
			gameUI.ttime.text = stomin(remainTime);
			gameUI.tcombo.text = "";
			add_game_motion();
			addChickenListener();
		}
		public function saveLevel(event:TouchEvent):void
		{
			var path:String = parsys.saveLevel(gamedata.leveldata.@total);
			gamedata.addLevel("Custom",path,leveldat.time,leveldat.chickspeed);
		}
		public function gameOver():void
		{
			gotoAndStop(4);
			removeChild(parsys);
			removeChild(gameUI);
			stop_game_motion();
		}
		public function gameAnalyze():String
		{
			var result:String = score + "\r";
			var bonus:int = 0;
			result +=  String(parsys.caught) + "/" + String(parsys.miss + parsys.caught) + "\r";
			var ratio:Number = parsys.caught/(parsys.miss + parsys.caught);
			bonus = ratio > 0.8 ? bonus + int(ratio * 250) - 200:bonus;
			//trace(ratio,int(ratio * 250) - 200);
			bonus +=  int(parsys.maxcombo * 0.6);
			result +=  String(parsys.maxcombo) + "\r" + String(bonus);
			score +=  bonus;
			return result;
		}
		public function gameTimer():void
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