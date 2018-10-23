package a_core.character.state
{
	import a_core.character.state.CCharacterState;
	import a_core.fsm.CFsm;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.animation.CCharacterAnimation;
	import a_core.character.animation.EAnimation;
	import a_core.ECommonEventType;
	import a_core.character.move.CMovementComponent;
	import a_core.character.state.CCharacterMoveState;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterIdleState extends CCharacterState {
		public function CCharacterIdleState(){
			
		}
		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);

			var animation:CCharacterAnimation = (fsm.owner as CGameObject).getComponentByClass(CCharacterAnimation) as CCharacterAnimation;
			if (animation.isRunning) {
				_onReady(animation);
			} else {
				animation.on(ECommonEventType.EVENT_RUNNING, this, _onReady, [animation]);
			}
		}
		private function _onReady(animation:CCharacterAnimation) : void {
			animation.playAnimation(EAnimation.IDLE);
			m_isReady = true;
		}

		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			if (!m_isReady) {
				return ;
			}

			var movement:CMovementComponent = (fsm.owner as CGameObject).getComponentByClass(CMovementComponent) as CMovementComponent;
			if (movement.needToMove) {
				changeState(fsm, CCharacterMoveState);
			}
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}

	 
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}

		private var m_isReady:Boolean;
	}

}