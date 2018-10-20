package core.procedure
{
	import core.procedure.IProcedureManager;
	import core.fsm.IFsmManager;
	import core.fsm.IFsm;

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
		
		public function initialize(name:String, fsmManager:IFsmManager, procedures:Array) : void {
			if (!fsmManager) {
				throw new Error("fsm manager is invalid");
			}

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
					m_pFsmManager.destroyFsm(m_procedureFsm.name);
					m_procedureFsm = null;
				}
				m_pFsmManager = null;
			}
		}

		private var m_pFsmManager:IFsmManager;
		private var m_procedureFsm:IFsm;
	}

}