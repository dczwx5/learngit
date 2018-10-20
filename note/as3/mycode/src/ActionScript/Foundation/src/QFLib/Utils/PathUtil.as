////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
import QFLib.Utils.StringUtil;

/**
	 * path处理通用方法
	 * @author tanjiazhang
	 * 
	 */	
	public class PathUtil
	{
		public static function getPurFileName(path:String):String
		{
			var arr:Array = path.split("/");
			return arr[arr.length - 1].split(".")[0];
		}
		
		public static function getExtension(path:String):String
		{
			var arr:Array = path.split("/");
			return arr[arr.length - 1].split(".")[1];
		}
		
		public static function getDir(path:String):String
		{
			if(path.substr(path.length-1, 1)=="/")
			{
				return path;
			}
			return path.substring(0, path.lastIndexOf("/")+1);
		}
		
		public static function setupPath(path:String):String
		{
			if(path.charAt(path.length-1)!="/")
			{
				return path + "/";
			}
			return path;
		}
		
		public static function replaceAllSeparator(path:String, replcSymbal:String):String
		{
//			while(path.indexOf("\\") != -1)
//			{
//				path = path.replace("\\", replcSymbal);
//			}
//			while(path.indexOf("/") != -1)
//			{
//				path = path.replace("/", replcSymbal);
//			}
			path = path.replace(/\\/g, replcSymbal);
			path = path.replace(/\//g, replcSymbal);
			return path;
		}
		
		public static function replaceAllDot(path:String, newDotSymbal:String):String
		{
			path = path.replace(/\./g, newDotSymbal);
			return path;
		}
		
		public static function findFirstSeparatorIndex(path:String):int
		{
			var index:int = path.indexOf("\\");
			if(index==-1)
			{
				index = path.indexOf("/");
			}
			return index;
		}
		
		/**
		 *修改路径所指文件的后缀，可以指定为无后缀，如 xxx/xx/er.atf - xxx/xx/er 
		 * @param path
		 * @param newExt
		 * @return 
		 * 
		 */		
		public static function modifyExtendsion(path:String, newExt:String):String
		{
			var index:int = path.lastIndexOf(".");
			if(index!=-1)
			{
				if(StringUtil.isNullOrEmpty(newExt))
				{
					path = path.substring(0, index);
				}
				else
				{
					path = path.substring(0, index+1)+newExt;
				}
			}
			else if(!StringUtil.isNullOrEmpty(newExt))
			{
				path += "."+newExt;
			}
			return path;
		}
		
		public static function removeExtendsion(path:String):String
		{
			var index:int = path.lastIndexOf(".");
			if (index!=-1)
			{
				path = path.substring(0, index);
			}
			
			return path;
		}

		public static function appendExtendsion(path:String, newExt:String):String
		{
			if(!StringUtil.isNullOrEmpty(newExt))
			{
				path += "." + newExt;
			}
			return path;
		}
		
		public static function getVUrl(url:String):String
		{
			url = url.replace(/\\/g, "/");
			return url;
		}
		
		public static function getUrl(url:String):String
		{
			var arr: Array = url.split(/[/\\]/);
			url = arr.join("/");
			return url;
		}
	}
}