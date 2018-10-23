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
var LoadingView = (function (_super) {
    __extends(LoadingView, _super);
    function LoadingView() {
        var _this = _super.call(this, null) || this;
        _this.resources = ['preload'];
        return _this;
    }
    LoadingView.prototype.onInit = function () {
        _super.prototype.onInit.call(this);
        var tf = this.tf_progress = new egret.TextField;
        tf.textColor = 0xff0000;
        tf.size = 40;
        this.addChild(tf);
    };
    LoadingView.prototype.setProgress = function (curr, total) {
        this.tf_progress.text = curr + ' / ' + total;
    };
    LoadingView.prototype.onDestroy = function () {
        this.removeChild(this.tf_progress);
        this.tf_progress = null;
    };
    return LoadingView;
}(App.BaseAutoSizeView));
__reflect(LoadingView.prototype, "LoadingView");
//# sourceMappingURL=LoadingView.js.map