package core.game.fsm
{
	import core.framework.CAppSystem;
	import core.fsm.CFsmManager;
	import core.framework.IUpdate;
	import core.fsm.IFsm;
	import core.procedure.CProcedureManager;
	import laya.utils.Dictionary;

	/**
	 * ...
	 * @author
	 */
	public class CFsmSystem extends CAppSystem implements IUpdate {
		public function CFsmSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
			m_proceudres = new Dictionary();
			m_fsmManager = new CFsmManager();
			addBean(m_fsmManager);
			
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();

			m_proceudres.clear();
			m_proceudres = null;
			
			m_fsmManager = null;
		}

		public function createFsm(name:String, owner:Object, stateList:Array) : IFsm {
			var fsm:IFsm = m_fsmManager.createFsm(name, owner, stateList);
			return fsm;
		}
		public function getFsm(name:String) : IFsm {
			return m_fsmManager.getFsm(name);
		}
		public function destroyFsm(name:String) : Boolean {
			return m_fsmManager.destroyFsm(name);
		}

		public function hasFsm(name:String) : Boolean {
			return m_fsmManager.hasFsm(name);
		}
		public function update(deltaTime:Number) : void {
			m_fsmManager.update(deltaTime);
		}

		// 流程
		public function createProcedure(name:String, procedures:Array) : CProcedureManager {
			var procedureManager:CProcedureManager = new CProcedureManager();
		
			procedureManager.initialize(name, m_fsmManager, procedures);
			m_proceudres.set(name, procedureManager);
			return procedureManager;
		}
		public function getProcedure(name:String) : CProcedureManager {
			return m_proceudres.get(name);
		}

		private var m_fsmManager:CFsmManager;

		private var m_proceudres:Dictionary;
	}

}