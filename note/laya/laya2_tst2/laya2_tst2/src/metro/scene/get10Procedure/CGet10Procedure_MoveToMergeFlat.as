package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_Fall;
import metro.scene.CFrameMovie;
import metro.scene.get10Procedure.CGet10Procedure_Merger;
import laya.utils.Tween;
import laya.utils.Ease;
import laya.utils.Handler;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_MoveToMergeFlat extends CProcedureBase {
	public function CGet10Procedure_MoveToMergeFlat(){
		
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
		m_isForceEnd = false;
		_targetFlyCount = 0;
		_flyCount = 0;

		_moveToMergerFlag();
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (m_isForceEnd) {
			changeProcedure(fsm, CGet10Procedure_Merger);
		}
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		m_selectItem = null;
		m_isForceEnd = false;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
		m_selectItem = null;
	}

	private function _moveToMergerFlag() : void {
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

		
		
		for (key in m_handler.selectMap) {
			var child:CFlatObejct = m_handler.container.getChildAt(key) as CFlatObejct;
			if (m_selectItem != child) {
				_targetFlyCount++;
				Tween.to(child, {x:m_selectItem.x, y:m_selectItem.y}, 200, Ease.bounceInOut, Handler.create(this, _onFinished));
			}
		}
	}
	private function _onFinished() : void {
		_flyCount++;
		if (_flyCount >= _targetFlyCount) {
			m_isForceEnd = true;
			m_handler.resetPosition();
		}
	}
	private var _flyCount:int;
	private var _targetFlyCount:int;

	private var m_isForceEnd:Boolean;

}

}

