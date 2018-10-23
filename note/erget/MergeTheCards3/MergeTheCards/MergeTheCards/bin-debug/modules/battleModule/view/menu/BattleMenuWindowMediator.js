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
var BattleMenuWindowMediator = (function (_super) {
    __extends(BattleMenuWindowMediator, _super);
    function BattleMenuWindowMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    BattleMenuWindowMediator.prototype.onViewOpen = function () {
        var view = this.view;
        EventHelper.addTapEvent(view.icon_backHome, this.onTap, this);
        EventHelper.addTapEvent(view.icon_continue, this.onTap, this);
        EventHelper.addTapEvent(view.icon_reset, this.onTap, this);
    };
    BattleMenuWindowMediator.prototype.onViewClose = function () {
        var view = this.view;
        EventHelper.removeTapEvent(view.icon_backHome, this.onTap, this);
        EventHelper.removeTapEvent(view.icon_continue, this.onTap, this);
        EventHelper.removeTapEvent(view.icon_reset, this.onTap, this);
    };
    BattleMenuWindowMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.icon_backHome:
                this.sendMsg(create(BattleMsg.cmd.BackToMainView));
                break;
            case view.icon_reset:
                this.sendMsg(create(BattleMsg.cmd.PlayAgain));
                break;
            case view.icon_continue:
                break;
        }
        this.sendMsg(create(BattleMsg.cmd.CloseBattleMenu));
    };
    Object.defineProperty(BattleMenuWindowMediator.prototype, "viewClass", {
        get: function () {
            return BattleMenuWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleMenuWindowMediator.prototype, "openViewMsg", {
        get: function () {
            return BattleMsg.cmd.OpenBattleMenu;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleMenuWindowMediator.prototype, "closeViewMsg", {
        get: function () {
            return BattleMsg.cmd.CloseBattleMenu;
        },
        enumerable: true,
        configurable: true
    });
    return BattleMenuWindowMediator;
}(ViewMediator));
__reflect(BattleMenuWindowMediator.prototype, "BattleMenuWindowMediator");
//# sourceMappingURL=BattleMenuWindowMediator.js.map