package core.scene
{
	import core.framework.CBean;
	import core.game.ecsLoop.CGameObject;

	/**
	 * ...
	 * @author
	 */
	public class CSceneObjectList extends CBean {
		public static const TYPE_PC:int = 0;
		public static const TYPE_MONSTER:int = 1;
		public static const TYPE_MAP_OBJECT:int = 2;
		public static const TYPE_NPC:int = 3;

		public function CSceneObjectList(){
			m_typeMapList = [
				new Object(),  // PC
				new Object(), // monsters
				new Object(), // mapObject
				new Object() // npc
			];

			m_all = new Array();
		}
		// ----------------------------
		public function getPlayer(id:Number) : CGameObject {
			var ret:CGameObject = getGameObject(TYPE_PC, id);
			return ret;
		}
		public function addPlayer(id:Number, obj:CGameObject) : void {
			addObject(id, obj, TYPE_PC);
		}
		public function removePlayer(id:Number) : CGameObject {
			return this.removeObject(id, TYPE_PC);
		}
		// ----------------------------
		public function getMonster(id:Number) : CGameObject {
			var ret:CGameObject = getGameObject(TYPE_MONSTER, id);
			return ret;
		}
		public function addMonster(id:Number, obj:CGameObject) : void {
			addObject(id, obj, TYPE_MONSTER);
		}
		public function removeMonster(id:Number) : CGameObject {
			return this.removeObject(id, TYPE_MONSTER);
		}
		// ----------------------------
		public function getNPC(id:Number) : CGameObject {
			var ret:CGameObject = getGameObject(TYPE_NPC, id);
			return ret;
		}
		public function addNPC(id:Number, obj:CGameObject) : void {
			addObject(id, obj, TYPE_NPC);
		}
		public function removeNPC(id:Number) : CGameObject {
			return this.removeObject(id, TYPE_NPC);
		}
		// -----------------------------
		public function getGameObject(type:int, id:Number) : CGameObject {
			var objects:Object = m_typeMapList[type];
			if (objects.hasOwnProperty(id)) {
				var gameObject:CGameObject = objects[id];
				return gameObject;
			}
			return null;
		}
		public function addObject(id:Number, obj:CGameObject, type:int) : void {
			var objects:Object = m_typeMapList[type];
			objects[id] = obj;

			m_all.push(obj);
		}

		public function removeObject(id:Number, type:int) : CGameObject {
			var objects:Object = m_typeMapList[type];
			var obj:CGameObject;
			if (objects.hasOwnProperty(id)) {
				obj = objects[id];
			}
			delete objects[id];

			if (obj) {
				var idx:int = m_all.indexOf(obj);
				if (-1 != idx) {
					m_all.splice(idx, 1);
				}
			}
			return obj;
		}

		private var m_all:Array;
		private var m_typeMapList:Array;
	}

}