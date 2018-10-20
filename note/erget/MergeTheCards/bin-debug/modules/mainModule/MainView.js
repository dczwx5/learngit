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
var MainView = (function (_super) {
    __extends(MainView, _super);
    function MainView() {
        return _super.call(this, "MainViewSkin") || this;
    }
    MainView.prototype.open = function () {
        _super.prototype.open.call(this);
    };
    MainView.prototype.close = function () {
        _super.prototype.close.call(this);
    };
    MainView.prototype.getWxOtherGameIcon = function (idx) {
        return this['wxOtherGameIcon' + idx];
    };
    MainView.prototype.onDestroy = function () {
    };
    Object.defineProperty(MainView.prototype, "resources", {
        get: function () {
            return [];
        },
        enumerable: true,
        configurable: true
    });
    return MainView;
}(App.BaseAutoSizeView));
__reflect(MainView.prototype, "MainView");
//# sourceMappingURL=MainView.js.map