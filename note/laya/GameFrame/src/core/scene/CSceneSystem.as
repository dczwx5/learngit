package core.scene
{
	import core.framework.CAppSystem;
	import core.scene.CSceneObjectList;
	import core.scene.CSceneRendering;
	import core.scene.CSceneSpawnHandler;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CCharacterProperty;

	/**
	 * ...
	 * @author
	 */
	public class CSceneSystem extends CAppSystem {
		public function CSceneSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();

			this.addBean(m_sceneSpawnHandler = new CSceneSpawnHandler(_onSpawnCharacter));
			this.addBean(m_sceneRendering = new CSceneRendering());
			this.addBean(m_sceneObjectList = new CSceneObjectList());
		}
	
		protected override function onDestroy() : void {
			super.onDestroy();
		}

		public virtual function createScene(sceneID:String) : void {
			m_sceneRendering.createScene(sceneID);
		}
		public function spawnCharacter(c:CGameObject) : void {
			m_sceneSpawnHandler.addCharacter(c);
		}
		private function _onSpawnCharacter(...characters) : void {
			for each (var character:CGameObject in characters) {
				var propertyData:CCharacterProperty = character.getComponentByClass(CCharacterProperty) as CCharacterProperty;
				m_sceneObjectList.addObject(propertyData.ID, character, propertyData.type);
			}
		}
		public function removeCharacter(c:CGameObject) : void {
			m_sceneSpawnHandler.removeCharacter(c);

			var propertyData:CCharacterProperty = c.getComponentByClass(CCharacterProperty) as CCharacterProperty;
			m_sceneObjectList.removeObject(propertyData.ID, propertyData.type);
		}

		private var m_sceneSpawnHandler:CSceneSpawnHandler;
		private var m_sceneRendering:CSceneRendering;
		private var m_sceneObjectList:CSceneObjectList;
	}

}