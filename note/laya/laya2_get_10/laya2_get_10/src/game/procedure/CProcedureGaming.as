package game.procedure
{
	import a_core.procedure.CProcedureBase;
	import a_core.fsm.CFsm;
	import a_core.scene.CSceneSystem;
	import a_core.game.CGameSystem;
	import metro.lobby.CLobbySystem;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerNetHandler;
	import game.scene.ESceneID;
	import metro.CMetroGameSystem;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureGaming extends CProcedureBase {
		public function CProcedureGaming(){
			
		}

		protected override function onInit(fsm:CFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:CFsm) : void {
			super.onEnter(fsm);

			var pPlayerSystem:CPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			(pPlayerSystem.getBean(CPlayerNetHandler) as CPlayerNetHandler).onData(); // for test

			var pGameSystem:CMetroGameSystem = fsm.system.stage.getSystem(CMetroGameSystem) as CMetroGameSystem;
			pGameSystem.createScene("1111");
		}
		protected override function onUpdate(fsm:CFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);

			var pGameSystem:CMetroGameSystem = fsm.system.stage.getSystem(CMetroGameSystem) as CMetroGameSystem;
			if (pGameSystem.isDead) {
				pGameSystem.stop();
				fsm.setData(EProcedureKey.NEXT_SCENE_ID, ESceneID.RESULT);
				changeProcedure(fsm, CProcedureChangeScene);
			}
 
		}
		protected override function onLeave(fsm:CFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:CFsm) : void {
			super.onDestroy(fsm);
		}
	}

}