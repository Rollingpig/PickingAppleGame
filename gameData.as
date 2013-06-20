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
			file = file.resolvePath("rank.txt");
			try
			{
				fileStream.open(file, FileMode.READ);
				ranklist = fileStream.readObject();
				fileStream.close();
			}
			catch (error:IOError)
			{
				trace("not found");
				ranklist.push(new Array,new Array,new Array,new Array,new Array);
			}
		}
		public function getFullRank(level:int = 1):String
		{
			var temp:String = "";
			if (ranklist[level].length !== 0)
			{
				for (var i=0; i<= ranklist[level].length - 1; i++)
				{
					temp = temp + String(i+1) + ".  " + ranklist[level][i].name + "  " + String(ranklist[level][i].score) + "\r";
				}
			}
			return temp;
		}
		public function getHighest(level:int = 1):String
		{
			var temp:String = "";
			if (ranklist[level].length !== 0)
			{
				temp = String(ranklist[level][0].score);
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
		public function addRankResult(new_name:String,new_score:int,level:int = 1):void
		{
			trace(ranklist[level]);
			ranklist[level].push({name:new_name,score:new_score});
			ranklist[level].sortOn("score",Array.DESCENDING | Array.NUMERIC);
			if (ranklist[level].length > 25)
			{
				ranklist[level].length = 25;
			}
		}

	}

}