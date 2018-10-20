class LvBlock extends eui.Component implements  eui.UIComponent {

	private rect_bg:eui.Rect;
	private lb_lv:eui.Label;

	private _lv:number = 1;
	private _skinId:number = 1;

	private _isReady:boolean = false;

	public constructor() {
		super();
		this.touchChildren = this.touchEnabled = false;
	}

	protected childrenCreated():void
	{
		super.childrenCreated();
		this._isReady = true;
		this.updateShow();
	}

	private updateShow(){
		if(!this._isReady){
			return;
		}
		this.rect_bg.fillColor = SkinConfigHelper.getLvColor(this._skinId, this.lv);
		this.lb_lv.text = this.lv.toString();
	}

	get lv(): number {
		return this._lv;
	}

	set lv(value: number) {
		this._lv = value;
		this.updateShow();
	}

	set skinId(value: number) {
		this._skinId = value;
		this.updateShow();
	}
}

window['LvBlock'] = LvBlock;