package {

	import flash.events.*;
	import flash.display.*;
	import flash.utils.*;
	import flash.text.*;

	public class fpsCatcher extends Sprite {
		private var numFrames:Number = 0;
		private var interval:Number = 10;
		private var ii:int = 0;
		private var total:Number = 0;
		private var startTime:Number;
		private var fpsText;
		private var my_fmt:TextFormat;
		
		public function fpsCatcher() {
			startTime = getTimer();
			
			my_fmt = new TextFormat();
			my_fmt.bold = true;
			my_fmt.size = 35;
			my_fmt.color = 0x66FFFF;

			fpsText = new TextField();
			fpsText.autoSize = "left";
			fpsText.text = "loading";
			addChild(fpsText);

			fpsText.defaultTextFormat = my_fmt;
			fpsText.selectable = false;
			this.addEventListener(Event.ADDED, onAdded);
		}
		private function onAdded(event:Event) {
			this.stage.addEventListener(Event.ENTER_FRAME, update, false, 0);
		}
		private function update(event:Event) {
			if (++numFrames == interval) {
				var now:Number = getTimer();
				var elapsedSeconds:Number = (now - startTime) / 1000;
				var actualFPS:Number = numFrames / elapsedSeconds;
				total += actualFPS;
				ii++;
				if(total>500){
					//trace((total/ii).toFixed(2));
					total = actualFPS;
					ii = 1;
				}
				fpsText.text = (actualFPS.toFixed(2));
				startTime = now;
				numFrames = 0;
			}
		}


	}
}