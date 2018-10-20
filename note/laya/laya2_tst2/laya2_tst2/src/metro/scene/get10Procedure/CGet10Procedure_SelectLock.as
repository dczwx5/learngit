package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_Merger;

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
		m_forceStop = false;
		var item:CFlatObejct = fsm.getData(EGet10ProcedureKey.CLICK_FLAT) as CFlatObejct;
		if (item.isLock) {
			_processFlatClick(item);
		} else {
			m_forceStop = true;
		}
	}
	private var m_forceStop:Boolean;
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		if (m_forceStop) {
			changeProcedure(fsm, CGet10Procedure_WaitClick);
		} else {
			changeProcedure(fsm, CGet10Procedure_MoveToMergeFlat);
		}
		
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_forceStop = false;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private function _processFlatClick(child:CFlatObejct) : void {
		if (child.value > 0) {
			var indexX:int = child.getIndexX();
			var cost:int = m_handler.getOpenCost(indexX);
			if (m_handler.canOpen(indexX)) {
				m_handler.open(indexX);
			} else {
				m_forceStop = true;
			}
		}
	}
}

}

