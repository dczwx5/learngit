package core.character.ai
{
import core.game.ecsLoop.CGameComponent;
import core.character.state.CCharacterState;
import core.character.state.CCharacterStateMachine;
import core.character.state.CCharacterIdleState;
import core.CCommon;
import core.character.move.CMovementComponent;
import core.character.display.IDisplay;

/**
	* ...
	* @author
	*/
public class CCharacterAIComponent extends CGameComponent {
	public function CCharacterAIComponent(){
		super("AI", false);
	}

	protected override function onEnter() : void {
		super.onEnter();

		m_lastThinkTime = CCommon.getTimer();
	}
	public function think() : void {
		var curTime:Number = CCommon.getTimer();
		if (curTime - m_lastThinkTime < 1) {
			return ;
		}
		m_lastThinkTime = curTime;
		if (Math.random() * 10 < 7) {
			return ;
		}

		var machine:CCharacterStateMachine = owner.getComponentByClass(CCharacterStateMachine) as CCharacterStateMachine;
		var state:CCharacterState = machine.curState;
		if (state is CCharacterIdleState) {
			m_lastThinkTime = curTime;
			var rWidth:Number = 0;
			var rHeight:Number = 0;
			var display:IDisplay = owner.getComponentByClass(IDisplay) as IDisplay;
			rWidth = 130; // display.displayObject.getWidth();
			rHeight = 170; // display.displayObject.getHeight();
			// for test
			var movement:CMovementComponent = owner.getComponentByClass(CMovementComponent) as CMovementComponent;
			var moveX:Number = Math.random() * (owner.sceneFacade.sceneWidth - rWidth);
			var moveY:Number = 150 + Math.random() * (owner.sceneFacade.sceneHeight - rHeight-150);
			movement.moveTo(moveX, moveY);
		}
	}

	override protected function onExit() : void {
		super.onExit();
	}

	private var m_lastThinkTime:Number;
}
}