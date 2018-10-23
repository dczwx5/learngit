var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var FriendRankListPanel = (function (_super) {
    __extends(FriendRankListPanel, _super);
    function FriendRankListPanel() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    FriendRankListPanel.prototype.createItem = function () {
        return new RankListItem();
    };
    Object.defineProperty(FriendRankListPanel.prototype, "itemHeight", {
        get: function () {
            return RankListItem.HEIGHT;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(FriendRankListPanel.prototype, "titleText", {
        get: function () {
            return "好友排行";
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(FriendRankListPanel.prototype, "dataList", {
        get: function () {
            return this._dataList;
        },
        set: function (dataList) {
            this._dataList = dataList;
            this.updateByData();
        },
        enumerable: true,
        configurable: true
    });
    return FriendRankListPanel;
}(ListPanel));
__reflect(FriendRankListPanel.prototype, "FriendRankListPanel");
window["FriendRankListPanel"] = FriendRankListPanel;
//# sourceMappingURL=FriendRankListPanel.js.map