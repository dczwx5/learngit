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
	import core.scene.CSceneEvent;
	import core.scene.ISceneFacade;
	import core.character.display.IDisplay;

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

		private var m_sceneSpawnHandler:CSceneSpawnHandler;
		private var m_sceneRendering:CSceneRendering;
		private var m_sceneObjectList:CSceneObjectList;
	}

}