package a_core.fsm
{
	// import a_core.CMap;
	import a_core.fsm.CFsmBase;
	import a_core.fsm.CFsm;
	import a_core.framework.CBean;

	/**
	 * ...
	 * @author
	 */
	public final class CFsmManager extends CBean {
		public function CFsmManager(){
			m_fsms = new Object();
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();

			for (var key:* in m_fsms) {
				var fsm:CFsmBase = m_fsms[key];
				delete m_fsms[key]; 

				if (fsm.isDestroyed) {
					continue;
				}
				fsm.shutDown();
			}
			m_fsms = null;


			// var temp:Array = m_fsms.values;
			// for (var i:int = 0; i < temp.length; i++) {
			// 	var fsm:CFsmBase = temp[i];
			// 	if (fsm.isDestroyed) {
			// 		continue;
			// 	}
			// 	fsm.shutDown();
			// }
		
			// m_fsms.clear();
		}

		public function update(deltaTime:Number) : void {
			for (var key:* in m_fsms) {
				var fsm:CFsmBase = m_fsms[key];
				if (fsm.isDestroyed) {
					continue;
				}
				fsm.update(deltaTime);
			}
			/**
			var temp:Array = m_fsms.values;
			for (var i:int = 0; i < temp.length; i++) {
				var fsm:CFsmBase = temp[i];
				if (fsm.isDestroyed) {
					continue;
				}
				fsm.update(deltaTime);
			}*/

		}

		public function getAllFsms() : Object {
			return m_fsms;
		}

		public function getFsm(name:String) : CFsm {
			return m_fsms[name];
		}
		public function getFsmByOwnerType(clazz:Class) : CFsm {
			var fsm:CFsm;
			for each (fsm in m_fsms) {
				if (fsm.owner is clazz) {
					return fsm;
				}
			}
			return null;
		}
		public function getFsmsByOwnerType(clazz:Class) : Array {
			var ret:Array = new Array();
			var fsm:CFsm;
			for each (fsm in m_fsms) {
				if (fsm.owner is clazz) {
					ret.push(fsm);
				}
			}
			return null;
		}

		public function createFsm(name:String, owner:Object, stateList:Array) : CFsm {
			if (hasFsm(name)) {
				throw new Error("already exist FSM " + name);
			}
		
			var fsm:CFsm = new CFsm(name, owner, stateList);
			fsm.system = system;
			fsm.initialize();
			m_fsms[name] =fsm;
			// m_fsms.set(name, fsm);
			return fsm;
		}

		public function destroyFsm(name:String) : Boolean {
			var fsm:CFsmBase = m_fsms[name];
			if (fsm) {
				fsm.shutDown();
				delete m_fsms[name];
				return fsm;
			}
			return false;
		}

		public function hasFsm(name:String) : Boolean {
			return m_fsms.hasOwnProperty(name);
		}

		// public function get count() : int {
		// 	return m_fsms.keys.length;
		// }

		private var m_fsms:Object; // key:string, value fsm
	}

}