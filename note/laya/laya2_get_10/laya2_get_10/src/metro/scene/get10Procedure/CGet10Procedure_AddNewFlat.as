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
import metro.player.CPlayerSystem;
import metro.scene.flat.CFlatState;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_AddNewFlat extends CProcedureBase {
	public function CGet10Procedure_AddNewFlat(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

		m_tempNewFlat = new Array();
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
		m_isFinish = false;
		_fallTargetCount = 0;
		_fallFinishedCount = 0;
		m_tempNewFlat.length = 0;

		_fall();
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		if (m_isFinish) {
			changeProcedure(fsm, CGet10Procedure_CheckDead);		
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

	private function _setFallValue() : void {
		for (var x:int = 0; x < CPlayerData.X_SIZE; x++) {
			var fallValue:int = 0;

			var needToFall:Boolean = false;
			var lastNode:CFlatObejct;
			for (var y:int = CPlayerData.Y_SIZE - 1; y >= 0; y--) {
				var node:CFlatObejct = m_handler.getChildByIndex(x, y);
				lastNode = node;
				node.fallValue = 0;
				if (node.value == 0) {
					fallValue++;
				} else {
					node.fallValue = fallValue;
					if (fallValue > 0) {
						_fallTargetCount++;
					}
					needToFall = true;
				}
			}
		

			// fallValue == new Flat
			for (var i:int = 0; i < fallValue; i++) {
				var value:int = m_pPlayerSystem.playerData.createNewValue();
				var newFlat:CFlatObejct = m_handler.flatBuilder.build(CFlatObejct.STATE_FALLING, value, -1) as CFlatObejct;
				newFlat.fallValue = fallValue;
				newFlat.tempIdxX = lastNode.getIndexX();
				newFlat.tempIdxY = - (i+1);
				newFlat.x = lastNode.x;
				newFlat.y = lastNode.y - CFlatObejct.SIZE * (i+1);
				m_handler.container.addChild(newFlat);
				m_tempNewFlat.push(newFlat);

				_fallTargetCount++;
			}
		}
	}

	private var m_tempNewFlat:Array;
	private function _fall() : void {
		_setFallValue();
		if (_fallTargetCount == 0) {
			m_isFinish = true;
			return ;
		}
		
		var targetNode:CFlatObejct;
		for (var i:int = 0; i < m_handler.container.numChildren; i++) {
			var node:CFlatObejct = m_handler.container.getChildAt(i) as CFlatObejct;
			if (node.fallValue > 0) {
				(node.fsm.currentState as CFlatState).toFalling();
				targetNode = m_handler.getChildByIndex(node.getIndexX(), node.getIndexY() + node.fallValue);
				Tween.to(node, {"y":targetNode.y}, CFlatObejct.FALL_TIME, CFlatObejct.FALL_HANDLER, Handler.create(this, _onFallFinished));
			}
		}

		for (i = 0; i < m_tempNewFlat.length; i++) {
			var newFlat:CFlatObejct = m_tempNewFlat[i] as CFlatObejct;
			if (newFlat.fallValue > 0) {
				targetNode = m_handler.getChildByIndex(newFlat.tempIdxX, newFlat.tempIdxY + newFlat.fallValue);
				Tween.to(newFlat, {"y":targetNode.y}, CFlatObejct.FALL_TIME, CFlatObejct.FALL_HANDLER, Handler.create(this, _onFallFinished));
			}
		}
	}

	private function _onFallFinished() : void {
		
		_fallFinishedCount++;
		
		if (_fallFinishedCount >= _fallTargetCount) {
			m_isFinish = true;
			var targetNode:CFlatObejct;

			// 移动完将目标方块的值换成新的
			for (var x:int = 0; x < CPlayerData.X_SIZE; x++) {
				for (var y:int = CPlayerData.Y_SIZE - 1; y >= 0; y--) {
					var node:CFlatObejct = m_handler.getChildByIndex(x, y);
					if (node.fallValue > 0) {
						(node.fsm.currentState as CFlatState).resumeStateFromFalling();
						targetNode = m_handler.getChildByIndex(node.getIndexX(), node.getIndexY() + node.fallValue);
						targetNode.value = node.value;
						node.fallValue = 0;
						node.value = 0;
					}
				}
			}


			while (m_tempNewFlat.length > 0) {
				var tempFlat:CFlatObejct = m_tempNewFlat.shift() as CFlatObejct;
				targetNode = m_handler.getChildByIndex(tempFlat.tempIdxX, tempFlat.tempIdxY + tempFlat.fallValue);
				targetNode.value = tempFlat.value;
				tempFlat.fallValue = 0;

				m_handler.container.removeChild(tempFlat);
				m_handler.flatBuilder.remove(tempFlat);
			}
			
			m_handler.resetPosition();

		}
	}

	
	private var m_isFinish:Boolean = false;
	private var _fallTargetCount:int;
	private var _fallFinishedCount:int;

	private var m_pPlayerSystem:CPlayerSystem;
}

}

