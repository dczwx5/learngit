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
var FlyScoreTip = (function (_super) {
    __extends(FlyScoreTip, _super);
    function FlyScoreTip() {
        var _this = _super.call(this) || this;
        _this.isReady = false;
        _this.skinName = "FlyScoreTipSkin";
        return _this;
    }
    FlyScoreTip.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this.isReady = true;
        this.updateShow();
    };
    FlyScoreTip.prototype.init = function (bgColor, score) {
        this.bgColor = bgColor;
        this.score = score;
        this.updateShow();
        return this;
    };
    FlyScoreTip.prototype.updateShow = function () {
        if (!this.isReady) {
            return;
        }
        this.rect_bg.fillColor = this.bgColor;
        this.lb_score.text = "+ " + this.score;
        this.anchorOffsetX = this.width >> 1;
        this.anchorOffsetY = this.height >> 1;
    };
    FlyScoreTip.prototype.clear = function () {
        this.score = 0;
        this.bgColor = 0;
        if (this.parent) {
            this.parent.removeChild(this);
        }
    };
    FlyScoreTip.prototype.restore = function (maxCacheCount) {
        VL.ObjectCache.CacheableClass.restore(this);
    };
    return FlyScoreTip;
}(eui.Component));
__reflect(FlyScoreTip.prototype, "FlyScoreTip", ["VL.ObjectCache.ICacheable"]);
//# sourceMappingURL=FlyScoreTip.js.map