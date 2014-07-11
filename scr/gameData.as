package 
{
	import flash.filesystem.*;
	import flash.errors.IOError;
	import MD5;
	
	public class gameData
	{
		private var rankfile:File = File.documentsDirectory;
		private var levelfile:File = File.documentsDirectory;
		
		private var levelData:File = File.documentsDirectory;
		private var originLevel:File = File.applicationDirectory;
		
		private var fileStream:FileStream = new FileStream();
		public var ranklist:Object = new Object();
		public var levelList:XML;
		private var md5:MD5 = new MD5();

		public function gameData()
		{
			rankfile = rankfile.resolvePath("pickapple/ranks.txt");
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
				trace("Rank data not found");
			}
			try
			{
				originLevel.copyTo(levelfile,false);
				trace("Creating new Levelfile.");
			}
			catch (error:IOError)
			{
				trace("Levelfile already exsists.");
			}
			fileStream.open(levelfile, FileMode.READ);
			levelList = XML(fileStream.readUTFBytes(fileStream.bytesAvailable));
			fileStream.close();
		}
		public function getLevelList(n:int = 1):XMLList
		{
			var str:String = levelList.list[n-1].@label;
			var t:XMLList = levelList.list.(@label == str);
			return t;
		}
		public function getFullList():XMLList
		{
			var t:XMLList = levelList.(@label == "1");
			return t;
		}
		public function getLevelStr(tlist,tlevel:int):String
		{
			var str:String = "";
			var path:String = levelList.list[tlist-1].level[tlevel-1].path;
			if (path.indexOf("native/") == 0)
			{
				levelData = File.applicationDirectory.resolvePath(path);
			}
			else
			{
				levelData = File.documentsDirectory.resolvePath(path);
				//path has included "pickapple/" prefix;
			}
			try
			{
				fileStream.open(levelData, FileMode.READ);
				str = fileStream.readUTFBytes(fileStream.bytesAvailable);
				fileStream.close();
			}
			catch (error:IOError)
			{
				trace("can't load level files");
			}
			return str;
		}
		public function getLevel(tlist,tlevel:int):Object
		{
			var idCode:String = levelList.list[tlist-1].level[tlevel-1].id;
			var container:Object = new Object();
			var str:String = getLevelStr(tlist,tlevel);
			container = levelDataHandler(str);
			if(idCode == "")
			{
				idCode = md5.calculate(str);
				trace(idCode);
			}
			container["id"] = idCode;
			return container;
		}
		private function levelDataHandler(str:String):Object
		{
			var parStr:Array = new Array();
			var parArr:Array = new Array(); 
			var temp:Array = new Array();
			var beginint:int = str.indexOf("[",0);
			var endint:int = str.indexOf("]",beginint);
			var container:Object = new Object();
			while (beginint !== -1)
			{
				temp = str.slice(beginint+1,endint).split(":");
				if(temp[0] !== "sequence")
				{
					//trace(temp[0],temp[1]);
					container[temp[0] + ""] = temp[1];
				}
				else
				{
					//trace(temp[1].slice(1,temp[1].length-1));
					parStr = temp[1].slice(1,temp[1].length-1).split(")(");
				}
				beginint = str.indexOf("[",endint);
				endint = str.indexOf("]",beginint);
			}
			for(var i:int = 0;i< parStr.length;i++)
			{
				//trace(par[i]);
				temp = parStr[i].split(",");
				var pa:particleData = new particleData();
				pa.type = temp[0];
				pa.targetX = int(temp[1]);
				pa.vy = int(temp[2]);
				pa.dropFrame = int(temp[3]);
				pa.reachFrame = int(temp[4]);
				parArr.push(pa);
			}
			container["sequence"] = parArr;
			return container;
		}
		public function addLevel(newlevel:Object):void
		{
			var levelStr:String = "";
			var idCode:String = "";
			levelStr = LevelTxt(newlevel);
			idCode = md5.calculate(levelStr);
			var path:String = "pickapple/" + idCode + ".txt";
			levelData = File.documentsDirectory.resolvePath(path);
			fileStream.open(levelData, FileMode.WRITE);
			fileStream.writeUTF(levelStr);
			fileStream.close();
			var lev:XML =  
				<level>
					<name>name</name>
					<path>path</path>
					<id>id</id>
				</level>;
			lev.path = path;
			lev.name = newlevel.title;
			lev.id = idCode;
			levelList.list.(@label == "custom").appendChild(lev);
			ranklist[idCode] = new Array();
			//trace("level added");
			//trace(levelList);
		}
		private function LevelTxt(lev:Object):String
		{
			var levStr:String = "############This is level data.Once modified, MD5 test will fail.############\r";
			levStr += "[title:" + lev.title+"][time:" + lev.time + "][chickspeed:" + lev.chickspeed;
			levStr += "][background:" + lev.background + "][sequence:";
			for(var i:int = 0;i< lev.sequence.length;i++)
			{
				var p:Object = lev.sequence[i];
				levStr += "(" + p.type + "," + p.targetX + "," + p.vy + "," + p.dropFrame + "," + p.reachFrame + ")";
			}
			levStr += "]"
			return levStr;
		}
		public function getFullRank(tlist,tlevel:int):String
		{
			var targetID:String = levelList.list[tlist-1].level[tlevel-1].id;
			var temp:String = "";
			if (targetID !== "" && ranklist[targetID].length !== 0)
			{
				for (var i = 0; i < ranklist[targetID].length; i++)
				{
					temp = temp + String(i+1) + ".  " + ranklist[targetID][i].name + "  " + String(ranklist[targetID][i].score) + "\r";
				}
			}
			return temp;
		}
		public function getHighest(tlist,tlevel:int):String
		{
			var targetID:String = levelList.list[tlist-1].level[tlevel-1].id;
			var temp:String = "";
			if(! ranklist.hasOwnProperty(targetID))
			{
				ranklist[targetID] = new Array();
			}
			//trace(ranklist[targetID].length);
			if (ranklist[targetID].length !== 0)
			{
				temp = String(ranklist[targetID][0].score);
				//trace(ranklist[targetID]);
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
			fileStream.writeUTFBytes(String(levelList));
			fileStream.close();
		}
		public function addRankResult(player:String,nscore:int,targetID:String = ""):void
		{
			if(targetID !== "")
			{
				ranklist[targetID].push({name:player,score:nscore});
				//trace(ranklist[targetID]);
				//trace(ranklist[targetID + ""]);
				ranklist[targetID].sortOn("score",Array.DESCENDING | Array.NUMERIC);
				if (ranklist[targetID].length > 25)
				{
					ranklist[targetID].length = 25;
				}
				//trace(ranklist[targetID].length);
			}
		}
		public function clearLevelResult(level:int):void
		{
			//ranklist[level].length = 0;
		}
		public function deleteLevel(tlabel:int):Boolean
		{
			/*
			var file:File = File.documentsDirectory;
			file = file.resolvePath(levelList.level.(@label == String(tlabel)).path);
			delete levelList.level.(@label == String(tlabel))[0];
			for each (var lev:XML in levelList.level)
			{
				if(int(lev.@label)>tlabel)
				{
					lev.@label = int(lev.@label)-1;
				}
			}
			ranklist.splice(tlabel,1);
			try
			{
				file.deleteFile();
			}
			catch (error:IOError)
			{
				//none
			}
			trace(levelList);
			*/
			return true;
		}
	}

}