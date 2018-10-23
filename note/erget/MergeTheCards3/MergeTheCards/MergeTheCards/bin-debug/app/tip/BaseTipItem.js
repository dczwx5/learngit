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
var App;
(function (App) {
    var BaseTipItem = (function (_super) {
        __extends(BaseTipItem, _super);
        function BaseTipItem() {
            var _this = _super.call(this) || this;
            _this.dg_onRestore = new VL.Delegate();
            _this.touchEnabled = _this.touchChildren = false;
            return _this;
        }
        /**
         * 从对象池取出或创建出来的时候要做的事
         * @param args
         */
        BaseTipItem.prototype.init = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            return this;
        };
        BaseTipItem.prototype.clear = function () {
            if (this.parent) {
                this.parent.removeChild(this);
            }
            this.dg_onRestore.boardcast(this);
            this.container.y = 0;
            this.container.alpha = 1;
        };
        /**
         * 放回对象池
         */
        BaseTipItem.prototype.restore = function () {
            restore(this);
        };
        BaseTipItem.prototype.onShow = function () {
            egret.Tween.get(this.container).set({ y: 0, alpha: 1 })
                .to({ y: -100 }, 300, egret.Ease.circOut)
                .wait(700)
                .to({ y: -200, alpha: 0 }, 400, egret.Ease.circIn)
                .call(this.restore, this);
        };
        return BaseTipItem;
    }(eui.Component));
    App.BaseTipItem = BaseTipItem;
    __reflect(BaseTipItem.prototype, "App.BaseTipItem", ["VL.ObjectCache.ICacheable"]);
})(App || (App = {}));
//# sourceMappingURL=BaseTipItem.js.map