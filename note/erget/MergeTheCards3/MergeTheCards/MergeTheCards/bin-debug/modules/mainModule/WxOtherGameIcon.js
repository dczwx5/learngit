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
var WxOtherGameIcon = (function (_super) {
    __extends(WxOtherGameIcon, _super);
    function WxOtherGameIcon() {
        var _this = _super.call(this) || this;
        _this.isPlayingAnim = false;
        return _this;
    }
    WxOtherGameIcon.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this.touchEnabled = true;
        this.touchChildren = false;
    };
    WxOtherGameIcon.prototype.setData = function (otherGameData) {
        if (otherGameData) {
            this.img_gameIcon.source = otherGameData.image_small;
            this.visible = true;
            this.playAnim();
        }
        else {
            this.visible = false;
            this.stopAnim();
        }
    };
    WxOtherGameIcon.prototype.playAnim = function () {
        if (this.isPlayingAnim) {
            return;
        }
        var img = this.img_gameIcon;
        egret.Tween.removeTweens(img);
        img.rotation = 0;
        egret.Tween.get(img, { loop: true })
            .to({ rotation: -15 }, 50)
            .to({ rotation: 0 }, 50)
            .to({ rotation: 15 }, 50)
            .to({ rotation: 0 }, 50)
            .wait(5000);
        this.isPlayingAnim = true;
    };
    WxOtherGameIcon.prototype.stopAnim = function () {
        if (!this.isPlayingAnim) {
            return;
        }
        var img = this.img_gameIcon;
        egret.Tween.removeTweens(img);
        img.rotation = 0;
        this.isPlayingAnim = false;
    };
    return WxOtherGameIcon;
}(eui.Component));
__reflect(WxOtherGameIcon.prototype, "WxOtherGameIcon", ["eui.UIComponent", "egret.DisplayObject"]);
window['WxOtherGameIcon'] = WxOtherGameIcon;
//# sourceMappingURL=WxOtherGameIcon.js.map