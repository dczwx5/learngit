////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{
	
	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class VariableInfo extends MetadataAbleInfo
	{
		public var name:String;
		public var type:String; // qualified name
		
		public function VariableInfo()
		{
			_memberType = EnumMemberType.Varialbe;
		}
	}
}