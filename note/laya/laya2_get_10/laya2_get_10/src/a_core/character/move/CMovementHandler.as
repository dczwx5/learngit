package a_core.character.move
{
	import a_core.game.ecsLoop.CGameSystemHandler;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.move.CMovementComponent;
	import a_core.game.ecsLoop.ITransform;
	import laya.d3.math.Vector3;
	import a_core.character.state.CCharacterState;
	import a_core.character.state.CCharacterStateMachine;
	import a_core.character.state.CCharacterMoveState;

	/**
	 * ...
	 * @author
	 */
	public class CMovementHandler extends CGameSystemHandler {
		public function CMovementHandler(){
			super(CMovementComponent);
		}

		public override function tickUpdate(delta:Number, obj:CGameObject) : void {
			super.tickUpdate(delta, obj);

			var fsmState:CCharacterState = (obj.getComponentByClass(CCharacterStateMachine) as CCharacterStateMachine).curState;
			if (!(fsmState is CCharacterMoveState)) {
				return ;
			}

			var movement:CMovementComponent = obj.getComponentByClass(CMovementComponent) as CMovementComponent;
			if (!movement.needToMove) {
				return ;
			}

			var transform:ITransform = movement.transform;
			var targetPos:Vector3 = movement.targetPos;
			var stepX:Number = 5;
			var stepY:Number = 5;
			var stepX_HV:Number = 3;
			var stepY_HV:Number = 3; // 

			if (transform.x != targetPos.x && transform.y != targetPos.y) {
				// 非正方向
				stepX = stepX_HV;
				stepY = stepY_HV;
			} 
			var distX:Number = Math.abs(transform.x - targetPos.x);
			var distY:Number = Math.abs(transform.y - targetPos.y);
			if (distX < stepX) {
				stepX = distX;
			}
			if (distY < stepY) {
				stepY = distY;
			}

			if (transform.x != targetPos.x) {
				if (transform.x > targetPos.x) {
					transform.x -= stepX;
				} else {
					transform.x += stepX;
				}
			}
			if (transform.y != targetPos.y) {
				if (transform.y > targetPos.y) {
					transform.y -= stepY;
				} else {
					transform.y += stepY;
				}
			}
			if (Math.abs(transform.x - targetPos.x) < 0.000001 && Math.abs(transform.y - targetPos.y) < 0.000001) {
				// arrived;
				movement.arrived();
			}
        }
	}

}