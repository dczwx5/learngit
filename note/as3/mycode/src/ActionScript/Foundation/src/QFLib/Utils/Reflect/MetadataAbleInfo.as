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
	public class MetadataAbleInfo implements IMetadataAble
	{
		protected var _metadatas:Vector.<MetadataInfo>;
		private var _metadatasDic_key_name:Dictionary;
		protected var _memberType:int;
		
		public function MetadataAbleInfo()
		{
			_metadatasDic_key_name = new Dictionary();
		}
		
		/**@see com.qifun.common.reflect.EnumMemberType*/
		public function get memberType():int
		{
			return _memberType;
		}
		
		public function get metadatas():Vector.<MetadataInfo>
		{
			return _metadatas;
		}
		
		public function set metadatas(value:Vector.<MetadataInfo>):void
		{
			_metadatas = value;
		}
		
		public function readMetadataByXmlList(node:XMLList):void
		{
			_metadatas = ReflectUtil.Reflect_ns::readMetadataInfoArrByXmlList(node, _metadatas);
			for each (var data:MetadataInfo in _metadatas) 
				addMetadata(data);
		}
		
		public function addMetadata(data:MetadataInfo):void
		{
			if (!data)
				return;
			_metadatasDic_key_name[data.name] = data;
		}
		
		public function getMetadata(name:String):MetadataInfo
		{
			return _metadatasDic_key_name[name];
		}
	}
}