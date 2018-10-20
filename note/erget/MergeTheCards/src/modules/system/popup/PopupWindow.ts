class PopupWindow extends App.BaseWindow {

	public btn_close:eui.Image;
	public lb_content:eui.Label;
	public lb_title:eui.Label;

	constructor(){
		super('PopupWindowSkin');
	}
	protected onInit() {
	}

	protected onDestroy() {
	}

	readonly resources: string[] = [];
}