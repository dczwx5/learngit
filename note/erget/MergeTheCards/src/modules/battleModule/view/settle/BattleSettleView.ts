class BattleSettleView extends App.BaseAutoSizeView {
	public readonly resources: string[] = [];

	public rect_bg:eui.Rect;
	public lb_lv:eui.Label;
	public lb_battleScore:eui.Label;
	public lb_highScore:eui.Label;
	public btn_playAgain:eui.Image;
	public btn_backHome:eui.Image;

	public constructor() {
		super("BattleSettleViewSkin");
	}

	protected onDestroy() {

	}
}