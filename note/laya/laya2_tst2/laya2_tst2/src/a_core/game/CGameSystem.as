package a_core.game
{
	import a_core.framework.CAppSystem;
	import a_core.scene.CSceneSystem;
	import a_core.game.ecsLoop.CECSLoop;
	import a_core.scene.CSceneEvent;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.CCharacterSystem;
	import a_core.character.builder.CCharacterBuilder;
	import a_core.character.CPlayHandler;

	/**
	 * ...
	 * @author auto

	 控制scene, character
	 */
	public class CGameSystem extends CAppSystem {
		public function CGameSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			m_pCharacterSystem = stage.getSystem(CCharacterSystem) as CCharacterSystem;
			m_pSceneSystem = stage.getSystem(CSceneSystem) as CSceneSystem;
			m_pEcsLoop = stage.getSystem(CECSLoop) as CECSLoop;

			m_pSceneSystem.on(CSceneEvent.EVENT_CHARACTER_ADDED, this, _onSceneChacterAdded);

			return ret;
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();

			if (m_pSceneSystem) {
				m_pSceneSystem.off(CSceneEvent.EVENT_CHARACTER_ADDED, this, _onSceneChacterAdded)		
				m_pSceneSystem = null;
			}

			m_pEcsLoop = null;
		}

		public function createScene(sceneID:String) : void {
			m_pSceneSystem.createScene(sceneID);
		
		}
		public function spawnCharacter(data:Object) : CGameObject {
			var gameObj:CGameObject = m_pCharacterSystem.characterPool.createObject();
			var characterBuilder:CCharacterBuilder = m_pCharacterSystem.getBean(CCharacterBuilder) as CCharacterBuilder;
			characterBuilder.build(gameObj, data);

			m_pSceneSystem.spawnCharacter(gameObj); // spawn不是即时, 需要等　characterAdded
			return gameObj;
		}
		private function _onSceneChacterAdded(...characters) : void {
			for each (var character:CGameObject in characters) {
				m_pEcsLoop.addObject(character);
			}
		}

		public function removeCharacter(obj:CGameObject) : void {
			m_pSceneSystem.removeCharacter(obj);
			m_pEcsLoop.removeObject(obj);
			m_pCharacterSystem.characterPool.recoverObject(obj);
		}

		private var m_pSceneSystem:CSceneSystem;
		private var m_pCharacterSystem:CCharacterSystem;
		private var m_pEcsLoop:CECSLoop;

	}

}