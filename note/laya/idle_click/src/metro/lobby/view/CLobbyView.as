package metro.lobby.view
{
	import core.framework.CViewBean;
	import metro.EViewType;
	import ui.GamePlayUI;
	import game.CPathUtils;
	import metro.player.CPlayerData;
	import metro.player.CPlayerSystem;
	import metro.lobby.view.bottom.CBottomView;
	import metro.player.CPlayerPropertyCalc;

	/**
	 * ...
	 * @author
	 */
	public class CLobbyView extends CViewBean {
		public function CLobbyView(){
			
		}

		public override function get viewID() : int {
			return EViewType.LOBBY;
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
			m_bottomView.onDestroy();
			m_bottomView = null;

			if (m_view) {
				uiSystem.removeView(m_view);
			}
			
			super.onDestroy();			
		}

		protected override function _onShow() : void {
			m_view = new GamePlayUI();
			uiSystem.addToView(m_view);

			m_bottomView = new CBottomView(this);
			m_bottomView.onShow();

			updateData();

		}
		protected override function _onHide() : void {
			m_bottomView.onHide();

			uiSystem.removeView(m_view);
		}

		public override function updateData() : void {
			super.updateData();

			var playerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

			var gold:Number = playerData.currencyData.gold;
			m_view.gold_txt.text = CPlayerPropertyCalc.valueToString(gold);
			m_view.adp_txt.text = CPlayerPropertyCalc.valueToString(playerData.dps);

			m_bottomView.updateData();
		}
		public function get view() : GamePlayUI {
			return m_view;
		}
		private var m_view:GamePlayUI;

		private var m_bottomView:CBottomView;
	}

}