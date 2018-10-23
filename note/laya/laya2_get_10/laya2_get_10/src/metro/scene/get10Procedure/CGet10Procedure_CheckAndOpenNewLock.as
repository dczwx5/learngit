package metro.scene.get10Procedure
{


import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CMetroSceneSystem;
import metro.player.CPlayerSystem;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import metro.scene.flat.CFlatObejct;
import metro.scene.flat.CFlatState;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_CheckAndOpenNewLock extends CProcedureBase {
	public function CGet10Procedure_CheckAndOpenNewLock(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

		
	}

	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}
		if (!m_pPlayerSystem) {
			m_pPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
		}
		
		m_bFinish = false;

		_checkCanOpenNewLock();
	}
	private function _checkCanOpenNewLock() : void {
		var lastOpenLockStep:int = m_pPlayerSystem.playerData.lastOpenLockStep;
		var newLockStep:int = m_pPlayerSystem.playerData.openLockStep;
		if (lastOpenLockStep < newLockStep) {
			var lockList:Array = [];
			for (var i:int = 0; i < m_handler.container.numChildren; i++) {
				var flat:CFlatObejct = m_handler.container.getChildAt(i) as CFlatObejct;
				if (flat.lockStep == newLockStep) {
					lockList.push(flat);
				}
			}

			// showFlat, 可以有动效
			for each (var pFlat:CFlatObejct in lockList) {
				(pFlat.fsm.currentState as CFlatState).toLock();
			}

			m_pPlayerSystem.playerData.updateOpenLockStep();
		}
		m_bFinish = true;
	}

	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (m_bFinish) {
			changeProcedure(fsm, CGet10Procedure_WaitClick);			
		}
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private var m_bFinish:Boolean;

	private var m_handler:CMetroSceneHandler;	
	private var m_pPlayerSystem:CPlayerSystem;
}

}

