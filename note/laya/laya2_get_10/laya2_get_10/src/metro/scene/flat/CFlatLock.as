package metro.scene.flat
{

import a_core.fsm.CFsmState;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import metro.player.CPlayerData;

/**
	* ...
	* @author
	*/
public class CFlatLock extends CFlatState {
	public function CFlatLock(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

	}

	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		m_pFlat.lockStep = CPlayerData.OPEN_LOCK_STEP_0;
		m_pFlat.show();
		m_pFlat.showLock();
		m_isToReady = false;
		
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (m_isToReady) {
			changeState(fsm, CFlatReady);
		}

	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);

	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);
		m_isToReady = false;
	}
	public function changeToReady() : void {
		m_isToReady = true;
	}
	public override function get stateClass() : Class {
		return CFlatLock;
	}
	private var m_isToReady:Boolean;
}

}

