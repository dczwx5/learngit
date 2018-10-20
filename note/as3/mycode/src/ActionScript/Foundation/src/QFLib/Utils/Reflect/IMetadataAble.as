////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public interface IMetadataAble
	{
		function get metadatas():Vector.<MetadataInfo>;
		function set metadatas(value:Vector.<MetadataInfo>):void;
		function readMetadataByXmlList(node:XMLList):void;
		function addMetadata(data:MetadataInfo):void;
		function getMetadata(name:String):MetadataInfo;
	}
}