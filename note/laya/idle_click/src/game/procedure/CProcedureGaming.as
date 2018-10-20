package game.procedure
{
	import core.procedure.CProcedureBase;
	import core.fsm.IFsm;
	import core.scene.CSceneSystem;
	import core.game.CGameSystem;
	import metro.lobby.CLobbySystem;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerNetHandler;

	/**
	 * ...
	 * @author
	 */
	public class CProcedureGaming extends CProcedureBase {
		public function CProcedureGaming(){
			
		}

		protected override function onInit(fsm:IFsm) : void {
			super.onInit(fsm);
		}
		protected override function onEnter(fsm:IFsm) : void {
			super.onEnter(fsm);

			var pPlayerSystem:CPlayerSystem = fsm.system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			(pPlayerSystem.getBean(CPlayerNetHandler) as CPlayerNetHandler).onData(); // for test

			var pGameSystem:CGameSystem = fsm.system.stage.getSystem(CGameSystem) as CGameSystem;
			pGameSystem.createScene("1111");

			var pLobbySystem:CLobbySystem = fsm.system.stage.getSystem(CLobbySystem) as CLobbySystem;
			pLobbySystem.showLobby();

		}
		protected override function onUpdate(fsm:IFsm, deltaTime:Number) : void {
			super.onUpdate(fsm, deltaTime);
		}
		protected override function onLeave(fsm:IFsm, isShutDown:Boolean) : void {
			super.onLeave(fsm, isShutDown);
		}
		protected override function onDestroy(fsm:IFsm) : void {
			super.onDestroy(fsm);
		}
	}

}