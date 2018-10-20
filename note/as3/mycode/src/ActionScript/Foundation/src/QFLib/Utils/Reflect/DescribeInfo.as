////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	import flash.utils.Dictionary;

	/**
	 * 描述信息
	 * @author Jave.Lin
	 * @date 2015-4-15
	 */
	public class DescribeInfo extends MetadataAbleInfo implements IDescribeInfo
	{
		private var _describeType:int;
		
		protected var _allMembersDic_key_name:Dictionary;
		protected var _varsDic_key_name:Dictionary;
		protected var _constantsDic_key_name:Dictionary;
		protected var _accessoresDic_key_name:Dictionary;
		protected var _methodesDic_key_name:Dictionary;
		
		protected var _name:String;
		protected var _base:String;
		
		public var extendsClasses:Vector.<String>; // qualified name
		public var implementsInterfaces:Vector.<String>; // qualified name
		public var variables:Vector.<VariableInfo>;
		public var constants:Vector.<ConstantInfo>;
		public var accessores:Vector.<AccessorInfo>;
		public var methods:Vector.<MethodInfo>;
//		public var name:String; // qualified name
		
		public function DescribeInfo( describeType:int)
		{
			super();
			
			_describeType = describeType;
			
			_allMembersDic_key_name = new Dictionary();
			_varsDic_key_name = new Dictionary();
			_constantsDic_key_name = new Dictionary();
			_accessoresDic_key_name = new Dictionary();
			_methodesDic_key_name = new Dictionary();
		}
		
		public function copyFromXML(xml:XML):void
		{
			throw new Error("describe info copy from xml need to reimplements");
		}
		
		protected function readConstant(node:XML):void
		{
			if (!constants)
				constants = new <ConstantInfo>[];
			var data:ConstantInfo = ReflectUtil.Reflect_ns::readConstantInfoByXml(node);
			constants.push(data);
			_constantsDic_key_name[data.name] = data;
			_allMembersDic_key_name[data.name] = data;
		}
		
		protected function readMetaData(node:XML):void
		{
			addMetadata(ReflectUtil.Reflect_ns::readMetadataInfoByXml(node));
		}
		
		protected function readMethod(node:XML):void
		{
			var data:MethodInfo = ReflectUtil.Reflect_ns::readMethodInfoByXml(node);
			
			if (!methods)
				methods = new <MethodInfo>[];
			methods.push(data);
			_methodesDic_key_name[data.name] = data;
			_allMembersDic_key_name[data.name] = data;
		}
		
		protected function readAccessor(node:XML):void
		{
			if (!accessores)
				accessores = new <AccessorInfo>[];
			var data:AccessorInfo = ReflectUtil.Reflect_ns::readAccessorInfoByXml(node);
			accessores.push(data);
			_accessoresDic_key_name[data.name] = data;
			_allMembersDic_key_name[data.name] = data;
		}
		
		protected function readVariable(node:XML):void
		{
			if (!variables)
				variables = new <VariableInfo>[];
			var data:VariableInfo = ReflectUtil.Reflect_ns::readVariableInfoByXml(node);
			variables.push(data);
			_varsDic_key_name[data.name] = data;
			_allMembersDic_key_name[data.name] = data;
		}
		
		protected function readImplementsInterface(node:XML):void
		{
			if (!implementsInterfaces)
				implementsInterfaces = new <String>[];
			implementsInterfaces.push(node["@type"].toString());
		}
		
		protected function readExtendsClass(node:XML):void
		{
			if (!extendsClasses)
				extendsClasses = new <String>[];
			extendsClasses.push(node["@type"].toString());
		}
		
		public function getMemberInfo(name:String):MetadataAbleInfo
		{
			return _methodesDic_key_name[name];
		}
		
		public function getVariableInfo(name:String):VariableInfo
		{
			return _varsDic_key_name[name];
		}
		
		public function getConstantInfo(name:String):ConstantInfo
		{
			return _constantsDic_key_name[name];
		}
		
		public function getAccessorInfo(name:String):AccessorInfo
		{
			return _accessoresDic_key_name[name];
		}
		
		public function getMethodInfo(name:String):MethodInfo
		{
			return _methodesDic_key_name[name];
		}
		
		// ======= extends start =======
		public function isExtendsFromByIDes(ides:IDescribeInfo, includeSelfCls:Boolean = false):Boolean
		{
			if (ides == null)
				return false;
			
			return isExtendsFromByQualifiedName(ides.name, includeSelfCls);
		}
		
		public function isExtendsFromByInst(inst:*, includeSelfCls:Boolean = false):Boolean
		{
			if (inst == null)
				return false;
			
			var facRI:FactoryInfo = ReflectUtil.getFactoryInfo(inst);
			return isExtendsFromByQualifiedName(facRI.name, includeSelfCls);
		}
		
		public function isExtendsFromByCls(cls:Class, includeSelfCls:Boolean = false):Boolean
		{
			if (cls == null)
				return false;
			
			var clsRI:ClassInfo = ReflectUtil.getClassInfo(cls);
			return isExtendsFromByQualifiedName(clsRI.name, includeSelfCls);
		}
		
		public function isExtendsFromByQualifiedName(qualifiedName:String, includeSelfCls:Boolean = false):Boolean
		{
			if (qualifiedName == null || qualifiedName == "")
				return false;
			
			if (!extendsClasses || extendsClasses.length == 0)
				return false;
			
			if (extendsClasses.length == 1)
			{
				if (includeSelfCls)
					return name == qualifiedName;
				else
					return extendsClasses[0] == qualifiedName;
			}
			
			if (includeSelfCls)
				return name == qualifiedName;
			else
				return extendsClasses.indexOf(qualifiedName) != -1;
		}
		// ======= extends end =======
		
		// ======= implements start =======
		public function isImplementsFromByIDes(ides:IDescribeInfo):Boolean
		{
			if (ides == null)
				return false;
			
			return isImplementsFromByQualifiedName(ides.name);
		}
		
		public function isImplementsFromByInst(inst:*):Boolean
		{
			if (inst == null)
				return false;
			
			var facRI:FactoryInfo = ReflectUtil.getFactoryInfo(inst);
			return isImplementsFromByQualifiedName(facRI.name);
		}
		
		public function isImplementsFromByCls(cls:Class):Boolean
		{
			if (cls == null)
				return false;
			
			var clsRI:ClassInfo = ReflectUtil.getClassInfo(cls);
			return isImplementsFromByQualifiedName(clsRI.name);
		}
		
		public function isImplementsFromByQualifiedName(qualifiedName:String):Boolean
		{
			if (qualifiedName == null || qualifiedName == "")
				return false;
			
			if (!implementsInterfaces || implementsInterfaces.length == 0)
				return false;
			
			return implementsInterfaces.indexOf(qualifiedName) != -1;
		}
		// ======= implements end =======
		
		public function get describeType():int
		{
			return _describeType;
		}
		
		public function get name():String
		{
			return _name;
		}
		
		public function get base():String
		{
			return _base;
		}
	}
}