package a_core.pool
{
	import a_core.framework.CBean;
	import laya.utils.Pool;

	/**
	 * ...
	 * @author
	 */
	public class CPoolBean extends CBean {
		public function CPoolBean(sign:String, type:Class){
			m_type = type;
			m_sign = sign;
		}

		public function get sign() : String {
			return m_sign;
		}
		public function get type() : Class {
			return m_type;
		}

		public function createObject() : * {
			var item:* = Pool.getItemByClass(sign, type);
			var reset:Function = item["reset"];
			if (reset) {
				reset();
			}
			return item;
		}

		public function recoverObject(item:*) : void {
			Pool.recover(sign, item);
		}

		private var m_sign:String;
		private var m_type:Class;
	}

}