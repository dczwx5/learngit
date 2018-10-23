class StarLevelComponent extends egret.Sprite {

    private readonly starUrl = `resource/openContext/rank/g-xing2.png`;
    private readonly emptyUrl = `resource/openContext/rank/g-xing1.png`;

    private tf_levelName: egret.TextField;
    private tf_moreStars: egret.TextField;

    private imgStars: Img[];

    private _levelCfg: LevelConfig;
    private _level: number;

    constructor() {
        super();
        let tfName = this.tf_levelName = new egret.TextField();
        tfName.size = 32;
        tfName.bold = true;
        this.addChild(tfName);
        this.imgStars = [];
        for (let i = 0; i < 5; i++) {
            let img = new Img();
            this.imgStars.push(img);
            this.addChild(img);
        }
        let moreStars = this.tf_moreStars = new egret.TextField();
        moreStars.size = 32;
        moreStars.bold = true;
        this.addChild(moreStars);

        this.height = 50;
    }

    private updateShow() {
        //文字
        this.tf_levelName.text = this._levelCfg.name;
        this.tf_moreStars.textColor = this.tf_levelName.textColor = parseInt("0x" + this._levelCfg.nameColour, 16);
        LogUtil.log(`===== lvNameColor:${this._levelCfg.nameColour}   ${parseInt(this._levelCfg.nameColour, 16)}`);
        //星星
        let starCount = this.level - this._levelCfg.baseStars;
        if (this.isLastLevel) {
            this.tf_moreStars.visible = true;
            this.tf_moreStars.text = (starCount + 1).toString();
            for (let i = 1; i <= this.imgStars.length; i++) {
                let star = this.imgStars[i - 1];
                if (i == 1) {
                    star.url = this.starUrl;
                } else {
                    star.visible = false;
                }
            }
        } else {
            let maxStars = this._levelCfg.stars;
            this.tf_moreStars.visible = false;
            for (let i = 0; i < this.imgStars.length; i++) {
                let star = this.imgStars[i];
                star.url = i <= starCount ? this.starUrl : this.emptyUrl;
                star.visible = i < maxStars;
            }
        }
        this.updateLayout();
    }

    private updateLayout() {
        let tfName = this.tf_levelName;
        tfName.x = 0;
        tfName.y = this.height - tfName.textHeight >> 1;
        let starX = this.tf_levelName.x + this.tf_levelName.width + 10;
        let starY = this.height - 48 >> 1;
        for (let i = 0; i < this.imgStars.length; i++) {
            let star = this.imgStars[i];
            star.x = starX;
            star.y = starY;
            starX += 55;
        }
        this.tf_moreStars.x = this.imgStars[1].x;
        this.tf_moreStars.y = tfName.y;
    }

    set level(value: number) {
        this._level = value;
        this._levelCfg = LevelConfig.getLevelDataByStars(value);
        this.updateShow();
    }

    get level(): number {
        return this._level;
    }


    private get isLastLevel() {
        return this.level >= 157;
    }
}
