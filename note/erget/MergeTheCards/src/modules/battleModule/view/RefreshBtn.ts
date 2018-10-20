class RefreshBtn extends eui.Component implements  eui.UIComponent {

	private rect_bg:eui.Rect;
	private icon_refresh:eui.Image;
	private icon_playVideo:eui.Image;

	private _enableRefresh:boolean;

	private _enableReset:boolean;

	public constructor() {
		super();
		this.touchEnabled = true;
		this.touchChildren = false;
	}

	private needRefresh:boolean = false;
	private updateShow(){
		if(!this.needRefresh){
			this.needRefresh = true;
			egret.callLater(()=>{
				if(this.enableRefresh){
					this.icon_playVideo.visible = false;
					this.icon_refresh.visible = true;
					this.rect_bg.fillColor = 0x00ff00;
				}else{
					this.icon_playVideo.visible = true;
					this.icon_refresh.visible = false;
					this.rect_bg.fillColor = 0xff0000;
					if(this.enableReset){
						this.icon_playVideo.source = "icon_playVideo_png";
					}else {
						this.icon_playVideo.source = "icon_disable_png";
					}
				}
				this.needRefresh = false;
			}, this);
		}
	}

	get enableRefresh(): boolean {
		return this._enableRefresh;
	}

	set enableRefresh(value: boolean) {
		this._enableRefresh = value;
		this.updateShow();
	}


	get enableReset(): boolean {
		return this._enableReset;
	}

	set enableReset(value: boolean) {
		this._enableReset = value;
		this.updateShow();
	}
}
window["RefreshBtn"] = RefreshBtn;