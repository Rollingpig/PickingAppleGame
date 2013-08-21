package 
{

	import flash.display.MovieClip;
	import flash.events.TouchEvent;
	import particleSystem;
	import gameData;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	import bgDisplay;
	import flash.display.Sprite;
	import flash.display.Shape;

	public class pickApple extends MovieClip
	{
		public var parsys:particleSystem = new particleSystem();
		public var chickSpeed:int = 9;
		private var c_chickSpeed:int = 0;
		public var score:int = 0;
		public var remainTime:int = 10;
		public var leveldat:XML;
		private var savetime:int = 0;

		private var papple:apple = new apple();
		private var pbomb:bomb = new bomb();
		public var gamedata:gameData = new gameData();
		public var currentLevel:int = 1;

		public var levelIcons:Array = new Array  ;
		public var icons:Sprite = new Sprite();
		private var iconmask:Shape = new Shape();
		private var leveltotal:int = 0;

		public var levelUI:level_ui = new level_ui();
		public var menuUI:menu_ui = new menu_ui();
		public var rankUI:rank_ui = new rank_ui();
		public var aboutUI:about_ui = new about_ui();
		private var uis:Array = new Array(menuUI,levelUI,rankUI,aboutUI);
		private var bg:bgDisplay;
		private var postinfo:String = "";
		
		private var endSec:int = 2;
		private var pageSig:int = 0;

		public function pickApple()
		{
			stop();
			addChild(parsys);
			parsys.initParticle(papple);
			levelSettingHandler();
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			iconmask.graphics.beginFill(0x000000,1);
			iconmask.graphics.drawRect((480 - 400) / 2,125,400,85 * 7);
			iconmask.graphics.endFill();
			icons.mask = iconmask;
			bg = new bgDisplay(this,bgLayer);
			postinfo = "menu";
			bg.loadMenu();
		}
		/*
		layout
		*/
		public function postLoad():void
		{
			switch (postinfo)
			{
				case "menu":
					gotoAndStop(1);
					showUI("menuUI");
					break;
				case "start game":
					gameLayout();
					break;
				case "select":
					gotoAndStop(1);
					showUI("levelUI");
					break;
				case "about":
					showUI("aboutUI");
					break;
				case "rank":
					showUI("rankUI");
					break;
			}
		}
		public function levelSettingHandler():void
		{
			leveltotal = 0;
			var cy:int = 125;
			for (var i:int = 0; i<levelIcons.length; i++)
			{
				if (icons.contains(levelIcons[i]))
				{
					icons.removeChild(levelIcons[i]);
				}
			}
			levelIcons.length = 0;
			for each (var prop:XML in gamedata.leveldata.level)
			{
				leveltotal++;
				var p:levelIcon = new levelIcon();
				p.high_txt.text = gamedata.getHighest(leveltotal);
				p.label_txt.text = String(leveltotal);
				p.title_txt.text = prop.title;
				p.rank_btn.addEventListener(TouchEvent.TOUCH_TAP,showRank);
				p.level_btn.addEventListener(TouchEvent.TOUCH_TAP,startLevel);
				p.x = (480 - 400) / 2;
				p.y = cy;
				cy +=  85;
				levelIcons.push(p);
			}
		}
		public function iconsUp(event:TouchEvent):void
		{
			if (icons.y < 0) icons.y += 85;
		}
		public function iconsDown(event:TouchEvent):void
		{
			if (icons.y + icons.height > 570) icons.y -= 85;
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
					levelUI.addChild(iconmask);
					levelUI.addChild(icons);
					levelUI.home_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					levelUI.up_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsUp);
					levelUI.down_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsDown);
					for (var j:int = 0; j<levelIcons.length; j++)
					{
						if (! icons.contains(levelIcons[j]))
						{
							icons.addChild(levelIcons[j]);
						}
						levelIcons[j].high_txt.text = gamedata.getHighest(j+1);
					}
					break;
				case "rankUI" :
					rankUI.visible = true;
					rankUI.home_btn.addEventListener(TouchEvent.TOUCH_TAP,exitRank);
					rankUI.rank_txt.text = gamedata.getFullRank(currentLevel);
					rankUI.title_txt.text = gamedata.leveldata.level[currentLevel-1].title;
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
		public function gameLayout():void
		{
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
		/*
		functions for buttons
		*/
		public function returnHome(Event:TouchEvent)
		{
			postinfo = "menu";
			bg.loadMenu();
		}
		public function goAbout(Event:TouchEvent)
		{
			postinfo = "about";
			bg.loadSelect();
		}
		public function returnLevel(Event:TouchEvent)
		{
			gamedata.addRankResult(scoreUI.name_txt.text,score,currentLevel);
			selectLevel();
		}
		public function selectLevel(event:TouchEvent = null)
		{
			postinfo = "select";
			bg.loadSelect();
		}
		public function showRank(event:TouchEvent)
		{
			currentLevel = levelIcons.indexOf(event.target.parent) + 1;
			showUI("rankUI");
		}
		public function exitRank(event:TouchEvent)
		{
			showUI("levelUI");
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
			selectLevel();
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
		public function startLevel(event:TouchEvent)
		{
			parsys.resetStats();
			parsys.clearMotion();
			c_chickSpeed = 0;
			score = 0;
			savetime = 0;
			currentLevel = levelIcons.indexOf(event.target.parent) + 1;
			var lev:XML = gamedata.leveldata.level[currentLevel - 1];
			if (lev.random == true)
			{
				parsys.basicSpeed = lev.basicspeed;
				parsys.generate(lev.normal,lev.time,lev.bomb,lev.golden,lev.threshold,lev.imaginespeed);
			}
			else
			{
				parsys.loadLocal(lev.path);
			}
			chickSpeed = lev.chickspeed;
			remainTime = lev.time;
			leveldat = lev;
			postinfo = "start game";
			bg.loadLevel(lev.background);
		}
		public function replayLevel(event:TouchEvent)
		{
			c_chickSpeed = 0;
			score = 0;
			savetime = 0;
			parsys.resetStats();
			chickSpeed = leveldat.chickspeed;
			remainTime = leveldat.time;
			gameUI.tscore.text = String(score);
			gameUI.ttime.text = stomin(remainTime);
			gameUI.tcombo.text = "";
			add_game_motion();
			addChickenListener();
			gameUI.gotoAndStop(1);
		}
		public function saveLevel(event:TouchEvent):void
		{
			if (savetime == 0)
			{
				var path:String = parsys.saveLevel(leveltotal + 1);
				gamedata.addLevel(name_txt.text,path,leveldat,leveltotal + 1);
				levelSettingHandler();
				savetime++;
				selectLevel();
				parsys.exitEdit();
			}
		}
		public function backdoor(Event:TouchEvent)
		{
			var s:String = aboutUI.back_txt.text;
			var command:Array = s.split("#");
			switch (command[0])
			{
				case "clr" :
					gamedata.clearLevelResult(int(command[1]));
					break;
				case "del" :
					if (gamedata.deleteLevel(int(command[1])))
					{
						levelSettingHandler();
					}
					break;
				case "tl" :
					trace(gamedata.leveldata);
					break;
			}
		}
		public function editLevel(Event:TouchEvent):void
		{
			gotoAndStop(5);
			parsys.enterEdit();
			pageSig = -1;
			addChild(parsys);
			endSec = 2;
			timerange.text = stomin(endSec-2) + "-" + stomin(endSec);
			f_btn.addEventListener(TouchEvent.TOUCH_TAP,pageUp);
			b_btn.addEventListener(TouchEvent.TOUCH_TAP,pageDown);
			save_btn.addEventListener(TouchEvent.TOUCH_TAP,saveLevel);
			back_btn.addEventListener(TouchEvent.TOUCH_TAP,exitEdit);
			typen.addEventListener(TouchEvent.TOUCH_TAP,typeItem);
			typegold.addEventListener(TouchEvent.TOUCH_TAP,typeItem);
			typebomb.addEventListener(TouchEvent.TOUCH_TAP,typeItem);
			lock.addEventListener(TouchEvent.TOUCH_TAP,toggleLock);
		}
		public function exitEdit(Event:TouchEvent):void
		{
			selectLevel();
			parsys.exitEdit();
		}
		public function typeItem(event:TouchEvent):void
		{
			parsys.editType = event.target.name.split("type")[1];
		}
		public function toggleLock(event:TouchEvent):void
		{
			parsys.lock = ! parsys.lock;
			if (parsys.lock)
			{
				lock.gotoAndStop(2);
			}
			else
			{
				lock.gotoAndStop(1);
			}
		}
		public function pageUp(Event:TouchEvent):void
		{
			//trace(pageSig);
			if(pageSig !== 1)
			{
				pageSig = parsys.switchPage(1);
				timerange.text = stomin(endSec) + "-" + stomin(endSec+2);
				endSec += 2;
			}
		}
		public function pageDown(Event:TouchEvent):void
		{
			//trace(pageSig);
			if(pageSig !== -1)
			{
				pageSig = parsys.switchPage(-1);
				endSec -= 2;
				timerange.text = stomin(endSec-2) + "-" + stomin(endSec);
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
			chicken.gotoAndPlay(2);
			pbomb.x = tx;
			pbomb.y = 500;
			pbomb.gotoAndPlay(1);
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