package 
{
	import flash.filesystem.*;
	import flash.errors.IOError;
	public class gameData
	{
		private var rankfile:File = File.applicationStorageDirectory;
		private var levelfile:File = File.documentsDirectory;
		private var originLevel:File = File.applicationDirectory;

		private var fileStream:FileStream = new FileStream();
		public var ranklist:Array = new Array();
		public var leveldata:XML;

		public function gameData()
		{
			rankfile = rankfile.resolvePath("rank.txt");
			levelfile = levelfile.resolvePath("pickapple/levels.xml");
			originLevel = originLevel.resolvePath("levels.xml");
			try
			{
				fileStream.open(rankfile, FileMode.READ);
				ranklist = fileStream.readObject();
				fileStream.close();
			}
			catch (error:IOError)
			{
				trace("Data not found");
				ranklist.push(new Array);
			}
			try
			{
				originLevel.copyTo(levelfile,false);
			}
			catch (error:IOError)
			{
				trace("Levelfile already exsists.");
			}
			fileStream.open(levelfile, FileMode.READ);
			leveldata = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
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
			if(level > ranklist.length - 1){
				ranklist.push(new Array);
			}
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
			fileStream.open(rankfile, FileMode.WRITE);
			fileStream.writeObject(ranklist);
			fileStream.close();
			fileStream.open(levelfile, FileMode.WRITE);
			fileStream.writeUTFBytes(String(leveldata));
			fileStream.close();
		}
		public function addRankResult(new_name:String,new_score:int,level:int = 1):void
		{
			//trace(ranklist[level]);
			ranklist[level].push({name:new_name,score:new_score});
			ranklist[level].sortOn("score",Array.DESCENDING | Array.NUMERIC);
			if (ranklist[level].length > 25)
			{
				ranklist[level].length = 25;
			}
		}
		public function clearLevelResult(level:int):void
		{
			ranklist[level].length = 0;
		}
		public function addLevel(newtitle:String,newpath:String,newtime:int,speed:int):void
		{
			var newlevel:XML =  
			    <level label="0">
					<random>false</random>
					<title>untitle</title>
					<description>none</description>
					<time>10</time>
					<chickspeed>10</chickspeed>
					<path>newpath</path>
				</level>;
			leveldata.@total = int(leveldata.@total) + 1;
			newlevel.path = newpath;
			newlevel.time = newtime;
			newlevel.title = newtitle;
			newlevel.chickspeed = speed;
			newlevel.@label = leveldata.@total;
			leveldata.appendChild(newlevel);
			trace(leveldata);
			ranklist.push(new Array);
		}
		public function deleteLevel(tlabel:int):Boolean
		{
			var file:File = File.documentsDirectory;
			file = file.resolvePath(leveldata.level.(@label == String(tlabel)).path);
			delete leveldata.level.(@label == String(tlabel))[0];
			for each (var lev:XML in leveldata.level)
			{
				if(int(lev.@label)>tlabel)
				{
					lev.@label = int(lev.@label)-1;
				}
			}
			ranklist.splice(tlabel,1);
			leveldata.@total = int(leveldata.@total) - 1;
			try
			{
				file.deleteFile();
			}
			catch (error:IOError)
			{
				//none
			}
			trace("done")
			return true;
		}
	}

}