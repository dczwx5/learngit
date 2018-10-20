class MainView extends App.BaseAutoSizeView{
	public btn_start:eui.Button;
	public btn_shop:eui.Button;
	public btn_rank:eui.Button;
	public btn_share:eui.Button;

	public constructor() {
		super("MainViewSkin");
	}

	public open() {
		super.open();
	}
	public close(){
		super.close();
	}

	public getWxOtherGameIcon(idx:number):WxOtherGameIcon{
		return this['wxOtherGameIcon' + idx];
	}

	protected onDestroy() {
	}

	public get resources():string[]{
		return [];
	}
}