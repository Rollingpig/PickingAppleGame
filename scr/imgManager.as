package  {
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;
	
	public class imgManager {
		
		private var background:MovieClip;
		private var main:MovieClip;
		
		private var loader:Loader = new Loader();
		
		private var current_bg:Bitmap;
		
		public const menuUrl:String = "native/menu.png";
		public var selectUrl:String = "native/level.png";
		private var currentUrl:String = "";
		
		public function imgManager(mainClip,target:MovieClip):void
		{
			background = target;
			main = mainClip;
		}
		private function ioHandler(event:Event):void
		{
			currentUrl = selectUrl;
			main.switchPage();
		}
		public function loadBackground(url:String = ""):void
		{
			if (url !== "" && url !== currentUrl)
			{
				currentUrl = url;
				loader.unload();
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,loadbgComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,ioHandler);
				loader.load(new URLRequest(currentUrl));
			}else{
				main.switchPage();
			}
		}
		private function loadbgComplete(event:Event):void
		{
			var data:Bitmap = loader.content as Bitmap;
			var temp:Bitmap = new Bitmap(data.bitmapData);
			loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadbgComplete);
			replace(temp);
		}
		private function replace(newpic:Bitmap):void
		{
			background.addChild(newpic);
			if (current_bg !== null) background.removeChild(current_bg);
			current_bg = newpic;
			main.switchPage();
		}
	}
	
}
