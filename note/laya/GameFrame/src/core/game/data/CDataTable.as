package core.game.data
{
	import core.framework.IDataTable;

	/**
	 * ...
	 * @author
	 */
	public class CDataTable implements IDataTable {
		public function CDataTable(strName:String, sIDKey:String = "ID") {
			m_Name = strName;
			m_idKey = sIDKey;
		}

		public function dispose() : void {
			if (m_tableMap) {
				for (var key:* in m_tableMap) {
					delete m_tableMap[key];
				}
				m_tableMap = null;
			}

			if (m_tableList) {
				m_tableList.length = 0;
				m_tableList = null;
			}
		}

		public function get name() : String {
			return m_Name;
		}
		public function set name(v:String) : void {
			m_Name = v;
		}

		internal function initWithMap(pDataMap:Object) : Boolean {
			if (!pDataMap) {
				return false;
			}

			m_tableMap = pDataMap;
			return true;
		}
		public function get primaryKey() : String {
			return m_idKey;
		}
		public function get tableMap() : Object {
			return m_tableMap;
		}

		public function findByPrimaryKey(key:*) : * {
			if (null == key || undefined == key) {
				return null;
			}

			var ret:* = m_tableMap[key];
			if (ret == undefined) {
				return null;
			}
			return ret;
		}

		public function findByProperty(sPropertyName:String, filterVal:*) : Array {
			if (null == sPropertyName || sPropertyName.length == 0) {
				return null;
			}
			if (null == filterVal || filterVal == undefined) {
				return null;
			}

			var ret:Array = [];
			var findValue:*;
			for each (var rowObj:Object in m_tableMap) {
				findValue = rowObj[sPropertyName];
				if (findValue != null && findValue != undefined) {
					ret[ret.length] = rowObj;
				}
			}
			return ret;
		}

		public function toArray() : Array {
			if (null == m_tableList) {
				m_tableList = new Array();
				for each (var value:* in m_tableMap) {
					m_tableList[m_tableList.length] = value;
				}
			}
			return m_tableList;
		}
		public function get first() : * {
			var array:Array = toArray();
			if (array && array.length > 0) {
				return array[0];
			}
			return null;
		}
		public function get last() : * {
			var array:Array = toArray();
			if (array && array.length > 0) {
				return array[array.length-1];
			}
			return null;
		}

		private var m_Name:String;
		private var m_tableMap:Object;
		private var m_tableList:Array;

		private var m_idKey:String;
	}

}