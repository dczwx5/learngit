class RankListItem extends ListItem {

    // public static readonly WIDTH: number = 370;
    public static readonly WIDTH: number = 914;
    public static readonly HEIGHT: number = 90;

    private bg: egret.DisplayObject;
    private img_rank: Img;
    private tf_rank: egret.TextField;
    private tf_name: egret.TextField;
    private tf_score: egret.TextField;
    private img_head: Img;

    private starLevel:StarLevelComponent;

    private _isInit: boolean;

    constructor() {
        super();
        this._isInit = false;
        this.init();
    }

    protected init() {
        this.width = RankListItem.WIDTH;
        this.height = RankListItem.HEIGHT;

        let bg = this.bg = new egret.Shape();
        bg.graphics.beginFill(0xF9C602);
        bg.graphics.drawRect(0, 0, this.width, this.height);
        bg.graphics.endFill();
        this.addChild(bg);

        let img_rank = this.img_rank = new Img();
        img_rank.height = 100;
        img_rank.width = 73;
        img_rank.x = 35;
        img_rank.y = this.height - img_rank.height >> 1;
        this.addChild(img_rank);

        let tf_rank = this.tf_rank = new egret.TextField();
        tf_rank.size = 32;
        tf_rank.textColor = 0x439B9E;
        tf_rank.x = 35;
        tf_rank.y = this.height - tf_rank.size >> 1;
        this.addChild(tf_rank);

        let img_head = this.img_head = new Img();
        img_head.height = img_head.width = 72;
        img_head.x = 140;
        img_head.y = this.height - img_head.height >> 1;
        this.addChild(img_head);

        let tf_name = this.tf_name = new egret.TextField();
        tf_name.size = 32;
        tf_name.bold = true;
        tf_name.textColor = 0x439B9E;
        tf_name.x = 240;
        tf_name.y = this.height - tf_name.size >> 1;
        this.addChild(tf_name);

        let tf_score = this.tf_score = new egret.TextField();
        tf_score.size = 42;
        tf_score.textColor = 0x439B9E;
        tf_score.x = 700;
        tf_score.y = this.height - tf_score.size >> 1;
        this.addChild(tf_score);

        let starLevel = this.starLevel = new StarLevelComponent();
        starLevel.x = 500;
        starLevel.y = this.height - 48 >> 1;
        this.addChild(starLevel);

        this._isInit = true;
    }

    protected onDataChanged() {
        let data = this.data;
        if (data) {
            this.bg.visible = data.openid == GlobalData.instance.playerData.openId;

            this.tf_name.text = NickNameFilter.filter(data.nickname);
            let rank = this.index + 1;
            if(rank <= 3){
                this.tf_rank.visible = false;
                // this.img_rank.url = `${GlobalData.instance.resBaseUrl}assets/openContext/rank/rank${rank}.png`;
                this.img_rank.url = `resource/openContext/rank/rank${rank}.png`;
                this.img_rank.visible = true;
            }else {
                this.tf_rank.visible = true;
                this.img_rank.visible = false;
                this.tf_rank.text = rank.toString();
                this.tf_rank.x = 78 - (this.tf_rank.width >> 1);
            }
            // let score_week = data.KVDataSet.score_week || 0;
            // this.tf_score.text = score_week.toString();
            let score_max = data.KVDataSet.score_max || 0;
            this.tf_score.text = score_max.toString();
            this.tf_score.x = this.width - this.tf_score.width - 50;
            this.img_head.url = data.avatarUrl;

            // this.starLevel.level = data.KVDataSet.star;

            this.visible = true;
        } else {
            this.visible = false;
        }
    }

    /**
     * 被从列表移除
     */
    public onRemoved() {
        this.removeChildren();
        this.bg
            = this.tf_rank
            = this.tf_name
            = this.tf_score
            = this.img_head
            = null;
        this._isInit = false;
    }

    public get index(): number {
        return this._index;
    }

    public set index(value: number) {
        this._index = value;
    }

    public get data(): UserGameData {
        return this._data;
    }

    public set data(value: UserGameData) {
        this._data = value;
        this.onDataChanged();
    }
}
window["RankListItem"] = RankListItem;
