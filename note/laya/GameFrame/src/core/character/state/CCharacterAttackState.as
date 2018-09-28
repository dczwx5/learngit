package core.character.state
{
	import core.character.state.CCharacterState;
	import core.fsm.IFsm;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterAttackState extends CCharacterState {
		public function CCharacterAttackState(){
			
		}
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);
		}

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}

	 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}