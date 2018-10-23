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
     * 普通容器层
     */
    var BaseSpriteLayer = (function (_super) {
        __extends(BaseSpriteLayer, _super);
        function BaseSpriteLayer() {
            var _this = _super.call(this) || this;
            _this.touchEnabled = false;
            _this.scrollRect = egret.Rectangle.create();
            _this.addEventListener(egret.Event.ADDED_TO_STAGE, _this.onAdd, _this);
            _this.addEventListener(egret.Event.REMOVED_FROM_STAGE, _this.onRemove, _this);
            return _this;
        }
        BaseSpriteLayer.prototype.onAdd = function () {
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.updateLayout, this);
        };
        BaseSpriteLayer.prototype.onRemove = function () {
            StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.updateLayout, this);
        };
        BaseSpriteLayer.prototype.updateLayout = function (e) {
            var stage = e.target;
            this.width = stage.width;
            this.height = stage.height;
            this.scrollRect.setTo(0, 0, this.width, this.height);
        };
        return BaseSpriteLayer;
    }(egret.DisplayObjectContainer));
    App.BaseSpriteLayer = BaseSpriteLayer;
    __reflect(BaseSpriteLayer.prototype, "App.BaseSpriteLayer", ["App.IGameLayer"]);
})(App || (App = {}));
//# sourceMappingURL=BaseSpriteLayer.js.map