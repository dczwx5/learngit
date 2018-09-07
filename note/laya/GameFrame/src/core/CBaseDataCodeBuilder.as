package core
{
	import core.CBaseDataCodeBuilder;

	/**
	 * ...
	 * @author
	 */
	public class CBaseDataCodeBuilder {
		public function CBaseDataCodeBuilder(){
			
		}
		public function testBuildCore() : void {
			var heroData:Object = {
				"skill":[
					{"ID":1, "lv":2}, {"ID":2, "lv":12, "obj":[1, 2, 3]}, 
				],
				"ID":"1001",
				"lv":13,
				"attack":15.2,
				"color":{
					"ppt":"abcd",
					"avg":true
				},
				"stone":{
					"power":1000,
					"count":20
				}, 
				"qq":{
					"number":1000,
					"age":20,
					"wx": {
						"qq":1111,
						"wxNumber":22222,
						"phone":1331112333
					}
				}, 

				"friends":[
					{"name":"auto", "lv":2}, {"name":"bob", "lv":12}, 
				], 
				"vip":[
					{"ID":11, "lv":2}, {"ID":21, "lv":12, 
						"obj":{
							"kk2b":[{"name":1}, {"name":2}]
						}
					}, 
				]
				
			};
/**, 
				*/
			var code:String = buildCore(heroData, "core.hero", "Hero");
			exportCode(code);
		}

		private var m_prefix:String;
		private var m_packageName:String;
		private var m_dataObject:Object;

		private var m_childIndexObject:Object; // childData的index
		private var m_simpleDataObject:Object;
		private var m_objDatas:Object;
		private var m_arrayDatas:Object; // 数组成员, 如果是简单的数组, 则放到 m_simpleArrayData
		private var m_simpleArrayData:Array;

		private var m_listChildName:String;
		
		// listChildName : 如果不为null , 则说明dataObjct是一个数组, 解析时会做特殊处理
		// 数组不会以key当成员名, 而是以KeyList以成员名, 并会生成两个类
		public function buildCore(dataObject:Object, packageName:String, prefix:String, listChildName:String = null) : String {
			m_prefix = prefix;
			m_packageName = packageName;
			m_dataObject = dataObject;
			m_listChildName = listChildName;

			// 解析object
			if (m_dataObject is Array) {
				_analysisList();
			} else {
				_analysisObject();
			}
			

			var code:String = "";
			// package
			code += _buildPackage();

			// 类
			code += _buildClass();

			// 构造函数
			code += _buildConstruct(m_objDatas, m_arrayDatas, m_childIndexObject);

			// 
			code += _n;

			// updateData
			code += _buildUpdateData(m_objDatas, m_arrayDatas);

			// property get
			code += _buildSimpleProperty(m_simpleDataObject);
			code += _buildObjectProperty(m_objDatas, m_childIndexObject);
			code += _buildArrayProperty(m_arrayDatas, m_childIndexObject);

			// 
			code += _buildSimpleArray();

			// 结尾
			code += _n + "}}";
			
			// 解析子object数据为一个类
			var newCoder:CBaseDataCodeBuilder;
			for (var key:String in m_objDatas) {
				var value:* = m_objDatas[key];
				newCoder = new CBaseDataCodeBuilder();
				var childCode:String = newCoder.buildCore(value, m_packageName, m_prefix + transFirstCharToUpCase(key));
				exportCode(childCode);
			}
			// 解析子array数据为一个类
			for (key in m_arrayDatas) {
				value = m_arrayDatas[key];
				newCoder = new CBaseDataCodeBuilder();
				childCode = newCoder.buildCore(value, m_packageName, m_prefix + transFirstCharToUpCase(key));
				exportCode(childCode);
			}

			return code;
		}

		
		private function _analysisList() : void {
			var array:Array = m_dataObject as Array;
			var fullDataObject:Object = new Object();
			for (var i:int = 0; i < array.length; i++) {
				var obj:Object = array[i];
				for (var key:String in obj) {
					fullDataObject[key] = obj[key];
				}
			}
			m_dataObject = fullDataObject; // 解析结构, 不管数据, 数组, 只要解析一个元素的结构即可
			
			_analysisObject();	

			var newCoder:CBaseDataCodeBuilder = new CBaseDataCodeBuilder();
			var code:String = newCoder.buildCore({}, m_packageName, m_prefix + "List", getClassName());
			exportCode(code);
		}
		private function _analysisObject() : void {
			m_childIndexObject = new Object(); // childData的index
			var childIndex:int = 0;

			m_simpleDataObject = new Object();
			m_objDatas = new Object();
			m_arrayDatas = new Object();
			m_simpleArrayData = new Array();

			for (var key:* in m_dataObject) {
				var value:* = m_dataObject[key];
				if (isSimpleType(value)) {
					m_simpleDataObject[key] = value;
				} else if (value is Array) {
					var v0:* = value[0];
					if (isSimpleType(v0)) {
						 m_simpleArrayData.push(key); // 简单类型的数组, 不创建新类
					} else {
						m_arrayDatas[key] = value;
						m_childIndexObject[key] = childIndex++;
					}
					
				} else {
					// object
					m_objDatas[key] = value;
					m_childIndexObject[key] = childIndex++;
				}
			}
		}
		private function _buildPackage() : String {
			var code:String = "";
			code += "package " + m_packageName + " {"
			code += _n;
			code += "import " + _BaseDataPath + ";";
			code += _n_n;
			return code;
		}
		private function getClassName() : String {
			var className:String = "C" + m_prefix + "Data";
			return className;
		}
		private function getListClassName() : String {
			var className:String = "C" + m_prefix + "ListData";
			return className;
		}
		private function _buildClass() : String {
			var className:String = getClassName();
			var code:String = "";
			// 类
			code += "public class " + className + " extends " +_BaseData + " {";
			return code;
		}
		private function _buildConstruct(objDatas:Object, arrDatas:Object, childIndexObject:Object) : String {
			var className:String = getClassName();
			var code:String = "";
			code += _n;
			code += _t;
			code += "public function " + className + "() {";
			if (m_listChildName && m_listChildName.length > 0) {
				code += _n + _t_t;
				code += "super(" + m_listChildName + ");"
			}
			code += _buildAddChild(objDatas, arrDatas, childIndexObject);

			code += _n;
			code += _t + "}"
			return code;
		}
		private function _buildUpdateData(objDatas:Object, arrDatas:Object) : String {
			var code:String = "";
			code += _t;
			code += "public override function updateData(dataObj:Object) : void {"
			code += _n;
			code += _t_t;
			code += "super.updateData(dataObj);";
			
			for (var key:String in objDatas) {
				var propertyName:String = key + "Data";
				code += _n;
				code += _t_t;
				code += propertyName + ".updateData(dataObj[\"" + key + "\"]);";
			}
			for (key in arrDatas) {
				propertyName = key + "Data";
				code += _n;
				code += _t_t;
				code += propertyName + ".updateData(dataObj[\"" + key + "\"]);";
			}

			code += _n;
			code += _t;
			code += "}";
			return code;
		}

		private function _buildAddChild(objDatas:Object, arrDatas:Object, childIndexObject:Object) : String {
			var ret:String = _n;

			var keyList:Array = new Array();
			var key:String;
			var i:int = 0;
			for (i = 0; i < 10000; i++) {
				var isOutRange:Boolean = true;
				for (key in childIndexObject) {
					var childIndex:int = childIndexObject[key];
					if (childIndex == i) {
						isOutRange = false;
						keyList[i] = key;
						break;
					}
				}
				if (isOutRange) {
					break;
				}
			}

			for (i = 0; i < keyList.length; i++) {
				ret += _t_t;
				
				key = keyList[i];
				var className:String;

				if (arrDatas.hasOwnProperty(key)) {
					className = getPropertyListClassName(key);
					ret += "addChild(new " + className + "());"
				} else {
					className = getPropertyClassName(key);
					ret += "addChild(new " + className + "());"
				}
				

				ret += _n;
			}

			
			// for (var key:* in datas) {
			// 	ret += '\t';
				
			// }
			return ret;
		}
		private function _buildSimpleProperty(datas:Object) : String {
			var ret:String = "";

			for (var key:* in datas) {
				ret += _n;
				ret += _t;

				var value:* = datas[key];
				if (value is int) {
					ret += "public function get " + key + "() : int { return getInt(\"" + key + "\"); }"
				} else if (value is Boolean) {
					ret += "public function get " + key + "() : Boolean { return getBoolean(\"" + key + "\"); }"
				} else if (value is String) {
					ret += "public function get " + key + "() : String { return getString(\"" + key + "\"); }"
				} else if (value is Number) {
					ret += "public function get " + key + "() : Number { return getNumber(\"" + key + "\"); }"
				}
			}

			return ret;
		}
		private function _buildObjectProperty(datas:Object, childIndexObject:Object) : String {
			var ret:String = "";


			for (var key:String in datas) {
				ret += _n;
				ret += _t;

				var value:* = datas[key];
				var index:int = childIndexObject[key];
				var propertyName:String = key + "Data";
				
				var className:String = getPropertyClassName(key);
				ret += "public function get " + propertyName + "() : " + className + " { return getChild(" + index + ") as " + className + "; }"
			}

			return ret;
		}
		private function _buildArrayProperty(datas:Object, childIndexObject:Object) : String {
			var ret:String = "";


			for (var key:String in datas) {
				ret += _n;
				ret += _t;

				var value:* = datas[key];
				var index:int = childIndexObject[key];
				var propertyName:String = key + "ListData";
				
				var className:String = getPropertyListClassName(key);
				ret += "public function get " + propertyName + "() : " + className + " { return getChild(" + index + ") as " + className + "; }"
			}

			return ret;
		}
		private function _buildSimpleArray() : String {
			var code:String = "";
			if (m_simpleArrayData && m_simpleArrayData.length > 0) {
				for (var i:int = 0; i < m_simpleArrayData.length; i++) {
					code += _n_t;
					code += "public function get " + m_simpleArrayData[i] + "() : Array() { return getData(\"" + m_simpleArrayData[i] + "\") as Array; } "; 
				}
			}
			return code;
		}

		private function transFirstCharToUpCase(key:String) : String {
			var tempKey:String = key.charAt(0);
			tempKey = tempKey.toUpperCase() + key.substring(1);
			return tempKey;
		}
		private function getPropertyClassName(key:String) : String {
			var tempKey:String = transFirstCharToUpCase(key);
			var className:String = "C" + m_prefix + tempKey + "Data";
			return className;
		}
		private function getPropertyListClassName(key:String) : String {
			var tempKey:String = transFirstCharToUpCase(key);
			var className:String = "C" + m_prefix + tempKey + "ListData";
			return className;
		}
		private function isSimpleType(value:*) : Boolean {
			return (value is int || value is Boolean || value is String || value is Number);
		}
		// ======================
		private function exportCode(code:String) : void {
			trace("\n\n=============================================");
			trace(code);
			trace("\n\n=============================================");
		}

		public const _t:String = "\t";
		public const _n:String = "\n";
		public const _t_t:String = "\t\t";
		public const _n_n:String = "\n\n";
		public const _n_t:String = "\n\t"

		public var _BaseDataPath:String = "core.CBaseData";
		public var _BaseData:String = "CBaseData";
	}
}
