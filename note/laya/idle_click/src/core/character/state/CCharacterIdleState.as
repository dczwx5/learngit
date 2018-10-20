package core.character.state
{
	import core.character.state.CCharacterState;
	import core.fsm.IFsm;
	import core.game.ecsLoop.CGameObject;
	import core.character.animation.CCharacterAnimation;
	import core.character.animation.EAnimation;
	import core.ECommonEventType;
	import core.character.move.CMovementComponent;
	import core.character.state.CCharacterMoveState;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterIdleState extends CCharacterState {
		public function CCharacterIdleState(){
			
		}
		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
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

		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			if (!m_isReady) {
				return ;
			}

			var movement:CMovementComponent = (fsm.owner as CGameObject).getComponentByClass(CMovementComponent) as CMovementComponent;
			if (movement.needToMove) {
				changeState(fsm, CCharacterMoveState);
			}
		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}

	 
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}

		private var m_isReady:Boolean;
	}

}