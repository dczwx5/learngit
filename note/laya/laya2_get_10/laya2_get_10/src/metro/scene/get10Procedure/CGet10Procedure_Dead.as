package metro.scene.get10Procedure
{
import a_core.procedure.CProcedureBase;
import a_core.fsm.CFsm;
import metro.scene.CMetroSceneHandler;
import laya.maths.Rectangle;
import laya.maths.Point;
import a_core.CCommon;
import metro.scene.flat.CFlatObejct;
import laya.events.Event;
import metro.scene.get10Procedure.CGet10Procedure_Select;
import metro.scene.CMetroSceneSystem;
import metro.scene.get10Procedure.CGet10Procedure_NewScene;
import metro.player.CPlayerData;
import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
import metro.CMetroGameSystem;
import metro.player.CPlayerSystem;

/**
	* ...
	* @author
	*/
public class CGet10Procedure_Dead extends CProcedureBase {
	public function CGet10Procedure_Dead(){
		
	}

	protected override function onInit(fsm:CFsm) : void {
		super.onInit(fsm);
		
	}
	private var m_handler:CMetroSceneHandler;
	protected override function onEnter(fsm:CFsm) : void {
		super.onEnter(fsm);

		(fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.updateTopScore(); 
	}
}

}

