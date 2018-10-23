package metro.scene.flat
{

import a_core.fsm.CFsmState;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;

/**
	* ...
	* @author
	*/
public class CFlatState extends CFsmState {
	public function CFlatState(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

	}

	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		m_pFlat = fsm.owner as CFlatObejct;
		m_toFalling = false;
		m_bResumeFromFalling = false;
		m_pFsm = fsm;
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (m_toFalling) {
			fsm.setData(EGet10ProcedureKey.STATE_BY_FALLING, stateClass);
			changeState(fsm, CFlatFalling);
			return ;
		}
		if (m_bResumeFromFalling) {
			var clazz:Class = fsm.getData(EGet10ProcedureKey.STATE_BY_FALLING) as Class;
			changeState(fsm, clazz);
		}

	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_pFsm = null;

	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_pFlat = null;
		m_toFalling = false;
		m_bResumeFromFalling = false;
		m_pFsm = null;
	}

	public function resumeStateFromFalling() : void {
		m_bResumeFromFalling = true;
		if (m_bResumeFromFalling) {
			var clazz:Class = m_pFsm.getData(EGet10ProcedureKey.STATE_BY_FALLING) as Class;
			changeState(m_pFsm, clazz);
		}
	}

	public function toFalling() : void {
		m_toFalling = true;
		// 不马上执行的话。会有跨帧的问题
		if (m_toFalling) {
			m_pFsm.setData(EGet10ProcedureKey.STATE_BY_FALLING, stateClass);
			changeState(m_pFsm, CFlatFalling);
		}
	}

	public function toLock() : void {
		if (this is CFlatUnVisible) {
			changeState(m_pFsm, CFlatLock);		
		} else {
			throw new Error("error to Change to lockState ")
		}
	}

	public virtual function get stateClass() : Class {
		return null;
	}
	protected var m_bResumeFromFalling:Boolean;
	protected var m_toFalling:Boolean;
	protected var m_pFlat:CFlatObejct;
	private var m_pFsm:CFsm;
}

}

