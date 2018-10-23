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
import laya.maths.Point;
import laya.utils.Tween;
import laya.utils.Ease;
import laya.utils.Handler;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_Fall extends CProcedureBase {
	public function CGet10Procedure_Fall(){
		
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
		m_selectItem = fsm.getData(EGet10ProcedureKey.CLICK_FLAT) as CFlatObejct;
		m_isFinish = false;

		_fall();
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);
		if (m_isFinish) {
			changeProcedure(fsm, CGet10Procedure_AddNewFlat);
			
		}
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_selectItem = null;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
		m_selectItem = null;
	}

	private function _fall() : void {
		if (!m_selectItem) {
			return ;
		}

		var targetNode:CFlatObejct;
		var indexX:int = m_selectItem.getIndexX();
		var indexY:int = m_selectItem.getIndexY();
		while (true) {
			indexY++;
			if (indexY >= CPlayerData.Y_SIZE) {  
				break;
			}

			var node:CFlatObejct = m_handler.getChildByIndex(indexX, indexY);
			if (node.value > 0) {
				break;
			}

			targetNode = node;
		}
		if (!targetNode) {
			m_isFinish = true;
			return ;
		}

		// falling
		Tween.to(m_selectItem, {"y":targetNode.y}, CFlatObejct.FALL_TIME, CFlatObejct.FALL_HANDLER, Handler.create(this, _onArrived, [targetNode]));

		
		//var targetPos:Point = new Point();
	}
	private function _onArrived(targetNode:CFlatObejct) : void {
		targetNode.value = m_selectItem.value;
		m_selectItem.value = 0;
		m_isFinish = true;

		m_handler.resetPosition();
	}
	private var m_isFinish:Boolean = false;

}

}

