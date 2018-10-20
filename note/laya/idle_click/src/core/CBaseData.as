package core
{
	import core.framework.CAppSystem;
	import core.CBaseData;

	/**
	 * ...
	 * @author auto
	 	m_dataMap : 封装简单的 key : value
		m_childData : 用于组装某个较大的数据集合, 拆分成各个childData, 在rootData使用addChild添加
			getChild
		m_listData : 数组数据, 如果一个数据为数组数据, 则会使用该字段, 
			getListData
	 */
	public class CBaseData {
		public static const _TYPE:String = "type";
		public static const _ID:String = "ID";
		public static const _id:String = "id";

		public static const _X:String = "x";
		public static const _Y:String = "y";

		public static const _SKIN:String = "skin";
		public static const _DEF_ANIMATION:String = "defAni";

		private var m_isList:Boolean;
		private var m_key:String;
		public function CBaseData(listDataClass:Class = null, listKey:String = null){
			m_dataMap = new Object();
			m_listDataClass = listDataClass;
			m_isList = m_listDataClass != null;
			m_key = listKey;
		}

		public function dispose() : void {
			if (m_childData) {
				for each (var child:CBaseData in m_childData) {
					child.dispose();
				}
			}
			if (m_listData) {
				for each (var listChild:CBaseData in m_listData) {
					listChild.dispose();
				}
			}

			clear();
			m_dataMap = null;
			m_childData = null;
			m_listData = null; 
			m_system = null;
			m_rootData = null;
		}

		public function clear() : void {
			for (var key:* in m_dataMap) {
				delete m_dataMap[key];
			}
			if (m_childData) {
				m_childData.length = 0;
			}
			if (m_listData) {
				m_listData.length = 0;
			}
		}
		
		// 增量更新
		// 对于List : 
		// 	传入的dataObj是Array : 
		//		有设置 m_key : 主键, 则会自动更新已有的数据, 或新增数据
		//		没设置 m_key : 只会新增数据
		public virtual function updateData(dataObj:Object) : void {
			if (m_isList) {
				_updateForList(dataObj);
			} else {
				_updateForObject(dataObj);
			}
		}
		private function _updateForList(dataObj:Object) : void {
			var existItemData:CBaseData = null;
			var tempData:Object = null;
			var listChildData:CBaseData = null;
			if (!m_listData) {
				m_listData = new Array();
			}

			if (dataObj is Array) {
				// 多个数据
				var tempList:Array = dataObj as Array;
				for (var i:int = 0; i < tempList.length; i++) {
					tempData = tempList[i];
					
					if (m_key && m_key.length > 0) {
						existItemData = getListChildData(m_key, tempData[m_key]);
					}
					if (existItemData) {
						// 已存在
						existItemData.updateData(tempData);
					} else {
						listChildData = new m_listDataClass();
						_setChildCommonData(listChildData);
						m_listData[m_listData.length] = listChildData;
						listChildData.updateData(tempData);
					}
				} 
			} else {
				tempData = dataObj;
				existItemData = getListChildData(m_key, tempData[m_key]);
				if (existItemData) {
					existItemData.updateData(tempData);
				} else {
					listChildData = new m_listDataClass();
					_setChildCommonData(listChildData);
					m_listData[m_listData.length] = listChildData;
					listChildData.updateData(tempData);
				}
			}
		}
		private function _updateForObject(dataObj:Object) : void {
			for (var key:* in dataObj) {
				m_dataMap[key] = dataObj[key];
			}
		}

		public function getData(key:*) : * {
			return m_dataMap[key];
		}
		public function getInt(key:*) : int {
			return getData(key) as int;
		}
		public function getBoolean(key:*) : Boolean {
			return getData(key) as int;
		}
		public function getString(key:*) : String {
			if (m_dataMap.hasOwnProperty(key)) {
				return getData(key) as String;
			} else {
				return null;
			}
		}
		public function getNumber(key:*) : Number {
			if (m_dataMap.hasOwnProperty(key)) {
				return getData(key) as Number;
			} else {
				return NaN;
			}
		}

		// =================== child
		public function addChild(childData:CBaseData) : void {
			if (!m_childData) {
				m_childData = new Array();
			}
			m_childData[m_childData.length] = childData;
			_setChildCommonData(childData);
		}
		public function getChild(index:int) : CBaseData {
			return m_childData[index];
		}
		public function getChildByType(clazz:Class) : CBaseData {
			for each (var child:CBaseData in m_childData) {
				if (child is clazz) {
					return child;
				}
			}
			return null;
		}
		// listData
		public function get list() : Array {
			return m_listData;
		}
		public function getListChildData(key:*, value:*) : CBaseData {
			for each (var child:CBaseData in m_listData) {
				if (child[key] == value) {
					return child
				}
			}
			return null;
		}
		public function getListChildPrimary(value:*) : CBaseData {
			return getListChildData(m_key, value);
		}

		protected function get isRootData() : Boolean {
			return m_rootData == null;
		}
		private function _setChildCommonData(child:CBaseData) : void {
			if (isRootData) {
				child.m_rootData = this;
			} else {
				child.m_rootData = m_rootData;
			}
			child.m_system = child.m_rootData.m_system;
		}
		private var m_needSync:Boolean;
		private var m_dataMap:Object;
		private var m_rootData:CBaseData;
		private var m_childData:Array; // 子数据

		private var m_listData:Array; // 数组元素
		private var m_listDataClass:Class; // 数组元素类型

		private var m_system:CAppSystem;
	}

}