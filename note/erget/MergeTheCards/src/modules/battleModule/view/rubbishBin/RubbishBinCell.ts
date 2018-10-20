class RubbishBinCell extends eui.Component implements  eui.UIComponent {

	private img_icon:eui.Image;
	private rect_bg:eui.Rect;

	private _isEmpty:boolean = true;

	private _isReady:boolean = false;

	private _skinId:number = 1;

	private _enableClear:boolean = false;

	public constructor() {
		super();
		this.skinName = "RubbishBinCellSkin";
		this.touchChildren = false;
		this.touchEnabled = true;
	}

	protected childrenCreated():void{
		super.childrenCreated();
		this._isReady = true;
		this.updateIcon();
	}

	private needUpdate:boolean = false;
	private updateIcon(){
		if(!this._isReady){
			return;
		}
		if(!this.needUpdate){
			this.needUpdate = true;
			egret.callLater(()=>{
				if(this._isEmpty){
					this.img_icon.source = "icon_rubbishBin_png";
					this.rect_bg.fillColor = SkinConfigHelper.getRubbishCellBgColor(this._skinId);
				}else{
					if(this._enableClear){
						// this.img_icon.source = "icon_playVideo_png";
						this.img_icon.source = "icon_share_png";
					}else{
						this.img_icon.source = "icon_disable_png";
					}
					this.rect_bg.fillColor = SkinConfigHelper.getRubbishCellForeColor(this._skinId);
				}
				this.needUpdate = false;
			}, this);
		}
	}

	set isEmpty(value: boolean) {
		if(this._isEmpty == value){
			return;
		}
		this._isEmpty = value;
		this.updateIcon();
	}

	get isEmpty(): boolean {
		return this._isEmpty;
	}

	get skinId(): number {
		return this._skinId;
	}

	set skinId(value: number) {
		this._skinId = value;
		this.updateIcon();
	}


	get enableClear(): boolean {
		return this._enableClear;
	}

	set enableClear(value: boolean) {
		this._enableClear = value;
		this.updateIcon();
	}
}

window['RubbishBinCell'] = RubbishBinCell;