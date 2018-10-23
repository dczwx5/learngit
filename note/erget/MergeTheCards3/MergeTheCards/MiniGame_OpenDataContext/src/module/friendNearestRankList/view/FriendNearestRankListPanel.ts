class FriendNearestRankListPanel extends egret.DisplayObjectContainer {
    private bg: egret.Shape;
    private itemList: FriendNearestRankListItem[];

    private _dataList: UserGameData[];

    constructor() {
        super();
        this.init();
    }

    private init() {
        this.width = 655;
        this.height = 212;

        let bg = this.bg = new egret.Shape();
        bg.graphics.beginFill(0xE3F5EA);
        bg.graphics.drawRect(0, 0, this.width, this.height);
        bg.graphics.endFill();
        this.addChild(bg);

        this.itemList = [];
        let gap = 5;
        let itemY = this.height - FriendNearestRankListItem.HEIGHT >> 1;
        let item: FriendNearestRankListItem;
        for (let i = 0, l = 3; i < l; i++) {
            item = new FriendNearestRankListItem();
            this.itemList.push(item);
            item.x = i * (gap + FriendNearestRankListItem.WIDTH);
            item.y = itemY;
            this.addChild(item);
        }
        this.setPosistion();
    }

    protected setPosistion(){
        this.x = Main.stage.stageWidth - this.width >> 1;
        this.y = Main.stage.stageHeight - this.height >> 1;
    }

    private updateByData() {
        let itemDatas = this.getItemDatas();
        for (let i = 0, l = this.itemList.length; i < l; i++) {
            this.itemList[i].data = itemDatas[i];
        }
    }

    private getItemDatas(): FriendNearestRankListItemData[] {
        let result: FriendNearestRankListItemData[] = [];
        let userData: UserGameData;
        let playerData = GlobalData.instance.playerData;
        for (let i = 0, l = this.dataList.length; i < l; i++) {
            userData = this.dataList[i];
            if (userData.openid == playerData.openId) {
                let playerIsFirst:boolean = false;
                let playerIsLast:boolean = false;

                if (i > 0) {
                    result.push({isSelf: false, rank: i, userData: this.dataList[i - 1]});
                }else {
                    playerIsFirst = true;
                }
                result.push({isSelf: true, rank: i + 1, userData: userData});
                if (i < l - 1) {
                    result.push({isSelf: false, rank: i + 2, userData: this.dataList[i + 1]});
                }else {
                    playerIsLast = true;
                }

                if(playerIsFirst && i < l - 2){
                    result.push({isSelf: false, rank: i + 3, userData: this.dataList[i + 2]});
                }else{
                    result.push(null);
                }
                if(playerIsLast && i > 1){
                    result.unshift({isSelf: false, rank: i - 1, userData: this.dataList[i - 2]});
                }else {
                    result.push(null);
                }
                break;
            }
        }
        return result;
    }

    public set dataList(dataList: UserGameData[]) {
        this._dataList = dataList;
        this.updateByData();
    }

    public get dataList(): UserGameData[] {
        return this._dataList;
    }
}
