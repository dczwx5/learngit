package core.game
{
	import core.framework.CAppSystem;
	import core.scene.CSceneSystem;
	import core.game.ecsLoop.CECSLoop;
	import core.scene.CSceneEvent;
	import core.game.ecsLoop.CGameObject;
	import core.character.CCharacterSystem;
	import core.character.builder.CCharacterBuilder;

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
			// test data
			spawnCharacter({ID:1, type:0, skin:"1001", defAni:"die", x:300, y:100});
			spawnCharacter({ID:2, type:0, skin:"1001", defAni:"idle", x:300, y:300});
			spawnCharacter({ID:3, type:0, skin:"1001", defAni:"move", x:500, y:300});
		}

		
		public function spawnCharacter(data:Object) : void {
			var gameObj:CGameObject = m_pCharacterSystem.characterPool.createObject();
			var characterBuilder:CCharacterBuilder = m_pCharacterSystem.getBean(CCharacterBuilder) as CCharacterBuilder;
			characterBuilder.build(gameObj, data);

			m_pSceneSystem.spawnCharacter(gameObj); // spawn不是即时, 需要等　characterAdded
		}
		private function _onSceneChacterAdded(...characters) : void {
			for each (var character:CGameObject in characters) {
				m_pEcsLoop.addObject(character);
			}
		}

		public function removeCharacter(obj:CGameObject) : void {
			m_pSceneSystem.removeCharacter(obj);
			m_pEcsLoop.removeObject(obj);
		}

		private var m_pSceneSystem:CSceneSystem;
		private var m_pCharacterSystem:CCharacterSystem;
		private var m_pEcsLoop:CECSLoop;

	}

}