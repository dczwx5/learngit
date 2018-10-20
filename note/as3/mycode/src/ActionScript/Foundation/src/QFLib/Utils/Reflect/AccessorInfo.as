////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class AccessorInfo extends MetadataAbleInfo
	{
		public var name:String;
		/**@see com.qifun.common.reflect.EnumAccessType*/
		public var access:String;
		public var type:String; // qualified name
		public var declaredBy:String; // qualified name
		
		public function AccessorInfo()
		{
			_memberType = EnumMemberType.Accessor;
		}
	}
}