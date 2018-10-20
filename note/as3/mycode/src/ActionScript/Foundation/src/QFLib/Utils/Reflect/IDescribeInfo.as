////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{
	/**
	 * 描述接口，ClassInfo、FactoryInfo都实现了该接口
	 * @author Jave.Lin
	 * @date 2015-4-15
	 */
	public interface IDescribeInfo
	{
		/**@see com.qifun.common.reflect.EnumDescribeType*/
		function get describeType():int;
		/**Indicate the class name*/
		function get name():String;
		/**Indicate directly the extends class*/
		function get base():String;
		
		function isExtendsFromByIDes(ides:IDescribeInfo, includeSelfCls:Boolean = false):Boolean;
		function isExtendsFromByInst(inst:*, includeSelfCls:Boolean = false):Boolean;
		function isExtendsFromByCls(cls:Class, includeSelfCls:Boolean = false):Boolean;
		function isExtendsFromByQualifiedName(qualifiedName:String, includeSelfCls:Boolean = false):Boolean;
		
		function isImplementsFromByIDes(ides:IDescribeInfo):Boolean;
		function isImplementsFromByInst(inst:*):Boolean;
		function isImplementsFromByCls(cls:Class):Boolean;
		function isImplementsFromByQualifiedName(qualifiedName:String):Boolean;
	}
}