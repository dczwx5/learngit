package metro.result
{
	import a_core.framework.CViewBean;
	import metro.EViewType;
	import game.CPathUtils;
	import metro.player.CPlayerData;
	import metro.player.CPlayerSystem;
	import metro.player.CPlayerPropertyCalc;
	import ui.ResultViewUI;
	import laya.events.Event;
	import laya.ui.Image;
	import laya.display.Text;

	/**
	 * ...
	 * @author
	 */
	public class CResultView extends CViewBean {
		public function CResultView(){
			
		}

		public override function get viewID() : int {
			return EViewType.LOBBY;
		}
		protected override function _viewRes() : Array {
			return [CPathUtils.getUIPath("comp")];
			
		}   
		protected override function _soundRes() : Array {
			return null;
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			return super.onStart();
		}
	
		protected override function onDestroy() : void {

			if (m_view) {
				uiSystem.removeView(m_view);
			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			if (!m_view) {
				m_view = new ResultViewUI();			
			}
			uiSystem.addToView(m_view);

			m_isClickRestart = false;

			m_view.reset_btn.on(Event.CLICK, this, _onClickRestart);

			updateData();

		}
		private function _onClickRestart() : void {
			m_isClickRestart = true;
		}
		protected override function _onHide() : void {
			m_isClickRestart = false;
			uiSystem.removeView(m_view);

			m_view.reset_btn.off(Event.CLICK, this, _onClickRestart);

		}

		public override function updateData() : void {
			super.updateData();

			var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
			m_view.top_number_img.loadImage(CPathUtils.getNumber(playerData.topNumber));
			m_view.score_txt.text = playerData.curScore.toString();
			m_view.top_score_txt.text = playerData.topScore.toString();

		}

		public function get view() : ResultViewUI {
			return m_view;
		}
		private var m_view:ResultViewUI;
		
		public function get isClickRestart() : Boolean {
			return m_isClickRestart;
		}
		private var m_isClickRestart:Boolean;
	}

}