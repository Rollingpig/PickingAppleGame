package  {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	
	public class bgDisplay {
		
		private var background:MovieClip;
		private var main:MovieClip;
		
		private var loader:Loader = new Loader();
		
		private var current:Bitmap;
		private var menu:Bitmap;
		private var select:Bitmap;
		private var level:Bitmap;
		
		public var menuURL:URLRequest = new URLRequest("menu.png");
		public var selectURL:URLRequest = new URLRequest("level.png");
		public var levelURL:URLRequest;
		
		public function bgDisplay(mainscr,target:MovieClip):void
		{
			background = target;
			main = mainscr;
		}
		private function ioHandler(event:Event):void
		{
			if (current !== null) background.removeChild(current);
			current = null;
			main.postLoad();
		}
		private function replace(newpic:Bitmap):void
		{
			background.addChild(newpic);
			if (current !== null) background.removeChild(current);
			current = newpic;
			main.postLoad();
		}
		public function loadMenu():void
		{
			if (menu == null)
			{
				loader.unload();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,menu_complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
				loader.load(menuURL);
			}else{
				replace(menu);
			}
		}
		private function menu_complete(event:Event):void
		{
			var data:Bitmap = loader.content as Bitmap;
			menu = new Bitmap(data.bitmapData);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, menu_complete);
			replace(menu);
		}
		public function loadSelect():void
		{
			if (select == null)
			{
				loader.unload();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,select_complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
				loader.load(selectURL);
			}else{
				replace(select);
			}
		}
		private function select_complete(event:Event):void
		{
			var data:Bitmap = loader.content as Bitmap;
			select = new Bitmap(data.bitmapData);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, select_complete);
			replace(select);
		}
		public function loadLevel(url:String):void
		{
			if (true)
			{
				loader.unload();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,level_complete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
				loader.load(new URLRequest(url));
			}else{
				replace(level);
			}
		}
		private function level_complete(event:Event):void
		{
			var data:Bitmap = loader.content as Bitmap;
			level = new Bitmap(data.bitmapData);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,level_complete);
			replace(level);
		}
	}
	
}
