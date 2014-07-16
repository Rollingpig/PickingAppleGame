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
		
		public var dataIO:gameData;
		
		public var currentLevel:int = 1;
		public var currentList:int = 1;
		
		public var iconArray:Array = new Array  ;
		public var iconList:Sprite = new Sprite();
		private var iconY:int = 0;
		private var iconmask:Shape = new Shape();
		private var iconTotal:int = 0;
		private var iconType:String = "list";

		private var imgSet:imgManager;
		private var targetPage:String = "";
		
		private var endSec:int = 2;
		private var pageSig:int = 0;

		public function pickApple()
		{
			dataIO = new gameData(this);
			//initailize particle system, add it to the stage
			parsys = new particleSystem(this);
			addChild(parsys);
			parsys.initParticle(papple);
			//innitialize game
			game = new gameControl(this);
			//initialize small objects in the stage
			initGadgets();
			//initailize background Loader
			imgSet = new imgManager(this,bgLayer);
			//set touch mode
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			//Layout
			stop();
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
					UIs.gotoAndStop("menu");
					UIs.selectPlay_btn.addEventListener(TouchEvent.TOUCH_TAP,goPages);
					UIs.selectOutput_btn.addEventListener(TouchEvent.TOUCH_TAP,goPages);
					UIs.selectEdit_btn.addEventListener(TouchEvent.TOUCH_TAP,goPages);
					UIs.about_btn.addEventListener(TouchEvent.TOUCH_TAP,goPages);
					UIs.update_btn.addEventListener(TouchEvent.TOUCH_TAP,goPages);
					UIs.exit_btn.addEventListener(TouchEvent.TOUCH_TAP,exitProgram);
					break;
				case "start game":
					gotoAndStop(3);
					parsys.hitZone = Object(root).chicken.hitBasket;
					addChild(parsys);
					addChild(gameUI);
					game.refreshDataBoard();
					resumeGame();
					break;
				case "selectPlay":
					gotoAndStop(1);
					UIs.gotoAndStop("select");
					refreshList("play_list");
					UIs.back_btn.addEventListener(TouchEvent.TOUCH_TAP,backPage);
					UIs.up_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsUp);
					UIs.down_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsDown);
					break;
				case "selectOutput":
					gotoAndStop(1);
					UIs.gotoAndStop("select");
					refreshList("output_level");
					UIs.back_btn.addEventListener(TouchEvent.TOUCH_TAP,backPage);
					UIs.up_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsUp);
					UIs.down_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsDown);
					break;
				case "selectEdit":
					gotoAndStop(1);
					UIs.gotoAndStop("selectEdit");
					refreshList("edit_list");
					UIs.back_btn.addEventListener(TouchEvent.TOUCH_TAP,backPage);
					UIs.up_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsUp);
					UIs.down_btn.addEventListener(TouchEvent.TOUCH_TAP,iconsDown);
					UIs.blank_btn.addEventListener(TouchEvent.TOUCH_TAP,startBlank);
					break;
				case "about":
					gotoAndStop(1);
					UIs.gotoAndStop("about");
					UIs.exAbout_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					break;
				case "output":
					gotoAndStop(1);
					UIs.gotoAndStop("output");
					UIs.exOut_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					UIs.id_txt.text = dataIO.levelList.list[1].level[currentLevel-1].id;
					UIs.str_txt.text = dataIO.getLevelStr(2,currentLevel);
					break;
				case "update":
					gotoAndStop(1);
					UIs.gotoAndStop("update");
					UIs.startUpdate_btn.addEventListener(TouchEvent.TOUCH_TAP,startUpdate);
					UIs.exUp_btn.addEventListener(TouchEvent.TOUCH_TAP,returnHome);
					break;
				case "rank":
					gotoAndStop(1);
					UIs.gotoAndStop("rank");
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
			iconY = 0;
			for (var i:int = 0; i<iconArray.length; i++)
			{
				if (iconList.contains(iconArray[i]))
					iconList.removeChild(iconArray[i]);
			}
			iconArray.length = 0;
			iconmask.graphics.clear();
			iconmask.graphics.beginFill(0x000000,1);			
			var tree:XMLList;
			switch(type)
			{
				case "play_list":
					tree = dataIO.getFullList();
					iconmask.graphics.drawRect((480 - 400) / 2,0,400,85 * 7);
					iconmask.y = 125;
					iconList.y = 125;
					for each (var prop:XML in tree.list)
					{
						iconTotal++;
						var p:ListIcon = new ListIcon();
						p.label_txt.text = String(iconTotal);
						p.title_txt.text = prop.@title;
						p.list_btn.addEventListener(TouchEvent.TOUCH_TAP,listBtnHandler);
						addIconToList(p);
					}
					break;
				case "play_level":
					tree = dataIO.getLevelList(currentList);
					iconmask.graphics.drawRect((480 - 400) / 2,0,400,85 * 7);
					iconmask.y = 125;
					iconList.y = 125;
					for each (var prop2:XML in tree.level)
					{
						iconTotal++;
						var temp:levelIcon = new levelIcon();
						temp.high_txt.text = dataIO.getHighest(currentList,iconTotal);
						temp.label_txt.text = String(iconTotal);
						temp.title_txt.text = prop2.name;
						temp.rank_btn.addEventListener(TouchEvent.TOUCH_TAP,showRank);
						temp.level_btn.addEventListener(TouchEvent.TOUCH_TAP,listBtnHandler);
						temp.high_txt.text = dataIO.getHighest(currentList,iconTotal);
						addIconToList(temp);
					}
					if(iconTotal == 0)
					{
						var temp7:ListIcon = new ListIcon();
						temp7.title_txt.text = "暂无关卡";
						temp7.label_txt.text = "";
						addIconToList(temp7);
					}
					break;
				case "output_level":
					tree = dataIO.levelList.list.(@label == "custom")
					iconmask.graphics.drawRect((480 - 400) / 2,0,400,85 * 7);
					iconmask.y = 125;
					iconList.y = 125;
					for each (var prop3:XML in tree.level)
					{
						iconTotal++;
						var te2:ListIcon = new ListIcon();
						te2.label_txt.text = String(iconTotal);
						te2.title_txt.text = prop3.name;
						te2.list_btn.addEventListener(TouchEvent.TOUCH_TAP,listBtnHandler);
						addIconToList(te2);
					}
					break;
				case "edit_list":
					iconList.y = 125 + 135;
					tree = dataIO.getFullList();
					iconmask.graphics.drawRect((480 - 400) / 2,0,400,85 * 5);
					iconmask.y = 125+135;
					for each (var prop5:XML in tree.list)
					{
						iconTotal++;
						var temp5:ListIcon = new ListIcon();
						temp5.label_txt.text = String(iconTotal);
						temp5.title_txt.text = prop5.@title;
						temp5.list_btn.addEventListener(TouchEvent.TOUCH_TAP,listBtnHandler);
						addIconToList(temp5);
					}
					break;
				case "edit_level":
					iconList.y = 125 + 135;
					iconmask.graphics.drawRect((480 - 400) / 2,0,400,85 * 5);
					iconmask.y = 125+135;
					tree = dataIO.getLevelList(currentList);
					for each (var prop4:XML in tree.level)
					{
						iconTotal++;
						var temp4:ListIcon = new ListIcon();
						temp4.label_txt.text = String(iconTotal);
						temp4.title_txt.text = prop4.name;
						temp4.list_btn.addEventListener(TouchEvent.TOUCH_TAP,listBtnHandler);
						addIconToList(temp4);
					}
					if(iconTotal == 0)
					{
						var temp8:ListIcon = new ListIcon();
						temp8.title_txt.text = "暂无关卡";
						temp8.label_txt.text = "";
						addIconToList(temp8);
					}
					break;
			}
			iconmask.graphics.endFill();
			iconList.mask = iconmask;
			UIs.addChild(iconmask);
			UIs.addChild(iconList);
			iconList.visible = true;
		}
		private function addIconToList(piece:MovieClip):void
		{
			piece.x = (480 - 400) / 2;
			piece.y = iconY;
			iconY +=  85;
			iconArray.push(piece);
			if (! iconList.contains(piece))
			{
				iconList.addChild(piece);
			}
		}
		public function iconsUp(event:TouchEvent):void
		{
			if (iconList.y < iconmask.y) iconList.y += 85;
		}
		public function iconsDown(event:TouchEvent):void
		{
			//trace(iconList.height);
			if (iconList.y + iconList.height > iconmask.height + iconmask.y) iconList.y -= 85;
		}
		/*
		functions for buttons
		*/
		public function backPage(Event:TouchEvent)
		{
			switch(iconType)
			{
				case "play_list":
				case "edit_list":
				case "output_level":
					returnHome();
					break;
				case "play_level":
					refreshList("play_list");
					break;
				case "edit_level":
					refreshList("edit_list");
					break;
			}
		}
		public function returnHome(Event:TouchEvent = null)
		{
			targetPage = "menu";
			imgSet.loadBackground(imgSet.menuUrl);
		}
		public function returnLevel(Event:TouchEvent)
		{
			dataIO.addRankResult(scoreUI.name_txt.text,game.score,game.levData.id);
			targetPage = "selectPlay";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function goPages(event:TouchEvent)
		{
			targetPage = event.target.name.split("_")[0];
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function startBlank(Event:TouchEvent)
		{
			game.fillBlankLevelData();
			editLevel();
		}
		public function startUpdate(Event:TouchEvent)
		{
			dataIO.updateProcess();
			UIs.startUpdate_btn.removeEventListener(TouchEvent.TOUCH_TAP,startUpdate);
			UIs.feedback_txt.text = "正在连接..."
		}
		public function listBtnHandler(event:TouchEvent)
		{
			switch(iconType)
			{
				case "play_list":
					currentList = iconArray.indexOf(event.target.parent) + 1;
					refreshList("play_level");
					break;
				case "play_level":
					parsys.resetStats();
					parsys.clearMotion();
					game.resetGameStats();
					currentLevel = iconArray.indexOf(event.target.parent) + 1;
					game.levData = dataIO.getLevel(currentList,currentLevel);
					game.loadLevelData();
					parsys.loadLocal(game.levData);
					targetPage = "start game";
					imgSet.loadBackground(game.levData.background);
					break;
				case "edit_list":
					parsys.clearMotion();
					currentList = iconArray.indexOf(event.target.parent) + 1;
					refreshList("edit_level");
					break;
				case "edit_level":
					currentLevel = iconArray.indexOf(event.target.parent) + 1;
					game.levData = dataIO.getLevel(currentList,currentLevel);
					parsys.loadLocal(game.levData);
					editLevel();
					break;
				case "output_level":
					currentLevel = iconArray.indexOf(event.target.parent) + 1;
					targetPage = "output";
					switchPage();
					break;
			}
		}
		public function showRank(event:TouchEvent)
		{
			currentLevel = iconArray.indexOf(event.target.parent) + 1;
			targetPage = "rank";
			switchPage();
		}
		public function exitRank(event:TouchEvent)
		{
			targetPage = "selectPlay";
			switchPage();
		}
		public function exitProgram(Event:TouchEvent)
		{
			dataIO.writeRanklist();
			NativeApplication.nativeApplication.exit();
		}
		public function haltGame(Event:TouchEvent)
		{
			endGame();
			targetPage = "selectPlay";
			imgSet.loadBackground(imgSet.selectUrl);
		}
		public function endGame():void
		{
			game.stopMotion();
			removeChild(parsys);
			removeChild(gameUI);
		}
		public function gameOver():void
		{
			endGame();
			gotoAndStop(4);
			scoreUI.tfscore.text = String(game.score);
			scoreUI.tstats.text = game.gameAnalyze();
			scoreUI.next_btn.addEventListener(TouchEvent.TOUCH_TAP,recordName);
		}
		public function recordName(Event:TouchEvent)
		{
			scoreUI.gotoAndStop(2);
			scoreUI.name_txt.text = "player";
			scoreUI.backLevel_btn.addEventListener(TouchEvent.TOUCH_TAP,returnLevel);
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
			gameUI.end_btn.addEventListener(TouchEvent.TOUCH_TAP,haltGame);
			gameUI.replay_btn.addEventListener(TouchEvent.TOUCH_TAP,replayLevel);
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
			moreopt_ui.visible = false;
			game.levData.title = title_txt.text;
			game.levData.time = int(moreopt_ui.time_txt.text);
			game.levData.background = moreopt_ui.bg_txt.text;
			game.levData.chickspeed = int(moreopt_ui.spd_txt.text);
			game.levData.sequence = parsys.saveLevel(game.levData.time);
			dataIO.addLevel(game.levData);
			returnHome();
			parsys.exitEdit();
		}
		public function editLevel(Event:TouchEvent = null):void
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
			returnHome();
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