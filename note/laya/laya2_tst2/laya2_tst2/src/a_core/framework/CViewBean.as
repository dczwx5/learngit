package a_core.framework
{
	import laya.ui.Box;
	import a_core.framework.IUICanvas;
	import laya.net.Loader;
	import laya.utils.Handler;
	import laya.ui.Dialog;

	/**
	 * ...
	 * @author auto
	 */
	public class CViewBean extends CBean {
		public static const EVENT_OK:String = "ok";
		public static const EVENT_CANCEL:String = "cancel";
		
		public static const EVENT_LOAD_PROGRESS:String = "load_progress";
		public static const EVENT_SHOWED:String = "showed";
		public static const EVENT_HIDED:String = "hided";
		
		public function CViewBean(){
			m_viewState = STATE_UNREADY;
		}

		// -----------------------------------------------------------------------------

		private var m_isDirty:Boolean = false;
		public function get isDirty() : Boolean {
			return m_isDirty;
		}
		public function invalidate() : void {
			m_isDirty = true;
		}
		// system的update中调用
		public virtual function updateData() : void {
			m_isDirty = false;
		}

		// -----------------------------------------------------------------------------
		protected override function onAwake() : void {
			super.onAwake();

			uiSystem.registry(this);
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
		protected override function onDestroy() : void {
			super.onDestroy();

			m_pUISystem = null;
			m_showHandler = null;
			m_viewState = STATE_UNREADY;
		}

		// ==========================================================================
		public virtual function get viewID() : int {
			return -1;
		}
		protected virtual function _viewRes() : Array {
			return null;
		}   
		protected virtual function _soundRes() : Array {
			return null;
		}
		public final function show(pShowHandler:Handler = null) : void {
			m_viewState = STATE_LOADING;
			showHandler = pShowHandler;

			var loadRes:Array;
			var viewRes:Array = _viewRes();
			loadRes = viewRes;
			var soundRes:Array = _soundRes();
			if (soundRes && soundRes.length > 0) {
				for each (var soundData:Object in soundRes) {
					if (false == soundData.hasOwnProperty("type")) {
						soundData["type"] = Loader.SOUND;
					}
				}
				if (loadRes) {
					loadRes.concat(soundRes);
				} else {
					loadRes = soundRes;
				}
			}
			if (loadRes && loadRes.length > 0) {
				Laya.loader.load(loadRes, Handler.create(this, _onComplete), Handler.create(this, _onProgress));
			} else {
				_onComplete();
			}
		}
		/**
		 * 游戏资源加载完成
		 */
		protected function _onComplete() : void {
			_onShow();
			event(EVENT_SHOWED);			
			m_viewState = STATE_SHOWING;
		}
		protected virtual function _onShow() : void {

		}
		
		/**
		 * 游戏资源加载进度
		 * @param loadNum  进度
		 */
		protected function _onProgress(loadNum:Number) : void {
			event(EVENT_LOAD_PROGRESS);
		}

		public function hide() : void {
			_onHide();
			event(EVENT_HIDED);
			m_viewState = STATE_HIDED;
		}
		protected virtual function _onHide() : void {
			
		}

		// ==========================================================================	

		public function addToRoot(comp:Box) : void {
			uiSystem.addToRoot(comp);
		}
		public function addToView(comp:Box) : void {
			uiSystem.addToView(comp);
		}
		public function addToDialog(dialog:Dialog) : void {
			uiSystem.addToDialog(dialog );
		}
		public function addToPopupDialog(dialog:Dialog) : void {
			uiSystem.addToPopupDialog(dialog);
		}
		public function addToLoading(comp:Box) : void {
			uiSystem.addToLoading(comp);
		}

		public function get uiSystem() : IUICanvas {
			if (m_pUISystem == null) {
				m_pUISystem = system.stage.getSystem(IUICanvas) as IUICanvas;
			}
			return m_pUISystem;
		}


		public function get isUnReadyState() : Boolean {
			return STATE_UNREADY == m_viewState;
		}
		public function get isLoadingState() : Boolean {
			return STATE_LOADING == m_viewState;
		}
		public function get isShowingState() : Boolean {
			return STATE_SHOWING == m_viewState;
		}
		public function get isHidedState() : Boolean {
			return STATE_HIDED == m_viewState;
		}

		public function get showHandler() : Handler {
			return m_showHandler;
		}
		public function set showHandler(v:Handler) : void {
			m_showHandler = v;
		}
		private var m_showHandler:Handler;

		protected static const STATE_UNREADY:int = -1;
		protected static const STATE_LOADING:int = 0;
		protected static const STATE_SHOWING:int = 1;
		protected static const STATE_HIDED:int = 2;
		private var m_viewState:int; 
		private var m_pUISystem:IUICanvas;
		
	}

}