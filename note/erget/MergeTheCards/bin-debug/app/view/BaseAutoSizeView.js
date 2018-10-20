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
    var BaseAutoSizeView = (function (_super) {
        __extends(BaseAutoSizeView, _super);
        function BaseAutoSizeView(skinName, $parent) {
            if ($parent === void 0) { $parent = App.GameLayers.UI_Main; }
            return _super.call(this, skinName, $parent) || this;
        }
        BaseAutoSizeView.prototype.onInit = function () {
            this.initScaleMode();
        };
        BaseAutoSizeView.prototype.initScaleMode = function () {
            this.contentScaleMode = VL.ScaleMode.SHOW_ALL_FILL;
            this.bgScaleMode = VL.ScaleMode.NO_BORDER;
        };
        BaseAutoSizeView.prototype.updateLayout = function () {
            _super.prototype.updateLayout.call(this);
            if (this.grp_content && this.contentScaleMode) {
                this.contentScaleMode.adapt(this.grp_content, this);
            }
            if (this.bgScaleMode && this.img_bg) {
                this.bgScaleMode.adapt(this.img_bg, this);
            }
            // app.log(`w:${this.width}  h:${this.height}`);
            // if(this.grp_content){
            //     app.log(`contentW:${this.grp_content.width}  contentH:${this.grp_content.height}`);
            // }
            // if(this.img_bg){
            //     app.log(`bgW:${this.img_bg.width}  bgH:${this.img_bg.height}`);
            // }
        };
        return BaseAutoSizeView;
    }(App.BaseEuiView));
    App.BaseAutoSizeView = BaseAutoSizeView;
    __reflect(BaseAutoSizeView.prototype, "App.BaseAutoSizeView");
})(App || (App = {}));
//# sourceMappingURL=BaseAutoSizeView.js.map