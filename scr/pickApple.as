package 
{

	import flash.display.MovieClip;
	import flash.events.TouchEvent;
	import particleSystem;
	import gameData;
	import gameControl;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.events.Event;
	import flash.desktop.NativeApplication;
	import imgManager;
	import flash.display.Sprite;
	import flash.display.Shape;

	public class pickApple extends MovieClip
	{
		public var parsys:particleSystem;
		
		public var papple:apple = new apple();
		public var pbomb:bomb = new bomb();
		public var gadgets:Object = new Object();
		public var game:gameControl;
		
		public var dataIO:gameData = new gameData();
		
		public var currentLevel:int = 1;
		public var currentList:int = 1;
		private var savetime:int = 0;
		
		public var iconArray:Array = new Array  ;
		public var iconList:Sprite = new Sprite();
		private var iconmask:Shape = new Shape();
		private var iconTotal:int = 0;
		private var iconType:String = "list";

		private var imgSet:imgManager;
		private var targetPage:String = "";
		
		private var endSec:int = 2;
		private var pageSig:int = 0;

		public function pickApple()
		{
			stop();
			//initailize particle system, add it to the stage
			parsys = new particleSystem(this);
			addChild(parsys);
			parsys.initParticle(papple);
			//innitialize game
			game = new gameControl(this);
			//initialize small objects in the stage
			initGadgets();
			//initailize level list
			refreshList("list");
			iconmask.graphics.beginFill(0x000000,1);
			iconmask.graphics.drawRect((480 - 400) / 2,125,400,85 * 7);
			iconmask.graphics.endFill();
			iconList.mask = iconmask;
			//initailize background Loader
			imgSet = new imgManager(this,bgLayer);
			//set touch mode
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			//
			returnHome();
		}
		/*
		layout
		*/
		public function switchPage():void
		{
			iconList.visible = false;
			switch (targetPage)
			{
				case "menu":
					gotoAndStop(1);
					UIs.gotoAndStop(1);
					UIs.select_btn.addEventListener(TouchEvent.TOUCH_TAP,selectLevel);
					UIs.output_btn.addEventListener(TouchEvent.TOUCH_TAP,selectOutputLevel);
					UIs.about_btn.addEventListener(TouchEvent.TOUCH_TAP,goAbout);
					UIs.exit_btn.addEventListener(TouchEvent.TOUCH_TAP,exitProgram);
					refreshList("list");
					break;
				case "start game":
					gotoAndStop(3);
					parsys.hitZone = Object(root).chicken.hitBasket;
					addChild(parsys);
					addChild(gameUI);
					game.refreshDataBoard();
					resumeGame();
					break;
				case "select":
				case "selectOutput":
					gotoAndStop(1);
					UIs.gotoAndStop(2);
					UIs.addChild(iconmask);
					UIs.addChild(iconList);
					iconList.visible = true;
					UIs.back_btn.addEventListener(TouchEvent.TOUCH_TAP,backPage);
					UIs.up_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsUp);
					UIs.down_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsDown);
					break;
				case "about":
					gotoAndStop(1);
					UIs.gotoAndStop(4);
					UIs.exAbout_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					UIs.backdoor_btn.addEventListener(TouchEvent.TOUCH_TAP,backdoor);
					break;
				case "output":
					gotoAndStop(1);
					UIs.gotoAndStop(5);
					UIs.exOut_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					UIs.id_txt.text = dataIO.levelList.list[1].level[currentLevel-1].id;
					UIs.str_txt.text = dataIO.getLevelStr(2,currentLevel);
					break;
				case "rank":
					gotoAndStop(1);
					UIs.gotoAndStop(3);
					UIs.exRank_btn.addEventListener(TouchEvent.TOUCH_TAP,exitRank);
					UIs.rank_txt.text = dataIO.getFullRank(currentList,currentLevel);
					UIs.title_txt.text = dataIO.levelList.list[currentList-1].level[currentLevel-1].name;
					break;
			}
		}
		public function refreshList(type:String):void
		{
			iconType = type;
			iconTotal = 0;
			var cy:int = 125;
			for (var i:int = 0; i<iconArray.length; i++)
			{
				if (iconList.contains(iconArray[i]))
				{
					iconList.removeChild(iconArray[i]);
				}
			}
			iconArray.length = 0;
			var tree:XMLList;
			switch(type)
			{
				case "list":
					tree = dataIO.getFullList();
					for each (var prop:XML in tree.list)
					{
						iconTotal++;
						var p:ListIcon = new ListIcon();
						p.label_txt.text = String(iconTotal);
						p.title_txt.text = prop.@title;
						p.list_btn.addEventListener(TouchEvent.TOUCH_TAP,startList);
						p.x = (480 - 400) / 2;
						p.y = cy;
						cy +=  85;
						iconArray.push(p);
						if (! iconList.contains(p))
						{
							iconList.addChild(p);
						}
					}
					break;
				case "level":
					tree = dataIO.getLevelList(currentList);
					for each (var prop2:XML in tree.level)
					{
						iconTotal++;
						var temp:levelIcon = new levelIcon();
						temp.high_txt.text = dataIO.getHighest(currentList,iconTotal);
						temp.label_txt.text = String(iconTotal);
						temp.title_txt.text = prop2.name;
						temp.rank_btn.addEventListener(TouchEvent.TOUCH_TAP,showRank);
						temp.level_btn.addEventListener(TouchEvent.TOUCH_TAP,startLevel);
						temp.high_txt.text = dataIO.getHighest(currentList,iconTotal);
						temp.x = (480 - 400) / 2;
						temp.y = cy;
						cy +=  85;
						iconArray.push(temp);
						if (! iconList.contains(temp))
						{
							iconList.addChild(temp);
						}
					}
					break;
				case "output":
					tree = dataIO.levelList.list.(@label == "custom")
					for each (var prop3:XML in tree.level)
					{
						iconTotal++;
						var te2:ListIcon = new ListIcon();
						te2.label_txt.text = String(iconTotal);
						te2.title_txt.text = prop3.name;
						te2.list_btn.addEventListener(TouchEvent.TOUCH_TAP,goOutput);
						te2.x = (480 - 400) / 2;
						te2.y = cy;
						cy +=  85;
						iconArray.push(te2);
						if (! iconList.contains(te2))
						{
							iconList.addChild(te2);
						}
					}
					break;
			}
			
		}
		public function iconsUp(event:TouchEvent):void
		{
			if (iconList.y < 0) iconList.y += 85;
		}
		public function iconsDown(event:TouchEvent):void
		{
			if (iconList.y + iconList.height > 570) iconList.y -= 85;
		}
		/*
		functions for buttons
		*/
		public function backPage(Event:TouchEvent)
		{
			switch(iconType)
			{
				case "list":
				case "output":
				returnHome();
				break;
				case "level":
				refreshList("list");
				break;
			}
		}
		public function returnHome(Event:TouchEvent = null)
		{
			targetPage = "menu";
			imgSet.loadBackground(imgSet.menuUrl);
		}
		public function goAbout(Event:TouchEvent)
		{
			targetPage = "about";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function returnLevel(Event:TouchEvent)
		{
			dataIO.addRankResult(scoreUI.name_txt.text,game.score,game.levData.id);
			refreshList("level");
			selectLevel();
		}
		public function selectLevel(event:TouchEvent = null)
		{
			targetPage = "select";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function selectOutputLevel(event:TouchEvent)
		{
			refreshList("output");
			targetPage = "selectOutput";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function goOutput(event:TouchEvent)
		{
			currentLevel = iconArray.indexOf(event.target.parent) + 1;
			targetPage = "output";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function showRank(event:TouchEvent)
		{
			currentLevel = iconArray.indexOf(event.target.parent) + 1;
			targetPage = "rank";
			switchPage();
		}
		public function exitRank(event:TouchEvent)
		{
			targetPage = "select";
			switchPage();
		}
		public function exitProgram(Event:TouchEvent)
		{
			dataIO.writeRanklist();
			NativeApplication.nativeApplication.exit();
		}
		public function endGame(Event:TouchEvent)
		{
			removeChild(parsys);
			removeChild(gameUI);
			game.stopMotion();
			selectLevel();
		}
		public function gameOver():void
		{
			gotoAndStop(4);
			removeChild(parsys);
			removeChild(gameUI);
			scoreUI.tfscore.text = String(game.score);
			scoreUI.tstats.text = game.gameAnalyze();
			scoreUI.next_btn.addEventListener(TouchEvent.TOUCH_TAP,recordName);
			game.stopMotion();
		}
		public function recordName(Event:TouchEvent)
		{
			scoreUI.gotoAndStop(2);
			scoreUI.name_txt.text = "player";
			scoreUI.backLevel_btn.addEventListener(TouchEvent.TOUCH_TAP,returnLevel);
			scoreUI.saveLevel_btn.addEventListener(TouchEvent.TOUCH_TAP,editLevel);
		}
		public function resumeGame(Event:TouchEvent = null)
		{
			game.addMotion();
			gameUI.gotoAndStop(1);
			gameUI.menu_btn.addEventListener(TouchEvent.TOUCH_TAP,pauseGame);
		}
		public function pauseGame(Event:TouchEvent)
		{
			game.stopMotion();
			gameUI.gotoAndStop(2);
			gameUI.resume_btn.addEventListener(TouchEvent.TOUCH_TAP,resumeGame);
			gameUI.end_btn.addEventListener(TouchEvent.TOUCH_TAP,endGame);
			gameUI.replay_btn.addEventListener(TouchEvent.TOUCH_TAP,replayLevel);
		}
		public function startList(event:TouchEvent)
		{
			currentList = iconArray.indexOf(event.target.parent) + 1;
			refreshList("level");
		}
		public function startLevel(event:TouchEvent)
		{
			parsys.resetStats();
			game.resetGameStats();
			parsys.clearMotion();
			currentLevel = iconArray.indexOf(event.target.parent) + 1;
			//trace("currentLevel",currentLevel);
			game.levData = dataIO.getLevel(currentList,currentLevel);
			game.loadLevelData();
			parsys.loadLocal(game.levData);
			targetPage = "start game";
			imgSet.loadBackground(game.levData.background);
		}
		public function replayLevel(event:TouchEvent)
		{
			parsys.resetStats();
			game.resetGameStats();
			game.loadLevelData();
			game.refreshDataBoard();
			resumeGame();
		}
		public function saveLevel(event:TouchEvent):void
		{
			if (savetime == 0)
			{
				moreopt_ui.visible = false;
				game.levData.title = title_txt.text;
				game.levData.time = int(moreopt_ui.time_txt.text);
			 	game.levData.background = moreopt_ui.bg_txt.text;
			 	game.levData.chickspeed = int(moreopt_ui.spd_txt.text);
				game.levData.sequence = parsys.saveLevel(game.levData.time);
				dataIO.addLevel(game.levData);
				refreshList("level");
				savetime++;
				selectLevel();
				parsys.exitEdit();
			}
		}
		public function backdoor(Event:TouchEvent)
		{
			var s:String = UIs.back_txt.text;
			var command:Array = s.split("#");
			switch (command[0])
			{
				case "clr" :
					dataIO.clearLevelResult(int(command[1]));
					break;
				case "del" :
					if (dataIO.deleteLevel(int(command[1])))
					{
						refreshList("level");
					}
					break;
				case "tl" :
					//trace(dataIO.leveldata);
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
			moreopt_ui.lock.addEventListener(TouchEvent.TOUCH_TAP,toggleLock);
			more_btn.addEventListener(TouchEvent.TOUCH_TAP,toggleMoreopt);
			title_txt.text = game.levData.title;
			moreopt_ui.time_txt.text = game.levData.time;
			moreopt_ui.bg_txt.text = game.levData.background;
			moreopt_ui.spd_txt.text = game.levData.chickspeed;
			moreopt_ui.visible = false;
			this.addChild(moreopt_ui);
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
				moreopt_ui.lock.gotoAndStop(2);
			}
			else
			{
				moreopt_ui.lock.gotoAndStop(1);
			}
		}
		public function toggleMoreopt(event:TouchEvent):void
		{
			moreopt_ui.visible = ! moreopt_ui.visible;
		}
		public function pageUp(Event:TouchEvent):void
		{
			if(endSec+2 <= int(moreopt_ui.time_txt.text))
			{
				parsys.switchPage(1);
				endSec += 2;
				timerange.text = stomin(endSec-2) + "-" + stomin(endSec);
			}
		}
		public function pageDown(Event:TouchEvent):void
		{
			if(endSec-2 > 0)
			{
				parsys.switchPage(-1);
				endSec -= 2;
				timerange.text = stomin(endSec-2) + "-" + stomin(endSec);
			}
		}
		public function initGadgets():void 
		{
			gadgets["plusx"] = new plusx();
			gadgets["plusx"].name = "plusx";
			gadgets["dectime"] = new dectime();
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
	}

}