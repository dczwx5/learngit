abstract class ListPanel<ITEM_RENDER_CLASS extends ListItem> extends egret.DisplayObjectContainer{

    protected bg:egret.DisplayObject;

    protected headArea:egret.DisplayObjectContainer;
    protected headBg:egret.DisplayObject;
    protected tf_title:egret.TextField;

    protected listArea:egret.DisplayObjectContainer;
    // protected listBg:egret.DisplayObject;

    protected footArea:egret.DisplayObjectContainer;
    protected footBg:egret.DisplayObject;
    protected tf_prePage:egret.TextField;
    protected tf_nextPage:egret.TextField;


    protected _dataList:any[];
    protected _pageSize:number;
    protected _pageIdx:number;
    protected vGap:number;

    protected itemList:ITEM_RENDER_CLASS[];

    private _isInited:boolean;

    constructor(width:number = RankListItem.WIDTH, height:number = 590, pageSize:number = 5){
        super();
        this._isInited = false;
        this.init(width, height, pageSize);
        this.createItems();
    }

    protected init(width:number = RankListItem.WIDTH, height:number = 590, pageSize:number = 5){
        this._pageSize = pageSize;
        this._pageIdx = 0;
        this.itemList = [];
        this._dataList = [];
        this.vGap = 5;

        this.width = width;
        this.height = height;

        let bg = this.bg = new egret.Shape();
        bg.graphics.beginFill(0xE3F5EA);
        bg.graphics.drawRect(0, 0, this.width, this.height);
        bg.graphics.endFill();
        this.addChild(bg);

        this.initHeadArea();
        this.initListArea();
        this.initFootArea();

        this._isInited = true;

        this.setPosistion();
    }

    protected setPosistion(){
        this.x = Main.stage.stageWidth - this.width >> 1;
        this.y = Main.stage.stageHeight - this.height >> 1;
    }

    protected initHeadArea(){
        let headArea = this.headArea = new egret.DisplayObjectContainer();
        headArea.width = this.width;
        headArea.height = 70;
        {
            let headBg = this.headBg = new egret.Shape();
            headBg.graphics.beginFill(0x7CD3D6);
            headBg.graphics.drawRect(0, 0, headArea.width, headArea.height);
            headBg.graphics.endFill();
            headArea.addChild(headBg);
            let tf_title = this.tf_title = new egret.TextField();
            tf_title.size = 34;
            tf_title.textColor = 0xffffff;
            tf_title.text = this.titleText;
            tf_title.x = headArea.width - tf_title.textWidth >> 1;
            tf_title.y = headArea.height - tf_title.textHeight >> 1;
            headArea.addChild(tf_title);
        }
        this.addChild(headArea);
    }
    protected initListArea(){
        let listArea = this.listArea = new egret.DisplayObjectContainer();
        listArea.width = this.width;
        listArea.height = this.listHeight;
        listArea.y = this.headArea.y + this.headArea.height;
        this.addChild(listArea);
    }
    protected initFootArea(){
        let footArea = this.footArea = new egret.DisplayObjectContainer();
        footArea.width = this.width;
        footArea.height = 70;
        footArea.y = this.listArea.y + this.listArea.height;
        {
            let footBg = this.footBg = new egret.Shape();
            footBg.graphics.beginFill(0x7CD3D6);
            footBg.graphics.drawRect(0, 0, footArea.width, footArea.height);
            footBg.graphics.endFill();
            footArea.addChild(footBg);

            let tf_prePage = this.tf_prePage = new egret.TextField();
            tf_prePage.touchEnabled = true;
            tf_prePage.size = 30;
            tf_prePage.textColor = 0xffffff;
            tf_prePage.text = "上一页";
            // tf_prePage.x = 60;
            tf_prePage.x = 620;
            tf_prePage.y = footArea.height - tf_prePage.textHeight >> 1;
            footArea.addChild(tf_prePage);
            tf_prePage.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onPrePage, this);

            let tf_nextPage = this.tf_nextPage = new egret.TextField();
            tf_nextPage.touchEnabled = true;
            tf_nextPage.size = 30;
            tf_nextPage.textColor = 0xffffff;
            tf_nextPage.text = "下一页";
            tf_nextPage.x = footArea.width - tf_nextPage.textWidth - 60;
            tf_nextPage.y = footArea.height - tf_nextPage.textHeight >> 1;
            footArea.addChild(tf_nextPage);
            tf_nextPage.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onNextPage, this);
        }
        this.addChild(footArea);
    }

    protected createItems(){
        if(!this.isInited){
            egret.warn(` ListPanel 尚未初始化 ！`);
            return;
        }
        this.removeAllItems();
        let item:ITEM_RENDER_CLASS;
        let listArea = this.listArea;
        for(let i = 0, l = this.pageSize; i < l; i++){
            item = this.createItem();
            listArea.addChild(item);
            item.x = listArea.width - item.width >> 1;
            item.y = i == 0 ? 0 : (item.height + this.vGap) * i;
            this.itemList.push(item);
        }
    }

    protected abstract createItem():ITEM_RENDER_CLASS;

    public updateByData(){
        this.pageIdx = 0;
        this.updateCurrPage();
    }

    protected updateCurrPage(){
        let beginDataIdx = this.pageSize * this.pageIdx;
        let endDataIdx = beginDataIdx + this.pageSize - 1;
        let item:ITEM_RENDER_CLASS;
        for(let i = beginDataIdx; i <= endDataIdx; i ++ ){
            item = this.itemList[i - beginDataIdx];
            item.index = i;
            item.data = this.dataList[i];
        }
    }

    protected removeAllItems(){
        let item:ITEM_RENDER_CLASS;
        while (this.itemList.length > 0){
            item = this.itemList.pop();
            item.onRemoved();
            if(item.parent){
                item.parent.removeChild(item);
            }
        }
    }

    protected onPrePage(e:egret.TouchEvent){
        egret.log(` onPrePage currPgIdx:${this.pageIdx}   pgCount:${this.pageCount}`);
        if(this.pageIdx <= 0 ){
            return;
        }
        this.pageIdx --;
    }
    protected onNextPage(e:egret.TouchEvent){
        egret.log(` onNextPage currPgIdx:${this.pageIdx}  pgCount:${this.pageCount}`);
        if(this.pageIdx >= this.pageCount - 1){
            return;
        }
        this.pageIdx ++;
    }


    public get dataList(): any[] {
        return this._dataList;
    }

    public set dataList(value: any[]) {
        this._dataList = value;
        this.updateByData();
    }

    public set pageIdx(val:number){
        this._pageIdx = Math.max(0, Math.min(this.pageCount - 1, val));
        this.updateCurrPage();
    }
    public get pageIdx():number{
        return this._pageIdx;
    }
    // public set pageSize(val:number){
    //     if(this.pageSize == val){
    //         return;
    //     }
    //     this._pageSize = val;
    //
    //     this.createItems();
    //     this.pageIdx = this.pageIdx;
    // }
    public get pageSize():number{
        return this._pageSize;
    }
    public get pageCount():number{
        return Math.max(Math.ceil(this.dataList.length / this.pageSize), 1);
    }

    public abstract get itemHeight():number;

    public abstract get titleText():string;

    protected get listHeight():number{
        return this.pageSize * (this.vGap + this.itemHeight);
    }
    public get isInited(): boolean {
        return this._isInited;
    }
}