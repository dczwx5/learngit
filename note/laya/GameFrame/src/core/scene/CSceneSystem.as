package core.scene
{
	import core.framework.CAppSystem;
	import core.scene.CSceneObjectList;
	import core.scene.CSceneRendering;
	import core.scene.CSceneSpawnHandler;
	import core.game.ecsLoop.CGameObject;
	import core.character.property.CCharacterProperty;
	import core.framework.IUpdate;
	import core.framework.CLifeCycle;
	import laya.utils.Handler;

	/**
	 * ...
	 * @author
	 */
	public class CSceneSystem extends CAppSystem implements IUpdate {
		public function CSceneSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();

			this.addBean(m_sceneSpawnHandler = new CSceneSpawnHandler(Handler.create(this, _onSpawnCharacter, null, false)));
			this.addBean(m_sceneRendering = new CSceneRendering());
			this.addBean(m_sceneObjectList = new CSceneObjectList());
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			

			return ret;
		}

		public function update(delta:Number) : void {
			var beans:Vector.<CLifeCycle> = getBeans();
			for each (var bean:CLifeCycle in beans) {
				if (bean is IUpdate) {
					(bean as IUpdate).update(delta);
				}
			}
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