class TestView extends App.BaseAutoSizeView{

    public readonly resources: string[] = [];    

    private bg:egret.Bitmap;


    constructor(){
        super(null);
        let sp = new egret.Shape();
        let g = sp.graphics;
        g.beginFill(0);
        g.drawRect(0,0,1334,750);
        g.endFill();
        this.addChild(sp);

    }


    protected async onInit(){
        this.bg = new egret.Bitmap();
        // this.bg.texture = app.resManager.getRes('bg_jpg');
        this.bg.texture = await app.resManager.getResAsync_promise('bg_jpg');

        this.addChild(this.bg);

    }


    protected onDestroy() {
        this.bg = null;
    }


}