package a_core.procedure
{
	import a_core.procedure.IProcedureManager;
	import a_core.fsm.CFsmManager;
	import a_core.fsm.CFsm;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureManager implements IProcedureManager {
		public function CProcedureManager(){
			

		}

		public function get currentProcedure() : CProcedureBase {
			if (m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}

			return m_procedureFsm.currentState as CProcedureBase;
		}

		public function get currentProcedureTime() : Number {
			if (m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}

			return m_procedureFsm.currentStateTime;
		}
		
		public function initialize(name:String, fsmManager:CFsmManager, procedures:Array) : void {
			if (!fsmManager) {
				throw new Error("fsm manager is invalid");
			}
			m_name = name;
			m_pFsmManager = fsmManager;
			m_procedureFsm = m_pFsmManager.createFsm(name, this, procedures);
		}

		public function startProcedure(typeProcedure:Class) : void {
			if (m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			m_procedureFsm.start(typeProcedure);
		}

		public function hasProcedure(typeProcedure:Class) : Boolean {
			if (m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			return m_procedureFsm.hasState(typeProcedure);
		}

		public function getProcedure(typeProcedure:Class) : CProcedureBase {
			if (m_procedureFsm == null) {
				throw new Error("you must iniialize procedure first");
			}
			return m_procedureFsm.getState(typeProcedure) as CProcedureBase;
		}

		public function update(deltaTime:Number) : void {
			trace("CProcedureManager.update----------------");
		}
		public function shutDown() : void {
			if (m_pFsmManager != null) {
				if (m_procedureFsm != null) {
					m_pFsmManager.destroyFsm(m_procedureFsm.Name);
					m_procedureFsm = null;
				}
				m_pFsmManager = null;
			}
		}

		private var m_pFsmManager:CFsmManager;
		private var m_procedureFsm:CFsm;

		public function get name() : String {
			return m_name;
		}
		private var m_name:String;
	}

}