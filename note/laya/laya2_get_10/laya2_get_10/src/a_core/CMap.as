package a_core
{	/**
	 * ...
	 * @author auto
	 这类不能用
	 */

	public class CMap extends Object {
		public function CMap(){
		}

		// final public function get count() : int {
		// 	return m_iCount;
		// }

		public function add(key:*, value:*, bAllowReplace:Boolean = false) : void {
			if (this[key] != null) {
				if (bAllowReplace) {
					this[key] = value;
				} else {
					var sKeyType:String = CCommon.getQualifiedClassName(key);
					var sValueType:String = CCommon.getQualifiedClassName(value);
					throw new Error("CMap.add() : adding a key that has already existed in the map... !! key = " + key + " : " + sKeyType + ", value = " + value + " : " + sValueType);
				}
			} else {
				this[key] = value;
				// m_iCount++;
			}
		}

		public function remove(key:*) : Boolean {
			if (this[key] != null) {
				delete this[key];
				// m_iCount--;
				return true;
			}
			return false;
		}

		final public function find(key:*) : * {
			if (key == null) return null;
			return this[key];
		}

		final public function firstKey() : * {
			for (var key:* in this) return key;
			return null;
		}

		final public function firstValue() : * { 
			for each (var value:* in this) {
				return value;
			}
			return null;
		}

		final public function clear() : void {
			while(firstKey() != null) {
				for (var key:* in this) delete this[key];
			}
			// m_iCount = 0;
		}

		public function toArray() : Array {
			// var theArray:Array = new Array(m_iCount);
			var theArray:Array = new Array();

			var i:int = 0;
			for each (var obj:* in this) {
				theArray[i++] = obj;
			}
			return theArray;
		}

		// func(key, value)
		public function loop(func:Function) : void {
			if (null == func) return ;
			for (var key:*in this) {
				func(key, this[key]);
			}
		}

		// private var m_iCount:int;
	}

}

