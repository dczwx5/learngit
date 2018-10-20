package game.view
{
	import a_core.framework.CAppSystem;
	import laya.display.Stage;
	import a_core.framework.IUICanvas;
	import a_core.framework.CViewBean;
	import game.view.CDialogLayer;
	import laya.ui.DialogManager;
	import laya.ui.Dialog;
	import laya.ui.View;
	import a_core.framework.IUpdate;
	import laya.display.Sprite;

	/**
	 * ...
	 * @author
	 */
	public class CUISystem extends CAppSystem implements IUICanvas {
		public function CUISystem(){
			m_viewList = new Array();
		}

	

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();
			
			m_layerList = new Array();
			
			m_uiRoot = new Sprite();
			_addNewLayer(m_viewLayer = new Sprite());
			
			// _addNewLayer(m_tipsLayer = new Box());
			// _addNewLayer(m_effectLayer = new Box());
			// _addNewLayer(m_tutorLayer = new Box());
			// _addNewLayer(m_msgLayer = new Box());
			_topLayer = new Sprite();
			_addToTopLayer(m_loadingLayer = new Sprite());

			return true;
		}
		private function _addNewLayer(layer:Sprite) : void {
			m_uiRoot.addChild(layer);
			m_layerList[m_layerList.length] = layer;
		}
		private function _addToTopLayer(layer:Sprite) : void {
			_topLayer.addChild(layer);
			m_layerList[m_layerList.length] = layer;
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();

			for (var i:int = 0; i < m_layerList.length; i++) {
				var layer:Sprite = m_layerList[i];
				layer.removeSelf();
				layer = null;
			}
			m_layerList = null;

			m_uiRoot.removeSelf();
			m_uiRoot = null;
		}
		
		// ============================================================
		// 允许多个相同ＩＤ的view , 自行管理
		public function registry(view:CViewBean) : void {
			m_viewList.push(view);
		}
		public function getView(viewID:int) : CViewBean {
			if (viewID == -1) {
				throw new Error("CUISystem.getView : viewID is invalid")
				return null;
			}
			for each (var view:CViewBean in m_viewList) {
				if (view.viewID == viewID) {
					return view;
				}
			}
			return null;
		}
		public function hasView(viewID:int) : Boolean {
			return getView(viewID) != null;
		}
		public function isViewShowing(viewID:int) : Boolean {
			var view:CViewBean = getView(viewID);
			var ret:Boolean = view && view.isShowingState;
			return ret;
		}
		public function isViewLoading(viewID:int) : Boolean {
			var view:CViewBean = getView(viewID);
			var ret:Boolean = view && view.isLoadingState;
			return ret;
		}
		public function isViewHided(viewID:int) : Boolean {
			var view:CViewBean = getView(viewID);
			var ret:Boolean = view && view.isHidedState;
			return ret;
		}

		// ============================================================
		
		public function addToRoot(comp:Sprite) : void {
			m_uiRoot.addChild(comp);
		}
		public function addToView(comp:Sprite) : void {
			m_viewLayer.addChild(comp);
		}
		public function addToDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void {
			dialg.show(closeOther, showEffect)
		}
		public function addToPopupDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void {
			dialg.popup(closeOther, showEffect);
		}
		public function addToLoading(comp:Sprite) : void {
			m_loadingLayer.addChild(comp);
		}

		public function closeDialog(dialog:Dialog) : void {
			dialog.close();
		}
		public function removeView(view:Sprite) : void {
			m_viewLayer.removeChild(view);
		}

		public function set container(v:Sprite) : void {
			if (_container) {
				while (_container.numChildren) {
					_container.removeChildAt(0);
				}
				_container = null;
			}
			_container = v;
			_container.addChild(m_uiRoot);
		}

		public function set topLayer(v:Sprite) : void {
			if (_topContainer) {
				while (_topContainer.numChildren) {
					_topContainer.removeChildAt(0);
				}
				_topContainer = null;
			}
			_topContainer = v;
			_topContainer.addChild(_topLayer);
		}
		private var _topContainer:Sprite; // dialog之上的layer
		private var _container:Sprite;
		
		private var m_uiRoot:Sprite; // dialog之下的layer
		private var _topLayer:Sprite; // dialog之上的layer

		private var m_viewLayer:Sprite;
		private var m_dialogLayer:CDialogLayer;
		//private var m_tipsLayer:Box;
		//private var m_effectLayer:Box;
		//private var m_tutorLayer:Box;
		//private var m_msgLayer:Box;
		private var m_loadingLayer:Sprite;

		private var m_layerList:Array;

		// 
		private var m_viewList:Array;
		
	}

}