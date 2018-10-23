package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_Merger;
import metro.player.CPlayerSystem;
import game.view.CUISystem;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_SelectLock extends CProcedureBase {
	public function CGet10Procedure_SelectLock(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

		
	}

	private var m_handler:CMetroSceneHandler;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}
		if (!m_pPlayerSystem) {
			m_pPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
		}
		
		m_forceStopByError = false;
		var item:CFlatObejct = fsm.getData(EGet10ProcedureKey.CLICK_FLAT) as CFlatObejct;
		if (item.isLockState) {
			_processFlatClick(item);
		} else {
			m_forceStopByError = true;
		}
	}
	private var m_forceStopByError:Boolean;
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		if (!m_forceStopByError) {
			changeProcedure(fsm, CGet10Procedure_CheckAndOpenNewLock);
		} else {
			changeProcedure(fsm, CGet10Procedure_MoveToMergeFlat);
		}
		
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_forceStopByError = false;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private function _processFlatClick(child:CFlatObejct) : void {
		if (child.value > 0) {
			var cost:int = m_pPlayerSystem.playerData.getOpenCost();
			if (m_pPlayerSystem.playerData.canOpen()) {
				m_handler.open(child);
			} else {
				(m_pPlayerSystem.stage.getSystem(CUISystem) as CUISystem).showMsg("积分不足, 需要" + cost + "积分");
				m_forceStopByError = true;
			}
		}
	}

	private var m_pPlayerSystem:CPlayerSystem;
}

}

