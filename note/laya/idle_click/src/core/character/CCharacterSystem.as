package core.character
{
	import core.framework.CAppSystem;
	import core.character.builder.CCharacterBuilder;
	import core.pool.CPoolBean;
	import core.pool.CPoolSystem;
	import core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public class CCharacterSystem extends CAppSystem {
		public function CCharacterSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			addBean(new CCharacterBuilder());
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			m_pCharacterPool = (stage.getSystem(CPoolSystem) as CPoolSystem).addPool("character", CGameObject);

			return ret;
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public function get characterPool() : CPoolBean {
			return m_pCharacterPool;
		}

		private var m_pCharacterPool:CPoolBean;
	}

}