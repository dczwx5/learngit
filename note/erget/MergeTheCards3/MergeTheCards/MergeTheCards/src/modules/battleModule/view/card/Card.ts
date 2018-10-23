class Card extends eui.Component implements VL.ObjectCache.ICacheable, VL.DragDrop.IDragItem{

	public static readonly MAX_CACHE_COUNT:number = 35;

	protected _isChildCreated:boolean = false;

	protected rect_bg:eui.Rect;
	protected img_bg:eui.Image;
	protected lb_value:eui.Label;

	public dragItemCtrl: DragCardCtrl;

	private _cfg:CardConfig;
	private _skinMng:SkinManager;

	public constructor() {
		super();
		this.skinName = "CardSkin";
		this.touchChildren = false;
		this.dragItemCtrl = new DragCardCtrl(this);
	}

	protected childrenCreated():void
	{
		super.childrenCreated();
		this._isChildCreated = true;
		this.updateByData();
	}

	protected  async updateByData(){
		let cfg = this.cfg;
		if(cfg){
			this.lb_value.text = this.cfg.value > 0 ? this.cfg.value.toString() : "";
			let color = this._skinMng.getCardColor(this.cfg);
			let bgUrl = this._skinMng.getCardImg(this.cfg);
			let bg = bgUrl.length > 0 ? await app.resManager.getResAsync_promise(bgUrl) : null;
			if(bg){
				this.img_bg.source = bg;
				this.img_bg.visible = true;
				this.rect_bg.visible = false;
			}else {
				this.rect_bg.fillColor = color;
				this.img_bg.visible = false;
				this.rect_bg.visible = true;
			}
		}else {
			this.lb_value.text = "";
			this.rect_bg.fillColor = 0;
			this.img_bg.source = null;
			this.img_bg.visible = false;
			this.rect_bg.visible = true;
		}
	}

	init(cfg:CardConfig, skinMng:SkinManager): Card {
		this._skinMng = skinMng;
		this._skinMng.dg_SkinChanged.register(this.onSkinChanged, this);
		this.cfg = cfg;
		return this;
	}

	private onSkinChanged(param:{skinId:number}){
		this.updateByData();
	}

	clear() {
		this._skinMng.dg_SkinChanged.unregister(this.onSkinChanged);
		this._skinMng = null;
		this.cfg = null;
		app.dragDropManager.unregDragItem(this);
		this.x = this.y = 0;
		if(this.parent){
			this.parent.removeChild(this);
		}
	}

	restore(maxCacheCount: number = Card.MAX_CACHE_COUNT) {
		restore(this, maxCacheCount);
	}

	get cfg(): CardConfig {
		return this._cfg;
	}

	set cfg(value: CardConfig) {
		if(this._cfg == value){
			return ;
		}
		this._cfg = value;
		if(this._isChildCreated){
			this.updateByData();
		}
	}
}

window['Card'] = Card;