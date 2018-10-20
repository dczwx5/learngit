class FlyScoreTip extends eui.Component implements VL.ObjectCache.ICacheable {

	private score:number;
	private bgColor:number;

	private rect_bg:eui.Rect;
	private lb_score:eui.Label;

	private isReady:boolean = false;

	public constructor() {
		super();
		this.skinName = "FlyScoreTipSkin";
	}

	protected childrenCreated():void
	{
		super.childrenCreated();
		this.isReady = true;
		this.updateShow();
	}

	init(bgColor:number, score:number): FlyScoreTip {
		this.bgColor = bgColor;
		this.score = score;
		this.updateShow();
		return this;
	}

	private updateShow(){
		if(!this.isReady){
			return ;
		}
		this.rect_bg.fillColor = this.bgColor;
		this.lb_score.text = `+ ${this.score}`;
		this.anchorOffsetX = this.width >> 1;
		this.anchorOffsetY = this.height >> 1;
	}

	clear() {
		this.score = 0;
		this.bgColor = 0;
		if(this.parent){
			this.parent.removeChild(this);
		}
	}

	restore(maxCacheCount?: number) {
		VL.ObjectCache.CacheableClass.restore(this);
	}
}