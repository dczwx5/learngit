package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CFlatObejct;
import metro.scene.get10Procedure.EGet10ProcedureKey;
import metro.scene.CMetroSceneHandler;
import metro.player.CPlayerData;
import a_core.CCommon;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.scene.CMetroSceneSystem;

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

	private var m_handler:CMetroSceneHandler;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);

		if (!m_handler) {
			m_handler = fsm.system.stage.getSystem(CMetroSceneSystem).getBean(CMetroSceneHandler) as CMetroSceneHandler;		
		}

		var XS:int = CPlayerData.X_SIZE;
		var YS:int = CPlayerData.Y_SIZE;
		var SIZE:int =  CFlatObejct.SIZE;
		trace("XS : " + XS + ", YS : " + YS);

		var xSize:int = XS * SIZE;
		var ySize:int = YS * SIZE;

		m_handler.container.x = (CCommon.screenWidth - xSize)/2;
		m_handler.container.y = (CCommon.screenHeight - ySize)/2;

		var locakXs:Array = [0, 4];

		var xIndex:int = 0;
		var count:int = XS * YS;
		for (var i:int = 0; i < count; i++) {
			var flat:CFlatObejct = m_handler.pool.createObject() as CFlatObejct;
			flat.value = m_handler.createNewValue();
			flat.index = i;
			xIndex = flat.getIndexX();
			if (-1 != locakXs.indexOf(xIndex)) {
				flat.isLock = true;
			} else {
				flat.isLock = false;
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
 
}

}

