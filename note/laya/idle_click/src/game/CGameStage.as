package game
{
	import core.framework.CAppStage;

	import game.login.CLoginSystem;
	import game.CGameStage;
	import laya.display.Stage;
	import core.game.sequentiaProcedure.CSequentiaProcedureSystem;
	import core.game.fsm.CFsmSystem;
	import game.procedure.CProcedureSystem;
	import game.instance.CInstanceSystem;
	import game.view.CUISystem;
	import core.game.data.CDatabaseSystem;
	import game.CTableConstant;
	import core.sound.CSoundSystem;
	import core.pool.CPoolSystem;
	import metro.scene.CMetroSceneSystem;
	import metro.CMetroBoostSystem;
	import core.character.CCharacterSystem;
	import core.game.ecsLoop.CECSLoop;
	import core.game.CGameSystem;
	import metro.lobby.CLobbySystem;
	import metro.player.CPlayerSystem;
	import metro.CMetroGameSystem;
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

			this.addSystem(new CPoolSystem());
			this.addSystem(new CFsmSystem());
			this.addSystem(new CSequentiaProcedureSystem());
			this.addSystem(new CDatabaseSystem(CTableConstant.tableList));

			this.addSystem(new CSoundSystem());
			
			this.addSystem(new CUISystem());

			this.addSystem(new CCharacterSystem());
			this.addSystem(new CECSLoop());

			this.addSystem(new CLoginSystem());
			this.addSystem(new CPlayerSystem());
			this.addSystem(new CLobbySystem());
			this.addSystem(new CMetroSceneSystem());
			this.addSystem(new CInstanceSystem());

			this.addSystem(new CProcedureSystem());

			this.addSystem(new CMetroGameSystem());
			// 
			this.addSystem(new CBoostSystem());

			//
			this.addSystem(new CMetroBoostSystem());
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}
	}

}