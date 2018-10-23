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
	import script.CNumberView;
	import laya.utils.Handler;
	import laya.components.Component;
	import ui.ResultPlayerItemUI;

	/**
	 * ...
	 * @author
	 */
	public class CResultView extends CViewBean {
		public function CResultView(){
			
		}

		public override function get viewID() : int {
			return EViewType.RESULT;
		}
		protected override function _viewRes() : Array {
			return null;
			
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
				m_view.playerList.renderHandler = null;

			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			if (!m_view) {
				m_view = new ResultViewUI();
				// (m_view.getChildByName("numberView") as CNumberView).align = CNumberView.ALIGN_CENTER;
				m_view.playerList.itemRender = ResultPlayerItemUI;
				m_view.playerList.renderHandler = new Handler(this, _onFriendRenderItem);// Handler.create(this, _onFriendRenderItem, null, false);		
			}
			uiSystem.addToView(m_view);

			m_isClickRestart = false;

			m_view.reset_btn.on(Event.CLICK, this, _onClickRestart);
			m_view.rank_btn.on(Event.CLICK, this, _onRankClick);

			updateData(0);

		}
		private function _onClickRestart() : void {
			m_isClickRestart = true;
		}
		private function _onRankClick() : void {
			event('rank');
		}
		protected override function _onHide() : void {
			m_isClickRestart = false;
			uiSystem.removeView(m_view);

			m_view.reset_btn.off(Event.CLICK, this, _onClickRestart);
			m_view.rank_btn.off(Event.CLICK, this, _onRankClick);

		}

		public override function updateData(delta:Number) : void {
			super.updateData(delta);

			var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
			//m_view.top_number_img.loadImage(CPathUtils.getNumber(playerData.topNumber));
			//m_view.score_txt.text = playerData.curScore.toString();
			m_view.top_score_txt.text = playerData.topScore.toString();
			(m_view.getChildByName("numberView") as CNumberView).num = playerData.curScore;
			m_view.playerList.array = [{"name":"auto", "score":10000, "rank":1}, {"name":"sbbob", "score":9980, "rank":2}, {"name":"sbkk", "score":5000, "rank":3}];
			

		}
		private function _onFriendRenderItem(comp:Component, idx:int) : void {
			var item:ResultPlayerItemUI = comp as ResultPlayerItemUI;
			var data:Object = item.dataSource;
			// if (!data) {
			// 	item.visible = false;
			// 	return ;
			// }
			item.visible = true;

			item.player_name_txt.text = data['name'];
			item.rank_txt.text = data['rank'].toString();
			item.score_txt.text = data['score'].toString();
			
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