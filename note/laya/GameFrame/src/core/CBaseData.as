package core
{
	import core.CBaseData;
	import core.framework.CAppSystem;

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
		public function CBaseData(listDataClass:Class = null){
			m_dataMap = new Object();
			m_listDataClass = listDataClass;
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
		public virtual function updateData(dataObj:Object) : void {
			if (dataObj is Array) {
				if (!m_listData) {
					m_listData = new Array();
				}
				var tempList:Array = dataObj as Array;
				for (var i:int = 0; i < tempList.length; i++) {
					var listChildData:CBaseData = new m_listDataClass();
					_setChildCommonData(listChildData);
					m_listData[m_listData.length] = listChildData;
					listChildData.updateData(tempList[i]);
				} 
			} else {
				for (var key:* in dataObj) {
					m_dataMap[key] = dataObj[key];
				}
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