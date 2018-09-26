package core.scene
{
	import core.character.CCharacter;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class CScene {
		public function CScene() {
			
		}

		public function addObjectToLayer(c:CCharacter) : void {
			_sceneLayer.addChild(c);
		}

		private var _sceneLayer:Sprite;
	}

}