////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{
	import flash.utils.Dictionary;
	
	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class MetadataInfo
	{
		private var _dic:Dictionary;
		
		public var name:String;
		public var args:Vector.<MetadataArgInfo>;
		
		public function MetadataInfo()
		{
			_dic = new Dictionary();
			args = new <MetadataArgInfo>[];
		}
		
		public function addArgKV(key:String, value:String):MetadataArgInfo
		{
			var result:MetadataArgInfo = _dic[key];
			if (!result)
			{
				result = _dic[key] = new MetadataArgInfo;
				args.push(result);
			}
			result.key = key;
			result.value = value;
			return result;
		}
		
		public function addArg(arg:MetadataArgInfo):void
		{
			if (_dic[arg.key] == null)
				args.push(arg);
			_dic[arg.key] = args;
		}
		
		public function getArg(key:String):MetadataArgInfo
		{
			return _dic[key];
		}
	}
}