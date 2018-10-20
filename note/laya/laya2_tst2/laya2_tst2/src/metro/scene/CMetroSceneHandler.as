package metro.scene
{
	import a_core.framework.CBean;
	import laya.ui.Box;
	import laya.display.Node;
	import laya.display.Sprite;
	import game.CPathUtils;
	import laya.ui.Image;
	import laya.d3.animation.AnimationClip;
	import laya.display.Animation;
	import laya.utils.Handler;
	import a_core.CBaseDisplay;
	import a_core.CCommon;
	import metro.player.CPlayerData;
	import metro.scene.CFlatObejct;
	import a_core.pool.CPoolBean;
	import a_core.pool.CPoolSystem;
	import laya.events.Event;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import a_core.game.fsm.CFsmSystem;
	import metro.scene.get10Procedure.CGet10Procedure_Select;
	import a_core.procedure.CProcedureManager;
	import metro.scene.get10Procedure.CGet10Procedure_WaitClick;
	import metro.scene.get10Procedure.CGet10Procedure_NewScene;
	import metro.scene.get10Procedure.CGet10Procedure_Merger;
	import metro.scene.get10Procedure.CGet10Procedure_Fall;
	import metro.scene.get10Procedure.CGet10Procedure_AddNewFlat;
	import metro.scene.get10Procedure.CGet10Procedure_CheckDead;
	import metro.scene.get10Procedure.CGet10Procedure_Dead;
	import metro.scene.CFrameMovie;
	import metro.scene.get10Procedure.CGet10Procedure_MoveToMergeFlat;
	import metro.player.CPlayerSystem;
	import metro.scene.get10Procedure.CGet10Procedure_SelectLock;

	/**
	 * ...
	 * @author auto
	 */
	public class CMetroSceneHandler extends CBean {
		public function CMetroSceneHandler(){

		}

		protected override function onAwake() : void {
			super.onAwake();

		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

			var pPoolSystem:CPoolSystem = system.stage.getSystem(CPoolSystem) as CPoolSystem;
			m_pool = pPoolSystem.addPool("get10Flat", CFlatObejct);

			m_mergeEffect = new CFrameMovie();
			m_mergeEffect.create("skilleff_1");

			return ret;
		}
		protected override function onDestroy() : void {
			var fsmSystem:CFsmSystem = system.stage.getSystem(CFsmSystem) as CFsmSystem;
			if (m_procedureManager) {
				fsmSystem.removeProcedure(m_procedureManager.name);
				m_procedureManager = null;
			}
			super.onDestroy();
		}

		public function releaseScene() : void {
			if (m_pContainer) {
				while (m_pContainer.numChildren > 0) {
					var child:CFlatObejct = m_pContainer.removeChildAt(0) as CFlatObejct;
					m_pool.recoverObject(child);
				}
			}
			m_pContainer = null;

			if (m_pEffectLayer) {
				while (m_pEffectLayer.numChildren > 0) {
					var effect:CFrameMovie = m_pEffectLayer.removeChildAt(0) as CFrameMovie;

				}
			}
			m_pEffectLayer = null;
		}

		public function createScene(container:CBaseDisplay, effectLayer:CBaseDisplay) : void {
			m_pContainer = container;
			m_pEffectLayer = effectLayer;
			m_selectMap = new Object();
			m_checkedMap = new Object();

			var fsmSystem:CFsmSystem = system.stage.getSystem(CFsmSystem) as CFsmSystem;
			var procedureList:Array = [
				new CGet10Procedure_NewScene(), new CGet10Procedure_WaitClick(), 
				new CGet10Procedure_Select(), new CGet10Procedure_MoveToMergeFlat(), new CGet10Procedure_Merger(), new CGet10Procedure_Fall(), 
				new CGet10Procedure_AddNewFlat(), new CGet10Procedure_CheckDead(), new CGet10Procedure_Dead(),
				new CGet10Procedure_SelectLock()
			];
			m_procedureManager = fsmSystem.createProcedure("get10Gaming", procedureList);		
			m_procedureManager.startProcedure(CGet10Procedure_NewScene);
		}
	
		public function getChildByIndex(x:int, y:int) : CFlatObejct {
			return m_pContainer.getChildAt(x + y * CPlayerData.X_SIZE) as CFlatObejct;
		}

		public function resetPosition() : void {
			for (var i:int = 0; i < m_pContainer.numChildren; i++) {
				var flat:CFlatObejct = m_pContainer.getChildAt(i) as CFlatObejct;
				flat.index = i;
			}
		}

		public function createNewValue() : int {
			var ret:int = 0;
			ret = 1 + Math.random() * 4;
			ret = Math.floor(ret);

			return ret;
		}

		public function stop() : void {
			if (m_procedureManager) {
				var fsmSystem:CFsmSystem = system.stage.getSystem(CFsmSystem) as CFsmSystem;
				fsmSystem.removeProcedure(m_procedureManager.name);
				m_procedureManager = null;
			}
		}

		public function calcScore() : int {
			var value:int = 0;
			var count:int = 0;
			for (var key:* in selectMap) {
				var child:CFlatObejct = container.getChildAt(key) as CFlatObejct;
				value = child.value;
				count++;
			}

			value = value * count * count;
			return value;
		}
		public function getOpenCost(indexX:int) : int {
			if (0 == indexX) {
				return 100;
			} else if (4 == indexX) {
				return 200;
			}
			return 0;
		}
		public function canOpen(indexX:int) : Boolean {
			var cost:int = getOpenCost(indexX);
			var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			if (pPlayerSystem.playerData.curScore >= cost) {
				return true;
			}
			return false;
		}
		public function open(indexX:int) : void {
			var cost:int = getOpenCost(indexX);
			var pPlayerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
			if (pPlayerSystem.netHandler.addScore(-cost)) {
				var allFlatInPanel:int = CPlayerData.X_SIZE * CPlayerData.Y_SIZE;
				for (var i:int = 0; i < container.numChildren && i < allFlatInPanel; i++) {
					var flat:CFlatObejct  = container.getChildAt(i) as CFlatObejct;
					if (flat.getIndexX() == indexX) {
						flat.isLock = false;
					}
				}
			}
		}

		public function get selectMap() : Object {
			return m_selectMap;
		}
		public function get checkedMap() : Object {
			return m_checkedMap;
		}
		public function get container() : CBaseDisplay {
			return m_pContainer;
		}
		public function get pool() : CPoolBean {
			return m_pool;
		}

		public function get isDead() : Boolean {
			if (m_procedureManager) {
				return m_procedureManager.currentProcedure is CGet10Procedure_Dead;
			}
			return false;
		}

		public function playMergeEffect(x:int, y:int) : void {
			m_mergeEffect.on(Event.COMPLETE, this, _onPlayFinished);
			m_mergeEffect.play(false);

			m_pEffectLayer.addChild(m_mergeEffect);
			m_mergeEffect.x = x;
			m_mergeEffect.y = y;
			m_mergeEffectEnd = false;
		}
		private function _onPlayFinished() : void {
			m_mergeEffect.off(Event.COMPLETE, this, _onPlayFinished);
			m_pEffectLayer.removeChild(m_mergeEffect);
			m_mergeEffectEnd = true;
		}
		public function get mergeEffectEnd() : Boolean {
			return m_mergeEffectEnd;
		}
		private var m_mergeEffectEnd:Boolean;

		private var m_pContainer:CBaseDisplay;
		private var m_pEffectLayer:CBaseDisplay;

		private var m_pool:CPoolBean;

		private var m_procedureManager:CProcedureManager;

		private var m_selectMap:Object;
		private var m_checkedMap:Object;

		private var m_mergeEffect:CFrameMovie;
	}

}