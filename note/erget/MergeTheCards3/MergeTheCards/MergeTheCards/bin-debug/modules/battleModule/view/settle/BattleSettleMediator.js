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
var BattleSettleMediator = (function (_super) {
    __extends(BattleSettleMediator, _super);
    function BattleSettleMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    BattleSettleMediator.prototype.onViewOpen = function () {
        var view = this.view;
        var battleModel = this.getModel(BattleModel);
        var playerModel = this.getModel(PlayerModel);
        view.lb_lv.text = "\u7B49\u7EA7 " + playerModel.lv;
        view.lb_highScore.text = Utils.NumberToUnitStringUtil.convert(playerModel.highScore);
        view.lb_battleScore.text = Utils.NumberToUnitStringUtil.convert(battleModel.currScore);
        EventHelper.addTapEvent(view.btn_playAgain, this.onTap, this);
        EventHelper.addTapEvent(view.btn_backHome, this.onTap, this);
        this.sendMsg(create(WxSdkMsg.ShowBannerAd));
    };
    BattleSettleMediator.prototype.onViewClose = function () {
        var view = this.view;
        EventHelper.removeTapEvent(view.btn_playAgain, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_backHome, this.onTap, this);
        this.sendMsg(create(WxSdkMsg.HideBannerAd));
    };
    BattleSettleMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.btn_playAgain:
                this.sendMsg(create(BattleMsg.cmd.PlayAgain));
                this.sendMsg(create(BattleMsg.cmd.OpenBattleView));
                this.sendMsg(create(BattleMsg.cmd.CloseBattleSettleView));
                break;
            case view.btn_backHome:
                this.sendMsg(create(BattleMsg.cmd.CloseBattleSettleView));
                this.sendMsg(create(BattleMsg.cmd.BackToMainView));
                break;
        }
    };
    Object.defineProperty(BattleSettleMediator.prototype, "viewClass", {
        get: function () {
            return BattleSettleView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleSettleMediator.prototype, "openViewMsg", {
        get: function () {
            return BattleMsg.cmd.OpenBattleSettleView;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleSettleMediator.prototype, "closeViewMsg", {
        get: function () {
            return BattleMsg.cmd.CloseBattleSettleView;
        },
        enumerable: true,
        configurable: true
    });
    return BattleSettleMediator;
}(ViewMediator));
__reflect(BattleSettleMediator.prototype, "BattleSettleMediator");
//# sourceMappingURL=BattleSettleMediator.js.map