class MainView extends App.BaseAutoSizeView{
	public btn_start:eui.Button;
	public btn_shop:eui.Image;
	public btn_rank:eui.Image;
	public btn_share:eui.Image;

	private sp_bg:egret.Shape;
	private bgMatrix:egret.Matrix;

	public constructor() {
		super("MainViewSkin");
	}

	protected onInit() {
		super.onInit();
		this.sp_bg = new egret.Shape();
		let bg = this.sp_bg;
		bg.width = this.width;
		bg.height = this.height;
		let mt = this.bgMatrix = new egret.Matrix();
		mt.rotate(90);
		//this.drawBg();
		this.addChildAt(bg, 0);
	}

	protected updateLayout() {
		super.updateLayout();
		this.drawBg();
	}

	private drawBg(){
		let bg = this.sp_bg;
		bg.width = this.width;
		bg.height = this.height;
		let g = this.sp_bg.graphics;
		g.clear();
		g.beginGradientFill(GradientType.LINEAR, [0x8963C3, 0xD893FF], [1,1], [0,255], this.bgMatrix);
		g.drawRect(0,0,bg.width, bg.height);
		g.endFill();
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