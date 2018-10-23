package metro.rank
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
	import ui.RankViewUI;
	import ui.RankItemUI;

	/**
	 * ...
	 * @author
	 */
	public class CRankView extends CViewBean {
		public function CRankView(){
			
		}

		public override function get viewID() : int {
			return EViewType.RANK;
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
				m_view.player_list.renderHandler = null;

			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			if (!m_view) {
				m_view = new RankViewUI();
				// (m_view.getChildByName("numberView") as CNumberView).align = CNumberView.ALIGN_CENTER;
				m_view.player_list.itemRender = RankItemUI;
				m_view.player_list.vScrollBarSkin = '';
				m_view.player_list.renderHandler = new Handler(this, _onPlayerRenderItem);// Handler.create(this, _onPlayerRenderItem, null, false);	
			}
			uiSystem.addToView(m_view);

			m_view.return_btn.on(Event.MOUSE_UP, this, _onReturn);

			updateData(0);

		}
		
		protected override function _onHide() : void {
			m_view.return_btn.off(Event.MOUSE_UP, this, _onReturn);

			uiSystem.removeView(m_view);
		}

		public override function updateData(delta:Number) : void {
			super.updateData(delta);

			var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
			m_view.player_list.array = [{"name":"你的", "score":55332, "rank":1}, {"name":"和的我", "score":12341, "rank":2}, {"name":"地", "score":7777, "rank":3}, 
			{"name":"是和的", "score":4444, "rank":4}, {"name":"脸我折", "score":4222, "rank":5}, {"name":"使用者", "score":4111, "rank":6}, 
			{"name":"有一上", "score":3333, "rank":7}, {"name":"止是了了了", "score":3222, "rank":8}, {"name":"从多有", "score":3111, "rank":9}, 
			{"name":"工人我", "score":2222, "rank":10}, {"name":"敢扔人", "score":1111, "rank":11}, {"name":"珠和上", "score":666, "rank":12}];
			

		}
		private function _onPlayerRenderItem(comp:Component, idx:int) : void {
			var item:RankItemUI = comp as RankItemUI;
			var data:Object = item.dataSource;
			// if (!data) {
			// 	item.visible = false;
			// 	return ;
			// }

			item.rank_1_img.visible = item.rank_2_img.visible = item.rank_3_img.visible = false;
			item.rank_txt.visible = false;
			item.visible = true;

			var rank:int = data['rank'];
			if (rank <= 3) {
				if (rank == 1) {
					item.rank_1_img.visible = true;
				} else if (2 == rank) {
					item.rank_2_img.visible = true;
				} else {
					item.rank_3_img.visible = true;
				}
			} else {
				item.rank_txt.text = rank.toString();
				item.rank_txt.visible = true;
			}
			

			item.name_txt.text = data['name'];
			item.score_txt.text = data['score'].toString();
			item.head_icon.skin = 'gameUI/coin_gold.png';
		}
		private function _onReturn() : void {
			hide();
		}

		public function get view() : RankViewUI {
			return m_view;
		}
		private var m_view:RankViewUI;
	}

}