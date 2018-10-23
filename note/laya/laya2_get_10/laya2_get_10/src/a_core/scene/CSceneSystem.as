package a_core.scene
{
	import a_core.framework.CAppSystem;
	import a_core.scene.CSceneObjectList;
	import a_core.scene.CSceneRendering;
	import a_core.scene.CSceneSpawnHandler;
	import a_core.game.ecsLoop.CGameObject;
	import a_core.character.property.CCharacterProperty;
	import a_core.framework.IUpdate;
	import a_core.framework.CLifeCycle;
	import laya.utils.Handler;
	import a_core.scene.CSceneEvent;
	import a_core.scene.ISceneFacade;
	import a_core.character.display.IDisplay;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class CSceneSystem extends CAppSystem implements IUpdate, ISceneFacade {
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

		public override function update(delta:Number) : void {			
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
				event(CSceneEvent.EVENT_CHARACTER_ADDED, character);
			}
		}
		public function removeCharacter(c:CGameObject) : void {
			m_sceneSpawnHandler.removeCharacter(c);

			var propertyData:CCharacterProperty = c.getComponentByClass(CCharacterProperty) as CCharacterProperty;
			m_sceneObjectList.removeObject(propertyData.ID, propertyData.type);
		}


		public function get sceneWidth() : Number {
			return 750;
		}
		public function get sceneHeight() : Number {
			return 1334;
		}
		public function isBlock(x:Number, y:Number) : Boolean {
			var ret:Boolean = false;
		
			return ret;
		}
		public function isInArea(x:Number, y:Number, obj:CGameObject = null) : Boolean {
			var ret:Boolean = true;

			if (x < 0 || y < 0) {
				return false;
			}

			var rWidth:Number = 0;
			var rHeight:Number = 0;
			if (obj) {
				var display:IDisplay = obj.getComponentByClass(IDisplay) as IDisplay;
				rWidth = display.displayObject.getWidth();
				rHeight = display.displayObject.getHeight();
			}

			if (x+rWidth > sceneWidth || y+rHeight > sceneHeight) {
				return false;
			}
			return ret;
		}

		public function get sceneRendering() : CSceneRendering {
			return m_sceneRendering;
		}
		public function set sceneContainer(c:Sprite) : void {
			if (m_container) {
				m_container.removeChild(m_sceneRendering.displayerObject);
				m_container = null;
			}
			m_container = c;
			c.addChild(m_sceneRendering.displayerObject);
		}

		private var m_container:Sprite;
		private var m_sceneSpawnHandler:CSceneSpawnHandler;
		private var m_sceneRendering:CSceneRendering;
		private var m_sceneObjectList:CSceneObjectList;
	}

}