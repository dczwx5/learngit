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
var SC_FriendsRankMediator = (function (_super) {
    __extends(SC_FriendsRankMediator, _super);
    function SC_FriendsRankMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    SC_FriendsRankMediator.prototype.onViewOpen = function () {
        _super.prototype.onViewOpen.call(this);
    };
    SC_FriendsRankMediator.prototype.onViewClose = function () {
        _super.prototype.onViewClose.call(this);
    };
    Object.defineProperty(SC_FriendsRankMediator.prototype, "viewClass", {
        get: function () {
            return SC_FriendsRankView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(SC_FriendsRankMediator.prototype, "openViewMsg", {
        get: function () {
            return WxSdkMsg.OpenFriendRankListView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(SC_FriendsRankMediator.prototype, "closeViewMsg", {
        get: function () {
            return WxSdkMsg.CloseFriendRankListView;
        },
        enumerable: true,
        configurable: true
    });
    SC_FriendsRankMediator.prototype.onBack = function () {
        this.sendMsg(create(WxSdkMsg.CloseFriendRankListView));
    };
    return SC_FriendsRankMediator;
}(ShareCanvasMediator));
__reflect(SC_FriendsRankMediator.prototype, "SC_FriendsRankMediator");
//# sourceMappingURL=SC_FriendsRankMediator.js.map