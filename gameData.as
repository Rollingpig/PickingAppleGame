package 
{
	import flash.filesystem.*;
	import flash.errors.IOError;
	public class gameData
	{
		private var file:File = File.applicationStorageDirectory;
		private var fileStream:FileStream = new FileStream();
		public var ranklist:Array = new Array();

		public function gameData()
		{
			file = file.resolvePath("highscore.txt");
			try
			{
				fileStream.open(file, FileMode.READ);
				ranklist = fileStream.readObject();
				fileStream.close();
			}
			catch (error:IOError)
			{
				trace("not found");
			}
		}
		public function getFullRank():String
		{
			var temp:String = "";
			if (ranklist.length !== 0)
			{
				for (var i=0; i<= ranklist.length - 1; i++)
				{
					temp = temp + String(i+1) + ".  " + ranklist[i].name + "  " + String(ranklist[i].score) + "\r";
				}
			}
			return temp;
		}
		public function getHighest():String
		{
			var temp:String = "";
			if (ranklist.length !== 0)
			{
				temp = ranklist[0].name + "\r" + String(ranklist[0].score);
			}
			else
			{
				temp = "None";
			}
			return temp;
		}
		public function writeRanklist():void
		{
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(ranklist);
			fileStream.close();
		}
		public function addRankResult(new_name:String,new_score:int):void
		{
			ranklist.push({name:new_name,score:new_score});
			ranklist.sortOn("score",Array.DESCENDING | Array.NUMERIC);
			if (ranklist.length > 15)
			{
				ranklist.length = 15;
			}
		}

	}

}