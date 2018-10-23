class EasyLoadingPanel extends egret.Sprite{

    private opacity:number;

    private bgColor:number;

    private roller:egret.Bitmap;

    // private bmt_text:egret.BitmapText;

    private interval:number;

    private _isShow:boolean;

    private rollSpeed:number = 6;

    private _rollerRes:string;

    constructor(rollerRes:string = "x-jiazai_png", bgColor:number = 0, opacity:number = 0.5){
        super();
        this._isShow = false;
        this.roller = new egret.Bitmap();
        this._rollerRes = rollerRes;
        
        this.opacity = opacity;
        this.bgColor = bgColor;
        
        // this.bmt_text = new egret.BitmapText();
        // AnchorUtil.setAnchorX(this.bmt_text, 0.5);
        // this.addChild(this.bmt_text);
        this.touchChildren = false;
        this.touchEnabled = true;
    }

    public async show(parent:egret.DisplayObjectContainer, text:string = null){
        let roller = this.roller;
        if(!roller.texture){
            roller.texture = await RES.getResAsync(this._rollerRes);
            // AnchorUtil.setAnchor(this.roller, 0.5);
            roller.anchorOffsetX = roller.width >> 1;
            roller.anchorOffsetY = roller.height >> 1;
            this.updateLayout();
            this.addChild(this.roller);
        }
        // parent.addChild(this);
        egret.setTimeout(function(){
            if(this.isShow){
                parent.addChild(this);
            }
        }, this, 500);
        
        // if(text){
        //     this.bmt_text.text = text;
        // }

        if(!this._isShow){
            this._isShow = true;
            this.interval = egret.setInterval(this.roll, this, 20);
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.updateLayout, this);
        }

        this.updateLayout();
    }
    public hide(){
        if(this.parent){
            this.parent.removeChild(this);
        }
        // this.bmt_text.text = "";
        egret.clearInterval(this.interval);

        StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.updateLayout, this);
        this._isShow = false;
    }

    private updateLayout(){
        let stageW = StageUtils.getStageWidth();
        let stageH = StageUtils.getStageHeight();
        let g = this.graphics;
        g.clear();
        g.beginFill(this.bgColor, this.opacity);
        g.drawRect(0,0, stageW, stageH);
        g.endFill();
        // this.bmt_text.x = this.roller.x = this.width>>1;
        this.roller.x = this.width>>1;
        this.roller.y = this.height>>1;
        // this.bmt_text.y = this.roller.y + (this.roller.height >> 1) + 10;
    }

    private roll(){
        let roller = this.roller;
        if(roller.rotation > 360){
            roller.rotation = roller.rotation - 360 + this.rollSpeed;
        }else {
            roller.rotation += this.rollSpeed;
        }
    }

    public get isShow():boolean{
        return this._isShow;
    }

}
window['EasyLoadingPanel']=EasyLoadingPanel;