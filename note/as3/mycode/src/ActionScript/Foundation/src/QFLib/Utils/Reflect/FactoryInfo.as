////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils.Reflect
{

	/**
	 * @author Jave.Lin
	 * @date 2015-1-13
	 **/
	public class FactoryInfo extends DescribeInfo
	{
		public function FactoryInfo( xml:XML)
		{
			super(EnumDescribeType.FactoryInfo);
			
			_memberType = EnumMemberType.Factory;
			
			copyFromXML(xml);
			
			_base = extendsClasses && extendsClasses.length > 0 ? extendsClasses[0] : null;
		}
		
		public var constructor:MethodInfo;
		
		public override function copyFromXML(xml:XML):void
		{
			_name = xml.@name == undefined ? xml["@type"] : xml["@name"];
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
					case "constructor":
						readConstructor(node);
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
					default:
						trace("Factory Info Unhandle the node:", nodeName);
						break;
				}
			}
		}
		
		private function readConstructor(node:XML):void
		{
			constructor = ReflectUtil.Reflect_ns::readConstructorByXml(node, name, constructor);
			_methodesDic_key_name[constructor.name] = constructor;
			_allMembersDic_key_name[constructor.name] = constructor;
		}
	}
}