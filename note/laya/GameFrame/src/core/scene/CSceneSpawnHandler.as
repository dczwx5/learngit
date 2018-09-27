package core.scene
{
	import core.game.ecsLoop.CGameObject;
	import core.framework.CBean;
	import core.framework.IUpdate;
	import core.scene.CSceneRendering;
	import core.character.CSceneObject;
	import core.character.display.IDisplay;

	/**
	 * ...
	 * @author
	 */
	public class CSceneSpawnHandler extends CBean implements IUpdate {
		private var m_pSceneRendering:CSceneRendering;
		private var m_pSceneObjectList:CSceneObject;
		private var m_spawnQueue:Vector.<CGameObject>;

		private var m_maxSpawnCountPerFrame:int;

		private var _onSpawnCharacterHandler:Function;

		public function CSceneSpawnHandler(onSpawnCharacterHandler:Function, maxSpawnCountPerFrame:int = 15){
			m_maxSpawnCountPerFrame = maxSpawnCountPerFrame;
			_onSpawnCharacterHandler = onSpawnCharacterHandler;
		}

		override protected function onDestroy() : void {
			super.onDestroy();

			m_pSceneRendering = null;
		}

		override protected function onStart() : Boolean {
			var ret:Boolean = super.onStart();
			
			return ret;
		}

		public function addCharacter(c:CGameObject) : void {
			if (!c) {
				return ;
			}

			m_spawnQueue.push(c);
		}

		public function removeCharacter(c:CGameObject) : void {
			if (!c) {
				return ;
			}

			var idx:int = m_spawnQueue.indexOf(c);
			if (-1 != idx) {
				m_spawnQueue.splice(idx, 1);
			}
		}

		public function update(dleta:Number) : void {
			if (!m_pSceneRendering) {
				return ;
			}

			if (!m_pSceneRendering.isReady) {
				return ;
			}
			if (m_spawnQueue.length == 0) {
				return ;
			}

			var counter:int = 0;
			for (var i:int = 0; i < m_spawnQueue.length; i++) {
				var obj:CGameObject = m_spawnQueue[i];
				if (obj) {
					spawnObject(obj);
					_onSpawnCharacterHandler(obj);
				}

				++counter;

				if (counter >= m_maxSpawnCountPerFrame) {
					break;
				}
			}

			if (counter > 0) {
				m_spawnQueue.splice(0, counter);
			}
		}

		protected function spawnObject(character:CGameObject) : void {
			var display:IDisplay = character.findComponentByClass(IDisplay) as IDisplay;
			if (display) {
				m_pSceneRendering.addDisplayObject(display.displayObject);
			}
		}
	}

}