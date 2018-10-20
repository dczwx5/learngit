////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	import flash.system.ApplicationDomain;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	
	/** Actually using for properties's editor
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class ReflectUtil
	{
		private static const _cachesDic_key_name:Dictionary = new Dictionary();
		
		public static function toBoolean(str:String):Boolean
		{
			if (str == "" || str == null)
				return false;
			return str.toLowerCase() == "true";
		}
		
		Reflect_ns static function readMetadataInfoArrByXmlList( xmlList:XMLList, result:Vector.<MetadataInfo> = null):Vector.<MetadataInfo>
		{
			if (xmlList == null || xmlList.length() == 0)
				return result;
			
			if (!result)
				result = new <MetadataInfo>[];
			for each (var node:XML in xmlList) 
			{
				var nodeName:String = node.localName().toString();
				if (nodeName != "metadata")
					continue;
				var data:MetadataInfo = Reflect_ns::readMetadataInfoByXml(node);
				result.push(data);
			}
			return result;
		}
		
		Reflect_ns static function readMetadataInfoByXml( xml:XML, result:MetadataInfo = null):MetadataInfo
		{
			if (!result)
				result = new MetadataInfo();
			result.name = xml["@name"];
			var argsXmlList:XMLList= xml.children();
			for each (var argNode:XML in argsXmlList)
				result.addArgKV(argNode["@key"], argNode["@value"]);
			return result;
		}
		
		Reflect_ns static function readMethodInfoByXml( xml:XML, result:MethodInfo = null):MethodInfo
		{
			if (!result)
				result = new MethodInfo();
			result.name = xml["@name"].toString();
			result.declaredBy = xml["@declaredBy"].toString();
			result.returnType = xml["@returnType"].toString();
			for each (var node:XML in xml.children)
			{
				if (!result.parameters)
					result.parameters = new <ParameterInfo>[];
				var param:ParameterInfo = new ParameterInfo();
				param.index = int(node["@index"]);
				param.type = node["@type"].toString();
				param.optional = ReflectUtil.toBoolean(node["@optional"]);
				result.parameters.push(param);
			}
			result.metadatas = Reflect_ns::readMetadataInfoArrByXmlList(xml.children(), result.metadatas);
			return result;
		}
		
		Reflect_ns static function readAccessorInfoByXml( xml:XML, result:AccessorInfo = null):AccessorInfo
		{
			if (!result)
				result = new AccessorInfo();
			result.name = xml["@name"].toString();
			result.access = xml["@access"].toString();
			result.type = xml["@type"].toString();
			result.declaredBy = xml["@declaredBy"].toString();
			result.readMetadataByXmlList(xml.children());
			return result;
		}
		
		Reflect_ns static function readVariableInfoByXml( xml:XML, result:VariableInfo = null):VariableInfo
		{
			if (!result)
				result = new VariableInfo();
			result.name = xml["@name"].toString();
			result.type = xml["@type"].toString();
			result.readMetadataByXmlList(xml.children());
			return result;
		}
		
		Reflect_ns static function readConstructorByXml( xml:XML, name:String, result:MethodInfo = null):MethodInfo
		{
			if (!result)
				result = new MethodInfo();
			result.name = name;
			result.declaredBy = name;
			result.returnType = "void";
			result.Reflect_ns::_isConstructor = true;
			result.readMetadataByXmlList(xml.children());
			return result;
		}
		
		Reflect_ns static function readConstantInfoByXml( xml:XML, result:ConstantInfo = null):ConstantInfo
		{
			if (!result)
				result = new ConstantInfo();
			result.name = xml["@name"].toString();
			result.type = xml["@type"].toString();
			result.readMetadataByXmlList(xml.children());
			return result;
		}
		
		Reflect_ns static function readFactoryInfoByXml( xml:XML):FactoryInfo
		{
			var name:String = xml.hasOwnProperty("@name") ? xml["@name"] : xml["@type"];
			var result:FactoryInfo = _cachesDic_key_name[name + "-FactoryInfo"];
			if (!result)
			{
				result = new FactoryInfo(xml);
				_cachesDic_key_name[result.name + "-FactoryInfo"] = result;
			}
			return result;
		}
		
		public static function clearCaches():void
		{
			var have:Boolean = true;
			while (have)
			{
				have = false;
				for (var key:Object in _cachesDic_key_name)
				{
					have = true;
					delete _cachesDic_key_name[key];
				}
			}
		}
		
		public static function getFactoryInfo(inst:Object):FactoryInfo
		{
			if (inst == null)
				return null;
			
			var describeXml:XML = describeType(inst);
			var name:String = describeXml.hasOwnProperty("@name") ? describeXml["@name"] : describeXml["@type"];
			var result:FactoryInfo = _cachesDic_key_name[name + "-FactoryInfo"];
			if (!result)
			{
				result = new FactoryInfo(describeXml);
				_cachesDic_key_name[result.name + "-FactoryInfo"] = result;
			}
			return result;
		}
		
		public static function getClassInfo(cls:Class):ClassInfo
		{
			if (cls == null)
				return null;
			
			var describeXml:XML = describeType(cls);
			var name:String = describeXml["@name"].toString();
			var result:ClassInfo = _cachesDic_key_name[name + "-ClassInfo"];
			if (!result)
			{
				result = new ClassInfo(describeXml);
				_cachesDic_key_name[result.name + "-ClassInfo"] = result;
			}
			return result;
		}
		
		/**
		 * @param strTranslated 该参数为true是，如果data是String的话，则将String做为：qualifiedName来处理，转为一个Class来处理
		 * @param domain 如果data为String时，那么需要将domain参数传进来，指定为data对应qualifiedName的程序域
		 * */
		public static function getDefineInfo(data:*, strTranslated:Boolean = true, domain:ApplicationDomain = null):IDescribeInfo
		{
			var result:IDescribeInfo;
			if (data is Class)
				result = getClassInfo(data);
			else if (data is XML)
				result = Reflect_ns::readFactoryInfoByXml(data);
			else
			{
				if (data is String && strTranslated)
					result = getClassInfoByQualifiedName(data, domain);
				else
					result = getFactoryInfo(data);
			}
			return result;
		}
		
		/**@param strTranslated 该参数为true是，如果src、tar是String的话，则将String做为：qualifiedName来处理，转为一个Class来处理*/
		public static function srcExtendsTar(src:*, tar:*, strTranslated:Boolean = true, 
												  srcDomain:ApplicationDomain = null, tarDomain:ApplicationDomain = null,
												  includeSelfCls:Boolean = false):Boolean
		{
			var srcIDes:IDescribeInfo = getDefineInfo(src, strTranslated, srcDomain);
			var tarIDes:IDescribeInfo = getDefineInfo(tar, strTranslated, tarDomain);
			if (srcIDes == null)
				throw new Error("can not found src described info : ", src);
			if (tarIDes == null)
				throw new Error("can not found tar described info : ", src);
			return srcIDes.isExtendsFromByIDes(tarIDes, includeSelfCls);
		}
		
		public static function srcImplementsTar(src:*, tar:*, strTranslated:Boolean = true, 
												srcDomain:ApplicationDomain = null, tarDomain:ApplicationDomain = null):Boolean
		{
			var srcIDes:IDescribeInfo = getDefineInfo(src, strTranslated, srcDomain);
			var tarIDes:IDescribeInfo = getDefineInfo(tar, strTranslated, tarDomain);
			if (srcIDes == null)
				throw new Error("can not found src described info : ", src);
			if (tarIDes == null)
				throw new Error("can not found tar described info : ", src);
			return srcIDes.isImplementsFromByIDes(tarIDes);
		}
		
		public static function getClassByQualifiedName(qualifiedName:String, domain:ApplicationDomain = null):Class
		{
			if (!domain)
				domain = ApplicationDomain.currentDomain;
			return domain.getDefinition(qualifiedName) as Class;
		}
		
		public static function getClassInfoByQualifiedName(qualifiedName:String, domain:ApplicationDomain = null):ClassInfo
		{
			if (!domain)
				domain = ApplicationDomain.currentDomain;
			var cls:Class = domain.getDefinition(qualifiedName) as Class;
			return getClassInfo(cls);
		}
	}
}