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

/**
	* ...
	* @author
	*/
public class CGet10Procedure_WaitClick extends CProcedureBase {
	public function CGet10Procedure_WaitClick(){
		
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
		CCommon.stage.on(Event.CLICK, this, _onStageClickHandler);
		m_isWait = true;
		m_selectItem = null;
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		// 
		if (m_selectItem) {
			fsm.setData(EGet10ProcedureKey.CLICK_FLAT, m_selectItem);

			if (m_selectItem.isLock) {
				changeProcedure(fsm, CGet10Procedure_SelectLock);
			} else {
				changeProcedure(fsm, CGet10Procedure_Select);
			}
		}
		
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
		CCommon.stage.off(Event.CLICK, this, _onStageClickHandler);
		m_selectItem = null;
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private var m_checkRect:Rectangle = new Rectangle();
	private var m_checkPoint:Point = new Point(0, 0);
	private function _onStageClickHandler() : void {
		if (!m_isWait) {
			return ;
		}

		for (var key:* in m_handler.checkedMap) {
			delete m_handler.checkedMap[key];
		}
		
		for (key in m_handler.selectMap) {
			delete m_handler.selectMap[key];
		}

		var x:int = CCommon.stage.mouseX;
		var y:int = CCommon.stage.mouseY;
		trace("click stage x : " + x + ', y' + y);
		for (var i:int = 0; i < m_handler.container.numChildren; i++) {
			var child:CFlatObejct = m_handler.container.getChildAt(i) as CFlatObejct;
			m_checkPoint.x = child.x + m_handler.container.x;
			m_checkPoint.y = child.y + m_handler.container.y;

			m_checkRect.setTo(m_checkPoint.x, m_checkPoint.y, CFlatObejct.SIZE, CFlatObejct.SIZE);
			if (m_checkRect.contains(x, y)) {
				if (child.isLock) {
					m_selectItem = child;
					break;
				}
				
				m_selectItem = child;
				m_isWait = false;
				break;
			}
		}
	}

	private var m_isWait:Boolean;
	private var m_selectItem:CFlatObejct;
}

}

