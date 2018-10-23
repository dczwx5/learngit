class SkinWindow extends App.BaseWindow {
	public readonly resources: string[] = [];

	public btn_close:eui.Image;
	public lb_unlockedCount:eui.Label;
	public dGroup_cardSkins:eui.List;

	constructor(){
		super(`SkinWindowSkin`);
	}

	protected updateLayout() {
		if (this._centerH) {
			this.x = StageUtils.getStageWidth() - this.width >> 1;
		}
		if (this._centerV) {
			this.y = (StageUtils.getStageHeight() - this.height >> 1) - 70;
		}
		this.updateMask();
	}

	protected onInit() {
		this.dGroup_cardSkins.itemRenderer = CardSkinItemRenderer;
	}

	protected onDestroy() {
	}
}