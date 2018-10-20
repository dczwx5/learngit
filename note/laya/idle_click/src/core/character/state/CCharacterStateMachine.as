package core.character.state
{
	import core.game.ecsLoop.CGameComponent;
	import core.fsm.IFsm;
	import core.game.fsm.CFsmSystem;
	import core.character.state.CCharacterIdleState;
	import core.character.state.CCharacterMoveState;
	import core.character.state.CCharacterAttackState;
	import core.character.state.CCharacterDeadState;
	import core.character.state.CCharacterState;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterStateMachine extends CGameComponent {
		private static var _INDEX:int = 0;
		public function CCharacterStateMachine(){
			
		}
		
		protected override function onEnter() : void {
			var pFsmSystem:CFsmSystem = owner.system.stage.getSystem(CFsmSystem) as CFsmSystem;
			var fsmName:String = "Character" + _INDEX;

			var stateList:Array = [
				new CCharacterIdleState(),
				new CCharacterMoveState(),
				new CCharacterAttackState(), 
				new CCharacterDeadState()
			];
			m_fsm = pFsmSystem.createFsm(fsmName, owner, stateList);
			_INDEX++;

			m_fsm.start(CCharacterIdleState);
		}

		protected override function onExit() : void {
			var pFsmSystem:CFsmSystem = owner.system.stage.getSystem(CFsmSystem) as CFsmSystem;
			pFsmSystem.destroyFsm(m_fsm.name);
		}

		public function get curState() : CCharacterState {
			return m_fsm.currentState as CCharacterState;
		}


		private var m_fsm:IFsm;
	}

}