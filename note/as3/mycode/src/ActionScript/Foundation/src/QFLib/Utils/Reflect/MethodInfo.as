////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class MethodInfo extends MetadataAbleInfo
	{
		Reflect_ns var _isConstructor:Boolean;
		
		public var name:String;
		public var declaredBy:String; // qualified name
		public var returnType:String; // qualified name
		
		public var parameters:Vector.<ParameterInfo>;
		
		public function MethodInfo()
		{
			_memberType = EnumMemberType.Method;
		}
		
		public function get isConstructor():Boolean
		{
			return Reflect_ns::_isConstructor;
		}
	}
}