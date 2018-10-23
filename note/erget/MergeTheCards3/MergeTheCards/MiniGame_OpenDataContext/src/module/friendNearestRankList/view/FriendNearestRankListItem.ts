class FriendNearestRankListItem extends ListItem {

    public static readonly WIDTH:number = 215;
    public static readonly HEIGHT:number = 208;

    /**玩家头象*/
    private imgheadIcon: Img;
    /**玩家名字*/
    private tfName: egret.TextField;
    /**玩家排名*/
    private tfRank: egret.TextField;
    /**玩家积分*/
    private tfScore: egret.TextField;
    /**自己玩家时显示的背景*/
    public imgSelfBg: egret.Shape;

    constructor(){
        super();
        this.init();
    }

    private init(){
        let imgSelfBg = this.imgSelfBg = new egret.Shape();
        imgSelfBg.graphics.beginFill(0xF9C602);
        imgSelfBg.graphics.drawRect(0,0,FriendNearestRankListItem.WIDTH, FriendNearestRankListItem.HEIGHT);
        imgSelfBg.graphics.endFill();
        this.addChild(this.imgSelfBg);

        let tfRank = this.tfRank = new egret.TextField();
        tfRank.size = 28;
        tfRank.textColor = 0x439B9E;
        this.addChild(tfRank);

        let imgheadIcon = this.imgheadIcon = new Img();
        imgheadIcon.height = imgheadIcon.width = 67;
        this.addChild(imgheadIcon);

        let tfName = this.tfName = new egret.TextField();
        tfName.textColor = 0x439B9E;
        tfName.size = 18;
        this.addChild(tfName);

        let tfScore = this.tfScore = new egret.TextField();
        tfScore.textColor = 0x439B9E;
        tfScore.size = 28;
        tfScore.bold = true;
        this.addChild(tfScore);


        this.visible = false;
    }

    public onRemoved() {
        this.removeChildren();
        this.imgheadIcon
            = this.tfName
            = this.tfRank
            = this.tfScore
            = this.imgSelfBg
            = null;
    }

    protected onDataChanged() {
        if(!this.data){
            this.visible = false;
            return;
        }

        let userData:UserGameData = this.data.userData;
        let rank = this.data.rank;
        let isSelf = this.data.isSelf;

        this.imgheadIcon.url = userData.avatarUrl;
        this.imgSelfBg.visible = isSelf;
        this.tfScore.text = userData.KVDataSet.score_week.toString();
        this.tfRank.text = rank.toString();
        this.tfName.text = NickNameFilter.filter(userData.nickname);

        this.updateLayout();
        this.visible = true;
    }

    private updateLayout(){
        this.tfRank.y = 13;
        this.imgheadIcon.y = 60;
        this.tfName.y = 141;
        this.tfScore.y = 165;

        this.setHCenter(this.imgheadIcon);
        this.tfScore.width = this.tfScore.textWidth;
        this.tfRank.width = this.tfRank.textWidth;
        this.tfName.width = this.tfName.textWidth;
        this.setHCenter(this.tfScore);
        this.setHCenter(this.tfRank);
        this.setHCenter(this.tfName);
    }

    private setHCenter(child:egret.DisplayObject){
        child.x = FriendNearestRankListItem.WIDTH - child.width >> 1 ;
    }

    public get data():FriendNearestRankListItemData{
        return this._data;
    }

    public set data(value:FriendNearestRankListItemData){
        this._data = value;
        this.onDataChanged();
    }


}

type FriendNearestRankListItemData = {
    userData:UserGameData,
    rank:number,
    isSelf:boolean
}