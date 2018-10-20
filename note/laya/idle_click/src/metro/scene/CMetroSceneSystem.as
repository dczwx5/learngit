package metro.scene
{
	import metro.scene.CMetroSceneHandler;
	import core.scene.CSceneSystem;
	import core.CCommon;
	import laya.events.Event;
	import core.game.CGameSystem;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerNetHandler;
	import metro.player.CPlayerData;

	/**
	 * ...
	 * @author
	 */
	public class CMetroSceneSystem extends CSceneSystem {
		public function CMetroSceneSystem(){
			
		}
		protected override function onDestroy() : void {
			super.onDestroy();
		}
		protected override function onAwake() : void {
			super.onAwake();

			this.addBean(m_sceneHandler = new CMetroSceneHandler());

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
		
			return ret;
		}

		

		public override function createScene(sceneID:String) : void {
			super.createScene(sceneID);
		}

		public override function get sceneWidth() : Number {
			return 750;
		}
		public override function get sceneHeight() : Number {
			return 733; //1334*0.55;
		}
		
		private var m_sceneHandler:CMetroSceneHandler;
	}

}