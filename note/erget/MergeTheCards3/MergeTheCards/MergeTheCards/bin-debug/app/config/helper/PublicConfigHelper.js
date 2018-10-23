var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var PublicConfigHelper = (function () {
    function PublicConfigHelper() {
    }
    /** 有多少个牌组 */
    PublicConfigHelper.CARD_GROUP_COUNT = 4;
    /**丢弃卡牌最大数量*/
    PublicConfigHelper.MAX_RUBBISH_COUNT = 2;
    /** 最大手牌数量 */
    PublicConfigHelper.MAX_HAND_CARD_COUNT = 2;
    /**
     * 每个牌组最多放多少张牌
     * @type {number}
     */
    PublicConfigHelper.MAX_GROUP_CARDS_COUNT = 8;
    /**
     * 初始刷新手牌机会数
     * @type {number}
     */
    PublicConfigHelper.INITIAL_REFRESH_HAND_CARD_CHANCE = 1;
    return PublicConfigHelper;
}());
__reflect(PublicConfigHelper.prototype, "PublicConfigHelper");
//# sourceMappingURL=PublicConfigHelper.js.map