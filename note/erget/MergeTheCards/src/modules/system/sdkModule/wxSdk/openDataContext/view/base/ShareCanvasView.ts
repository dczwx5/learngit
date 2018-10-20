abstract class ShareCanvasView extends App.BaseAutoSizeView {

	public rect_bg:eui.Rect;

	public grp_canvasLayer:eui.Group;
	public grp_topLayer:eui.Group;
	public btn_back:eui.Group;

	public constructor() {
		super("ShareCanvasViewSkin");
	}


	protected onInit() {
		super.onInit();
		this.rect_bg.touchEnabled = true;
	}
}
