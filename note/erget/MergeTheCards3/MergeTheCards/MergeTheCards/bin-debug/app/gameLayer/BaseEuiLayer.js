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
/**
 * 游戏层级
 */
var App;
(function (App) {
    /**
     * EUI容器层
     */
    var BaseEuiLayer = (function (_super) {
        __extends(BaseEuiLayer, _super);
        function BaseEuiLayer(touchChildren, touchEnabled) {
            if (touchChildren === void 0) { touchChildren = true; }
            if (touchEnabled === void 0) { touchEnabled = false; }
            var _this = _super.call(this) || this;
            _this.touchEnabled = touchEnabled;
            _this.touchChildren = touchChildren;
            _this.addEventListener(egret.Event.ADDED_TO_STAGE, _this.onAdd, _this);
            _this.addEventListener(egret.Event.REMOVED_FROM_STAGE, _this.onRemove, _this);
            return _this;
        }
        BaseEuiLayer.prototype.onAdd = function () {
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.updateLayout, this);
        };
        BaseEuiLayer.prototype.onRemove = function () {
            StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.updateLayout, this);
        };
        BaseEuiLayer.prototype.updateLayout = function (e) {
            var stage = e.target;
            this.width = stage.width;
            this.height = stage.height;
        };
        return BaseEuiLayer;
    }(eui.UILayer));
    App.BaseEuiLayer = BaseEuiLayer;
    __reflect(BaseEuiLayer.prototype, "App.BaseEuiLayer", ["App.IGameLayer"]);
})(App || (App = {}));
//# sourceMappingURL=BaseEuiLayer.js.map