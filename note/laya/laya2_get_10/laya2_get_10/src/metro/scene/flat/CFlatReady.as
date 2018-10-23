package metro.scene.flat
{

import a_core.fsm.CFsmState;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;

/**
	* ...
	* @author
	*/
public class CFlatReady extends CFlatState {
	public function CFlatReady(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

	}

	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		m_pFlat.show();
		m_pFlat.hideLock();
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
	public override function get stateClass() : Class {
		return CFlatReady;
	}
}

}

