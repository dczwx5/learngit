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
    /**
     * 模态VIEW
     */
    var BaseWindow = (function (_super) {
        __extends(BaseWindow, _super);
        function BaseWindow(skinName, layer, isMask, isTouch, centerH, centerV) {
            if (layer === void 0) { layer = App.GameLayers.UI_Popup; }
            if (isMask === void 0) { isMask = true; }
            if (isTouch === void 0) { isTouch = true; }
            if (centerH === void 0) { centerH = true; }
            if (centerV === void 0) { centerV = true; }
            var _this = _super.call(this, skinName, layer) || this;
            /**是否遮罩*/
            _this._isMask = false;
            _this._uiMask = null;
            /**遮罩透明度*/
            _this._maskAlpha = 0.5;
            _this.dg_onMaskTap = new VL.Delegate();
            _this._centerH = centerH;
            _this._centerV = centerV;
            _this._isMask = isMask;
            if (isMask) {
                _this.initMask(isTouch);
            }
            return _this;
        }
        BaseWindow.prototype.updateLayout = function () {
            if (this._centerH) {
                this.x = StageUtils.getStageWidth() - this.width >> 1;
            }
            if (this._centerV) {
                this.y = StageUtils.getStageHeight() - this.height >> 1;
            }
            this.updateMask();
        };
        BaseWindow.prototype.initMask = function (isTouch) {
            this.cleanUiMask();
            this._uiMask = new egret.Sprite();
            this._uiMask.touchEnabled = isTouch;
            this._uiMask.touchChildren = false;
        };
        BaseWindow.prototype.updateMask = function () {
            if (!this._isMask) {
                return;
            }
            var g = this._uiMask.graphics;
            g.clear();
            g.beginFill(0x000000, 1);
            g.drawRect(0, 0, StageUtils.getStageWidth(), StageUtils.getStageHeight());
            g.endFill();
            this.setMaskAlpha(this._maskAlpha);
            if (this._uiMask.parent != this.myParent) {
                // this.myParent.addChildAt(this._uiMask, Math.max(0, this.myParent.getChildIndex(this)));
                this.myParent.addChildAt(this._uiMask, this.myParent.getChildIndex(this));
            }
        };
        BaseWindow.prototype.setMaskAlpha = function (val) {
            var self = this;
            if (self._uiMask == null)
                return;
            self._maskAlpha = val;
            self._uiMask.alpha = self._maskAlpha;
        };
        BaseWindow.prototype.cleanUiMask = function () {
            var self = this;
            if (self._uiMask) {
                if (self._uiMask.parent) {
                    self._uiMask.parent.removeChild(self._uiMask);
                }
                self._uiMask.graphics.clear();
                self._uiMask = null;
            }
        };
        BaseWindow.prototype.open = function (param) {
            if (param === void 0) { param = null; }
            _super.prototype.open.call(this);
            if (this._isMask && this._uiMask) {
                this._uiMask.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onMaskTap, this);
                this.updateMask();
            }
        };
        BaseWindow.prototype.close = function (param) {
            if (param === void 0) { param = null; }
            _super.prototype.close.call(this);
            if (this._isMask && this._uiMask.parent) {
                this._uiMask.parent.removeChild(this._uiMask);
                this._uiMask.removeEventListener(egret.TouchEvent.TOUCH_TAP, this.onMaskTap, this);
            }
        };
        BaseWindow.prototype.onMaskTap = function (e) {
            this.dg_onMaskTap.boardcast();
        };
        BaseWindow.prototype.destroy = function () {
            _super.prototype.destroy.call(this);
            this.cleanUiMask();
        };
        return BaseWindow;
    }(App.BaseEuiView));
    App.BaseWindow = BaseWindow;
    __reflect(BaseWindow.prototype, "App.BaseWindow");
})(App || (App = {}));
//# sourceMappingURL=BaseWindow.js.map