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
var HelpWindowMediator = (function (_super) {
    __extends(HelpWindowMediator, _super);
    function HelpWindowMediator() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    HelpWindowMediator.prototype.onViewOpen = function () {
        EventHelper.addTapEvent(this.view.btn_close, this.onTap, this);
    };
    HelpWindowMediator.prototype.onViewClose = function () {
        EventHelper.removeTapEvent(this.view.btn_close, this.onTap, this);
    };
    HelpWindowMediator.prototype.onTap = function (e) {
        switch (e.currentTarget) {
            case this.view.btn_close:
                this.sendMsg(create(HelpModuleMsg.CLOSE_HELP_VIEW));
                break;
        }
    };
    Object.defineProperty(HelpWindowMediator.prototype, "viewClass", {
        get: function () {
            return HelpWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(HelpWindowMediator.prototype, "openViewMsg", {
        get: function () {
            return HelpModuleMsg.OPEN_HELP_VIEW;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(HelpWindowMediator.prototype, "closeViewMsg", {
        get: function () {
            return HelpModuleMsg.CLOSE_HELP_VIEW;
        },
        enumerable: true,
        configurable: true
    });
    return HelpWindowMediator;
}(ViewMediator));
__reflect(HelpWindowMediator.prototype, "HelpWindowMediator");
//# sourceMappingURL=HelpWindowMediator.js.map