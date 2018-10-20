package a_core.game.fsm
{
	import a_core.framework.CAppSystem;
	import a_core.fsm.CFsmManager;
	import a_core.framework.IUpdate;
	import a_core.fsm.CFsm;
	import a_core.procedure.CProcedureManager;

	/**
	 * ...
	 * @author
	 */
	public class CFsmSystem extends CAppSystem {
		public function CFsmSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
			m_proceudres = new Object();
			m_fsmManager = new CFsmManager();
			addBean(m_fsmManager);
			
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();

			for (var key:* in m_proceudres) {
				delete m_proceudres[key];
			}
			m_proceudres = null;
			
			m_fsmManager = null;
		}

		public function createFsm(name:String, owner:Object, stateList:Array) : CFsm {
			var fsm:CFsm = m_fsmManager.createFsm(name, owner, stateList);
			return fsm;
		}
		public function getFsm(name:String) : CFsm {
			return m_fsmManager.getFsm(name);
		}
		public function destroyFsm(name:String) : Boolean {
			return m_fsmManager.destroyFsm(name);
		}

		public function hasFsm(name:String) : Boolean {
			return m_fsmManager.hasFsm(name);
		}
		public override function update(deltaTime:Number) : void {
			super.update(deltaTime);

			m_fsmManager.update(deltaTime);
		}

		// 流程
		public function createProcedure(name:String, procedures:Array) : CProcedureManager {
			var procedureManager:CProcedureManager = new CProcedureManager();
		
			procedureManager.initialize(name, m_fsmManager, procedures);
			m_proceudres[name] = procedureManager;
			return procedureManager;
		}
		public function getProcedure(name:String) : CProcedureManager {
			return m_proceudres[name];
		}
		public function removeProcedure(name:String) : void {
			
			var manager:CProcedureManager = getProcedure(name);
			if (manager) {
				manager.shutDown();
				delete m_proceudres[name];
			}

		}


		private var m_fsmManager:CFsmManager;

		private var m_proceudres:Object;
	}

}