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
var MainViewMediator = (function (_super) {
    __extends(MainViewMediator, _super);
    function MainViewMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    MainViewMediator.prototype.onViewOpen = function () {
        var view = this.view;
        EventHelper.addTapEvent(view.btn_start, this.onBtnStart, this);
        EventHelper.addTapEvent(view.btn_shop, this.onTouch, this);
        EventHelper.addTapEvent(view.btn_rank, this.onTouch, this);
        EventHelper.addTapEvent(view.btn_share, this.onTouch, this);
        EventHelper.addTapEvent(view.getWxOtherGameIcon(0), this.onTouch, this);
        EventHelper.addTapEvent(view.getWxOtherGameIcon(1), this.onTouch, this);
        this.regMsg(WxSdkMsg.OtherGameDataChanged, this.onOtherGameDataChanged, this);
        this.updateOtherGameIcon();
        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    };
    MainViewMediator.prototype.onViewClose = function () {
        var view = this.view;
        EventHelper.removeTapEvent(view.btn_start, this.onBtnStart, this);
        EventHelper.removeTapEvent(view.btn_shop, this.onTouch, this);
        EventHelper.removeTapEvent(view.btn_rank, this.onTouch, this);
        EventHelper.removeTapEvent(view.btn_share, this.onTouch, this);
        EventHelper.removeTapEvent(view.getWxOtherGameIcon(0), this.onTouch, this);
        EventHelper.removeTapEvent(view.getWxOtherGameIcon(1), this.onTouch, this);
        this.unregMsg(WxSdkMsg.OtherGameDataChanged, this.onOtherGameDataChanged, this);
        this.updateOtherGameIcon(true);
        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    };
    MainViewMediator.prototype.onShop = function () {
        this.sendMsg(create(CardSkinModuleMsg.OpenCardSkinWindow));
    };
    MainViewMediator.prototype.onRank = function () {
        this.sendMsg(create(WxSdkMsg.SendOpenDataContextCmd).init({ head: WxOpenDataContextMsg.FRIEND_RANK_LIST }));
    };
    MainViewMediator.prototype.onShare = function () {
        this.sendMsg(create(WxSdkMsg.Share));
    };
    MainViewMediator.prototype.onTouch = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.btn_share:
                this.onShare();
                break;
            case view.btn_rank:
                this.onRank();
                break;
            case view.btn_shop:
                this.onShop();
                break;
            case view.getWxOtherGameIcon(0):
                this.onOtherGame(0);
                break;
            case view.getWxOtherGameIcon(1):
                this.onOtherGame(1);
                break;
        }
    };
    MainViewMediator.prototype.onOtherGameDataChanged = function () {
        this.updateOtherGameIcon();
    };
    MainViewMediator.prototype.updateOtherGameIcon = function (setNull) {
        if (setNull === void 0) { setNull = false; }
        if (app.globalConfig.pf != 'weixin') {
            return;
        }
        var otherGameMng = this.getModel(WxSDKModel).otherGameMng;
        var view = this.view;
        for (var i = 0, l = otherGameMng.groupCount; i < l; i++) {
            view.getWxOtherGameIcon(i).setData(setNull ? null : otherGameMng.getCurrGameData(i));
        }
    };
    MainViewMediator.prototype.onOtherGame = function (idx) {
        this.sendMsg(create(WxSdkMsg.ToOtherGame).init({ groupIdx: idx }));
    };
    MainViewMediator.prototype.onBtnStart = function (e) {
        this.sendMsg(create(MainModuleMsg.CloseMainView));
        this.sendMsg(create(BattleMsg.cmd.EnterBattle));
    };
    Object.defineProperty(MainViewMediator.prototype, "viewClass", {
        get: function () {
            return MainView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(MainViewMediator.prototype, "openViewMsg", {
        get: function () {
            return MainModuleMsg.OpenMainView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(MainViewMediator.prototype, "closeViewMsg", {
        get: function () {
            return MainModuleMsg.CloseMainView;
        },
        enumerable: true,
        configurable: true
    });
    return MainViewMediator;
}(ViewMediator));
__reflect(MainViewMediator.prototype, "MainViewMediator");
//# sourceMappingURL=MainViewMediator.js.map