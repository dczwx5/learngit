package a_core.character.state
{
	import a_core.character.state.CCharacterState;
	import a_core.fsm.CFsm;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterAttackState extends CCharacterState {
		public function CCharacterAttackState(){
			
		}
		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);
		}

		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}

	 
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}