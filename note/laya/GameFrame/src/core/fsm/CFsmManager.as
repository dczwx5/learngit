package core.fsm
{
	// import core.CMap;
	import core.fsm.CFsmBase;
	import core.fsm.IFsmManager;
	import laya.utils.Dictionary;
	import core.fsm.IFsm;
	import core.framework.CBean;

	/**
	 * ...
	 * @author
	 */
	public final class CFsmManager extends CBean implements IFsmManager {
		public function CFsmManager(){
			m_fsms = new Dictionary();
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();

			var temp:Array = m_fsms.values;
			for (var i:int = 0; i < temp.length; i++) {
				var fsm:CFsmBase = temp[i];
				if (fsm.isDestroyed) {
					continue;
				}
				fsm.shutDown();
			}
		
			m_fsms.clear();
		}

		public function update(deltaTime:Number) : void {
			var temp:Array = m_fsms.values;
			for (var i:int = 0; i < temp.length; i++) {
				var fsm:CFsmBase = temp[i];
				if (fsm.isDestroyed) {
					continue;
				}
				fsm.update(deltaTime);
			}

		}

		public function getAllFsms() : Array {
			return m_fsms.values;
		}

		public function getFsm(name:String) : IFsm {
			return m_fsms.get(name);
		}
		public function getFsmByOwnerType(clazz:Class) : IFsm {
			var values:Array = m_fsms.values;
			var fsm:IFsm;
			for each (fsm in values) {
				if (fsm.owner is clazz) {
					return fsm;
				}
			}
			return null;
		}

		public function createFsm(name:String, owner:Object, stateList:Array) : IFsm {
			if (hasFsm(name)) {
				throw new Error("already exist FSM " + name);
			}

			var fsm:CFsm = new CFsm(name, owner, stateList);
			fsm.system = system;
			fsm.initialize();
			m_fsms.set(name, fsm);
			return fsm;
		}

		public function destroyFsm(name:String) : Boolean {
			var fsm:CFsmBase = m_fsms.get(name);
			if (fsm) {
				fsm.shutDown();
				return m_fsms.remove(name);
			}
			return false;
		}

		public function hasFsm(name:String) : Boolean {
			return m_fsms.get(name) != null;
		}

		public function get count() : int {
			return m_fsms.keys.length;
		}

		private var m_fsms:Dictionary; // key:string, value fsm
	}

}