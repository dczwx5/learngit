////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	/**
	 * @author Jave.Lin
	 * @date 2015-1-14
	 **/
	public class ConstantInfo extends MetadataAbleInfo
	{
		public var name:String;
		public var type:String; // qualified name
		
		public function ConstantInfo()
		{
			_memberType = EnumMemberType.Constant;
		}
	}
}