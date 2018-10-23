package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_Fall;
import metro.scene.CFrameMovie;
import metro.player.CPlayerSystem;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_Merger extends CProcedureBase {
	public function CGet10Procedure_Merger(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

		
	}

	private var m_handler:CMetroSceneHandler;
	private var m_selectItem:CFlatObejct;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}
		if (!m_pPlayerSystem) {
			m_pPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
		}
		m_selectItem = fsm.getData(EGet10ProcedureKey.CLICK_FLAT) as CFlatObejct;
		m_isForceEnd = false;
		_merger();
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		//if (m_isForceEnd || m_handler.mergeEffectEnd) {
			changeProcedure(fsm, CGet10Procedure_Fall);
		//}
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_selectItem = null;
		m_isForceEnd = false;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
		m_pPlayerSystem = null;
		m_selectItem = null;
	}

	private function _merger() : void {
		var key:*;
		var count:int = 0;
		for (key in m_handler.selectMap) {
			count++;
			if (count > 1) {
				break;
			}
		}

		if (count < 2) {
			m_isForceEnd = true;
			return ;
		}
		
		m_pPlayerSystem.netHandler.prevMerge();

		for (key in m_handler.selectMap) {
			var child:CFlatObejct = m_handler.container.getChildAt(key) as CFlatObejct;
			if (m_selectItem == child) {
				child.value++;
				// m_handler.playMergeEffect(child.x + m_handler.container.x, child.y + m_handler.container.y);
			} else {
				child.value = 0;
			}
		}
	}

	
	private var m_isForceEnd:Boolean;
	private var m_pPlayerSystem:CPlayerSystem;

}

}

