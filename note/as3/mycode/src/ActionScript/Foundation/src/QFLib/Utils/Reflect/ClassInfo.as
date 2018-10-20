////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	import flash.utils.Dictionary;
	
	/**
	 * @author Jave.Lin
	 * @date 2015-1-14
	 **/
	public class ClassInfo extends DescribeInfo
	{
		public function ClassInfo( xml:XML)
		{
			super(EnumDescribeType.ClassInfo);
			
			_allMembersDic_key_name = new Dictionary();
			_varsDic_key_name = new Dictionary();
			_constantsDic_key_name = new Dictionary();
			_accessoresDic_key_name = new Dictionary();
			_methodesDic_key_name = new Dictionary();
			
			_memberType = EnumMemberType.Class;
			
			copyFromXML(xml);
		}
		
		public var isDynamic:Boolean;
		public var isFinal:Boolean;
		public var isStatic:Boolean;
		
		public var factoryInfo:FactoryInfo;
		
		public override function copyFromXML(xml:XML):void
		{
			_name = xml["@name"].toString();
			_base = xml["@base"].toString();
			isDynamic = ReflectUtil.toBoolean(xml["@isDynamic"]);
			isFinal = ReflectUtil.toBoolean(xml["@isFinal"]);
			isStatic = ReflectUtil.toBoolean(xml["@isStatic"]);
			
			var children:XMLList = xml.children();
			for each (var node:XML in children)
			{
				var nodeName:String = node.name().toString();
				switch (nodeName)
				{
					case "extendsClass":
						readExtendsClass(node);
						break;
					case "implementsInterface":
						readImplementsInterface(node);
						break;
					case "variable":
						readVariable(node);
						break;
					case "constant":
						readConstant(node);
						break;
					case "accessor":
						readAccessor(node);
						break;
					case "method":
						readMethod(node);
						break;
					case "metadata":
						readMetaData(node);
						break;
					case "factory":
						readFactory(node);
						break;
					default:
						trace("Class Info Unhandle the node:", nodeName);
						break;
				}
			}
		}
		
		private function readFactory(node:XML):void
		{
			factoryInfo = ReflectUtil.Reflect_ns::readFactoryInfoByXml(node);
		}
		
		public override function isExtendsFromByIDes(ides:IDescribeInfo, includeSelfCls:Boolean = false):Boolean
		{
			var result:Boolean = super.isExtendsFromByIDes(ides, includeSelfCls);
			if (!result)
				result = factoryInfo.isExtendsFromByIDes(ides, includeSelfCls);
			return result;
		}
		
		public override function isExtendsFromByInst(inst:*, includeSelfCls:Boolean = false):Boolean
		{
			var result:Boolean = super.isExtendsFromByInst(inst, includeSelfCls);
			if (!result)
				result = factoryInfo.isExtendsFromByInst(inst, includeSelfCls);
			return result;
		}
		
		public override function isExtendsFromByCls(cls:Class, includeSelfCls:Boolean = true):Boolean
		{
			var result:Boolean = super.isExtendsFromByCls(cls, includeSelfCls);
			if (!result)
				result = factoryInfo.isExtendsFromByCls(cls, includeSelfCls);
			return result;
		}
		
		public override function isExtendsFromByQualifiedName(qualifiedName:String, includeSelfCls:Boolean = true):Boolean
		{
			var result:Boolean = super.isExtendsFromByQualifiedName(qualifiedName, includeSelfCls);
			if (!result)
				result = factoryInfo.isExtendsFromByQualifiedName(qualifiedName, includeSelfCls);
			return result;
		}
		
		public override function isImplementsFromByIDes(ides:IDescribeInfo):Boolean
		{
			var result:Boolean = super.isImplementsFromByIDes(ides);
			if (!result)
				result = factoryInfo.isImplementsFromByIDes(ides);
			return result;
		}
		
		public override function isImplementsFromByInst(inst:*):Boolean
		{
			var result:Boolean = super.isImplementsFromByInst(inst);
			if (!result)
				result = factoryInfo.isImplementsFromByInst(inst);
			return result;
		}
		
		public override function isImplementsFromByCls(cls:Class):Boolean
		{
			var result:Boolean = super.isImplementsFromByCls(cls);
			if (!result)
				result = factoryInfo.isImplementsFromByCls(cls);
			return result;
		}
		
		public override function isImplementsFromByQualifiedName(qualifiedName:String):Boolean
		{
			var result:Boolean = super.isImplementsFromByQualifiedName(qualifiedName);
			if (!result)
				result = factoryInfo.isImplementsFromByQualifiedName(qualifiedName);
			return result;
		}
	}
}