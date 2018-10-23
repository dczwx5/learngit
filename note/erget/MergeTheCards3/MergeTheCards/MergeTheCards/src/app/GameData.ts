/**
 * Created by MuZi on 2018/9/10.
 */
class GameData{

    private static _score:number=0;
    public static killCount:number=20;
    public static addScore:number=10;
    public static speed:number=10;
    public static continuePlayCount:number=0;
    public static continuePlayMaxCount:number=3;
    //单位：秒
    public static syncTime:number=0;
    public static syncDogTime:number=0;

    static get score(): number {
        return Math.floor(this._score);
    }

    static set score(value: number) {
        this._score = value;
    }

    public static resetAttr(){
        GameData.score=0;
        GameData.killCount=0;
        GameData.speed=10;
    }

    public static isOnlyShareGroup:boolean=false;

    public static otherGameInfo:Array<Object>;
    public static curOtherGameIndex:number;

    public static shareId:Array<number>=[];
    public static shareText:Array<string>=[
        "抖音火爆游戏！",
        "你有39个好友正在玩，一起来吧！",
        "史上最难游戏，全球仅有四人通关。",
        "世界上最好玩的游戏，保证你没玩过！",
        "苹果排行榜第一的游戏，快来玩吧！",
        "单身多年，让他们见识你的手速有多快！",
        "说以你的智商，绝对活不过30秒。",
        "别以为你长得帅我就不打你。",
        "左脑发达还是右脑发达，进来就知道了！",
        "智商超过130才能通过，来测试测试！",
        "牛顿的棺材板压不住了，快来帮忙！",
        "史上最难游戏，爱因斯坦很无语！",
        "老婆在家，不要偷偷点哦！",
    ];

    public static shareImg:Array<string>=[
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/1.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/2.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/3.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/4.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/5.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/6.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/7.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/8.jpg",
    ];

}