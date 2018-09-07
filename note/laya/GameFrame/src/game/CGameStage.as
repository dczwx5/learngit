package game
{
	import core.framework.CAppStage;

	import game.login.CLoginSystem;
	import game.player.CPlayerSystem;
	import game.lobby.CLobbySystem;
	import game.scene.CSceneSystem;
	import game.CGameStage;
	import laya.display.Stage;
	import core.game.sequentiaProcedure.CSequentiaProcedureSystem;
	import core.game.fsm.CFsmSystem;
	import game.procedure.CProcedureSystem;
	import game.instance.CInstanceSystem;
	import game.view.CUISystem;
	import core.game.data.CDatabaseSystem;
	import game.CTableConstant;
	/**
	 * ...
	 * @author auto
	 */
	public class CGameStage extends CAppStage {
		private static var m_stage:CGameStage;
		
		public static function getInstance() : CGameStage {
			if (m_stage == null) {
				m_stage = new CGameStage();
			}

			return m_stage;
		}

		public function CGameStage() {
			if (m_stage) {
				throw new Error("gamestage is exist");
			} 
		}

		protected override function onAwake() : void {
			super.onAwake();

			this.addSystem(new CFsmSystem());
			this.addSystem(new CSequentiaProcedureSystem());
			this.addSystem(new CDatabaseSystem(CTableConstant.tableList));
			this.addSystem(new CUISystem());

			this.addSystem(new CLoginSystem());
			this.addSystem(new CPlayerSystem());
			this.addSystem(new CLobbySystem());
			this.addSystem(new CSceneSystem());
			this.addSystem(new CInstanceSystem());

			this.addSystem(new CProcedureSystem());
		}
		protected override function onStart() : void {
			super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}
	}

}