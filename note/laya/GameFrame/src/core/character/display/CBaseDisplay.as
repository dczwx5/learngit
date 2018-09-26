package core.character.display
{
	import core.character.CCharacter;
	import core.game.ecsLoop.CGameComponent;

	/**
	 * ...
	 * @author
	 */
	public class CBaseDisplay extends CGameComponent implements IDisplay {
		private var m_pModelDisplay:CCharacter;
		public function CBaseDisplay(){
			
		}
		public override function dispose() : void {
			super.dispose();

			if (m_pModelDisplay) {
				m_pModelDisplay.dispose();
				m_pModelDisplay = null;
			}
		}

		override protected virtual function onExit() : void {
			super.onExit();

			if (m_pModelDisplay) {
				m_pModelDisplay.dispose();
			}
			m_pModelDisplay = null;
		}

		final public function get modelDisplay() : CCharacter {
			return m_pModelDisplay;
		}
	}

}