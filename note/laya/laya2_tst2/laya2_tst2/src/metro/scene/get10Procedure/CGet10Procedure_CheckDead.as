package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CMetroSceneHandler;
import laya.maths.Rectangle;
import laya.maths.Point;
import a_core.CCommon;
import metro.scene.CFlatObejct;
import laya.events.Event;
import metro.scene.get10Procedure.CGet10Procedure_Select;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_NewScene;
import metro.player.CPlayerData;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.CMetroGameSystem;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_CheckDead extends CProcedureBase {
	public function CGet10Procedure_CheckDead(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		
	}
	private var m_handler:CMetroSceneHandler;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);
		m_isDead = false;

		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}

		fsm.removeData(EGet10ProcedureKey.CLICK_FLAT);
		
		var isOk:Boolean = false;
		for (var i:int = 0; i < m_handler.container.numChildren; i++) {
			var node:CFlatObejct = m_handler.container.getChildAt(i) as CFlatObejct;
			if (node.isLock) {
				continue ;
			}
			var idxX:int = node.getIndexX();
			var idxY:int = node.getIndexY();

			var value:int = node.value;
			var leftIdx:int = idxX - 1;
			var rightIdx:int = idxX + 1;
			var upIdx:int = idxY - 1;
			var downIdx:int = idxY + 1;
			if (leftIdx >= 0) {
				// left
				isOk = _checkNode(leftIdx, idxY, value);
			}
			if (isOk) break;

			if (rightIdx < CPlayerData.X_SIZE) {
				// right
				isOk = _checkNode(rightIdx, idxY, value);
			}
			if (isOk) break;

			if (upIdx >= 0) {
				// up
				isOk = _checkNode(idxX, upIdx, value);
			}
			if (isOk) break;
			
			if (downIdx < CPlayerData.Y_SIZE) {
				// down
				isOk = _checkNode(idxX, downIdx, value);
			}
			if (isOk) break;
		}

		m_isDead = !isOk;
	}

	private var m_isDead:Boolean = false;
	private function _checkNode(idxX:int, idxY:int, value:int) : Boolean {
			var node:CFlatObejct = m_handler.getChildByIndex(idxX, idxY);
			if (node.isLock) {
				return false;
			}

			if (node.value == value) {
				return true;
			}
			return false;
		}

	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (!m_isDead) {
			changeProcedure(fsm, CGet10Procedure_WaitClick);
		} else {
			changeProcedure(fsm, CGet10Procedure_Dead);
		}
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}
}

}

