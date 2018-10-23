var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
/**
 * Created by MuZi on 2018/9/10.
 */
var GameData = (function () {
    function GameData() {
    }
    Object.defineProperty(GameData, "score", {
        get: function () {
            return Math.floor(this._score);
        },
        set: function (value) {
            this._score = value;
        },
        enumerable: true,
        configurable: true
    });
    GameData.resetAttr = function () {
        GameData.score = 0;
        GameData.killCount = 0;
        GameData.speed = 10;
    };
    GameData._score = 0;
    GameData.killCount = 20;
    GameData.addScore = 10;
    GameData.speed = 10;
    GameData.continuePlayCount = 0;
    GameData.continuePlayMaxCount = 3;
    //单位：秒
    GameData.syncTime = 0;
    GameData.syncDogTime = 0;
    GameData.isOnlyShareGroup = false;
    GameData.shareId = [];
    GameData.shareText = [
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
    GameData.shareImg = [
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/1.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/2.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/3.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/4.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/5.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/6.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/7.jpg",
        "http://cdn.evogames.com.cn/wxgames/qiuqiuyouxilaile/8.jpg",
    ];
    return GameData;
}());
__reflect(GameData.prototype, "GameData");
//# sourceMappingURL=GameData.js.map