package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.flat.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import a_core.CCommon;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.scene.CMetroSceneSystem;
import metro.player.CPlayerSystem;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_NewScene extends CProcedureBase {
	public function CGet10Procedure_NewScene(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);

		
	}

	private static const FLAT_INIT_LIST:Array = [
		0, 0, 0, 0, 0, 0, 0, 
		0, 1, 1, 1, 1, 1, 0, 
		0, 1, 2, 2, 2, 2, 0, 
		0, 1, 2, 2, 2, 2, 0, 
		0, 1, 2, 2, 2, 2, 0, 
		0, 1, 2, 2, 2, 2, 0, 
		0, 0, 0, 0, 0, 0, 0, 
		0, 0, 0, 0, 0, 0, 0, 

	]
	private static const FLAT_LOCK_STEP:Array = [
		1, 1, 1, 1, 1, 1, 1, 
		1, 0, 0, 0, 0, 0, 1, 
		1, 0, 0, 0, 0, 0, 1, 
		1, 0, 0, 0, 0, 0, 1, 
		1, 0, 0, 0, 0, 0, 1, 
		1, 0, 0, 0, 0, 0, 1, 
		1, 1, 1, 1, 1, 1, 1, 
		2, 2, 2, 2, 2, 2, 2, 

	]
	private var m_handler:CMetroSceneHandler;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);

		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}
		if (!m_pPlayerSystem) {
			m_pPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
		}

		var XS:int = CPlayerData.X_SIZE;
		var YS:int = CPlayerData.Y_SIZE;
		var SIZE:int =  CFlatObejct.SIZE;

		var xSize:int = XS * SIZE;
		var ySize:int = YS * SIZE;

		m_handler.container.x = (CCommon.screenWidth - xSize)/2;
		m_handler.container.y = (CCommon.screenHeight - ySize)/2;

		var count:int = XS * YS;
		for (var i:int = 0; i < count; i++) {
			var state:int = 0;
			if (i >= FLAT_INIT_LIST.length) {
				state = CFlatObejct.STATE_READY;// 显示出来排错
			} else {
				state = FLAT_INIT_LIST[i];
			}
			var value:int = m_pPlayerSystem.playerData.createNewValue();
			var index:int = i;
			var flat:CFlatObejct = m_handler.flatBuilder.build(state, value, index) as CFlatObejct;
			if (i >= FLAT_LOCK_STEP.length) {
				flat.lockStep = CPlayerData.OPEN_LOCK_STEP_0;
			} else {
				flat.lockStep = FLAT_LOCK_STEP[i];
			}
			m_handler.container.addChild(flat);
		} 
	}
	protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
		super.onUpdate(fsm, deltaTime);

		changeProcedure(fsm, CGet10Procedure_WaitClick);
	}
	protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
		super.onLeave(fsm, isShutDown);
	}
	protected override function onDestroy(fsm:CFsm) : void {
		super.onDestroy(fsm);

		m_handler = null;
	}

	private var m_pPlayerSystem:CPlayerSystem;
 
}

}

