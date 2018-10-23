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
var RebirthConfirmMediator = (function (_super) {
    __extends(RebirthConfirmMediator, _super);
    function RebirthConfirmMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    RebirthConfirmMediator.prototype.onViewOpen = function (data) {
        var view = this.view;
        this.onClose = data.onClose;
        EventHelper.addTapEvent(view.btn_close, this.onTap, this);
        EventHelper.addTapEvent(view.btn_rebirth, this.onTap, this);
        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    };
    RebirthConfirmMediator.prototype.onViewClose = function () {
        var view = this.view;
        EventHelper.removeTapEvent(view.btn_close, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_rebirth, this.onTap, this);
        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    };
    RebirthConfirmMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.btn_close:
                this.sendMsg(create(BattleMsg.cmd.CloseRebirthWindow));
                if (this.onClose) {
                    this.onClose();
                }
                break;
            case view.btn_rebirth:
                this.sendMsg(create(BattleMsg.cmd.Rebirth));
                break;
        }
    };
    Object.defineProperty(RebirthConfirmMediator.prototype, "viewClass", {
        get: function () {
            return RebirthConfirmWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RebirthConfirmMediator.prototype, "openViewMsg", {
        get: function () {
            return BattleMsg.cmd.OpenRebirthWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RebirthConfirmMediator.prototype, "closeViewMsg", {
        get: function () {
            return BattleMsg.cmd.CloseRebirthWindow;
        },
        enumerable: true,
        configurable: true
    });
    return RebirthConfirmMediator;
}(ViewMediator));
__reflect(RebirthConfirmMediator.prototype, "RebirthConfirmMediator");
//# sourceMappingURL=RebirthConfirmMediator.js.map