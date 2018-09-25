package game.view
{
	import core.framework.CAppSystem;
	import laya.ui.Box;
	import laya.display.Stage;
	import laya.ui.Component;
	import core.framework.IUICanvas;
	import core.framework.CViewBean;
	import laya.utils.Dictionary;
	import game.view.CDialogLayer;
	import laya.ui.DialogManager;
	import laya.ui.Dialog;

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
			
			_addNewLayer(m_uiRoot = new Box());
			_addNewLayer(m_viewLayer = new Box());

			Dialog.manager; // 设置dialog的层级
			
			// _addNewLayer(m_tipsLayer = new Box());
			// _addNewLayer(m_effectLayer = new Box());
			// _addNewLayer(m_tutorLayer = new Box());
			// _addNewLayer(m_msgLayer = new Box());
			_addNewLayer(m_loadingLayer = new Box());

			return true;
		}
		private function _addNewLayer(layer:Box) : void {
			var stage:Stage = Laya.stage;
			stage.addChild(layer);
			m_layerList[m_layerList.length] = Box;
		}
		
		protected override function onDestroy() : void {
			super.onDestroy();

			for (var i:int = 0; i < m_layerList.length; i++) {
				var layer:Box = m_layerList[i];
				layer.removeSelf();
				layer = null;
			}
			m_layerList = null;
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
		
		public function addToRoot(comp:Box) : void {
			m_uiRoot.addChild(comp);
		}
		public function addToView(comp:Box) : void {
			m_viewLayer.addChild(comp);
		}
		public function addToDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void {
			dialg.show(closeOther, showEffect)
		}
		public function addToPopupDialog(dialg:Dialog, closeOther:Boolean = false, showEffect:Boolean = true) : void {
			dialg.popup(closeOther, showEffect);
		}
		public function addToLoading(comp:Box) : void {
			m_loadingLayer.addChild(comp);
		}

		public function closeDialog(dialog:Dialog) : void {
			dialog.close();
		}
		
		private var m_sceneLayer:Box;

		private var m_uiRoot:Box;
		private var m_viewLayer:Box;
		private var m_dialogLayer:CDialogLayer;
		//private var m_tipsLayer:Box;
		//private var m_effectLayer:Box;
		//private var m_tutorLayer:Box;
		//private var m_msgLayer:Box;
		private var m_loadingLayer:Box;

		private var m_layerList:Array;

		// 
		private var m_viewList:Array;
		
	}

}