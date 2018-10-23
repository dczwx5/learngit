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
import metro.scene.flat.CFlatReady;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_Select extends CProcedureBase {
	public function CGet10Procedure_Select(){
		
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

		var item:CFlatObejct = fsm.getData(EGet10ProcedureKey.CLICK_FLAT) as CFlatObejct;
		_processFlatClick(item);
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		changeProcedure(fsm, CGet10Procedure_MoveToMergeFlat);
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private function _processFlatClick(child:CFlatObejct) : void {
		if (child.value > 0 && child.isRunning) {
			m_handler.checkedMap[child.index] = true;
			m_handler.selectMap[child.index] = true;

			var idxX:int = child.getIndexX();
			var idxY:int = child.getIndexY();

			var value:int = child.value;
			var leftIdx:int = idxX - 1;
			var rightIdx:int = idxX + 1;
			var upIdx:int = idxY - 1;
			var downIdx:int = idxY + 1;
			if (leftIdx >= 0) {
				// left
				_checkNode(leftIdx, idxY, value);
			
			}
			if (rightIdx < CPlayerData.X_SIZE) {
				// right
				_checkNode(rightIdx, idxY, value);
				
			}
			if (upIdx >= 0) {
				// up
				_checkNode(idxX, upIdx, value);
			}
			
			if (downIdx < CPlayerData.Y_SIZE) {
				// down
				_checkNode(idxX, downIdx, value);  
			}
		}
	}
	private function _checkNode(idxX:int, idxY:int, value:int) : void {
		var node:CFlatObejct = m_handler.getChildByIndex(idxX, idxY);
		if (!(node.fsm.currentState is CFlatReady)) {  
			return ;
		}
		
		if (node.value == value) {
			// ok
			m_handler.selectMap[node.index] = true;
			if (m_handler.checkedMap.hasOwnProperty(node.index) == false) {
				_processFlatClick(node);
			}
		}
	}


}

}

