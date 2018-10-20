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
var EasyLoadingPanel = (function (_super) {
    __extends(EasyLoadingPanel, _super);
    function EasyLoadingPanel(rollerRes, bgColor, opacity) {
        if (rollerRes === void 0) { rollerRes = "x-jiazai_png"; }
        if (bgColor === void 0) { bgColor = 0; }
        if (opacity === void 0) { opacity = 0.5; }
        var _this = _super.call(this) || this;
        _this.rollSpeed = 6;
        _this._isShow = false;
        _this.roller = new egret.Bitmap();
        _this._rollerRes = rollerRes;
        _this.opacity = opacity;
        _this.bgColor = bgColor;
        // this.bmt_text = new egret.BitmapText();
        // AnchorUtil.setAnchorX(this.bmt_text, 0.5);
        // this.addChild(this.bmt_text);
        _this.touchChildren = false;
        _this.touchEnabled = true;
        return _this;
    }
    EasyLoadingPanel.prototype.show = function (parent, text) {
        if (text === void 0) { text = null; }
        var roller = this.roller;
        if (!roller.texture) {
            roller.texture = RES.getRes(this._rollerRes);
            // AnchorUtil.setAnchor(this.roller, 0.5);
            roller.anchorOffsetX = roller.width >> 1;
            roller.anchorOffsetY = roller.height >> 1;
            this.updateLayout();
            this.addChild(this.roller);
        }
        // parent.addChild(this);
        egret.setTimeout(function () {
            if (this.isShow) {
                parent.addChild(this);
            }
        }, this, 500);
        // if(text){
        //     this.bmt_text.text = text;
        // }
        if (!this._isShow) {
            this._isShow = true;
            this.interval = egret.setInterval(this.roll, this, 20);
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.updateLayout, this);
        }
        this.updateLayout();
    };
    EasyLoadingPanel.prototype.hide = function () {
        if (this.parent) {
            this.parent.removeChild(this);
        }
        // this.bmt_text.text = "";
        egret.clearInterval(this.interval);
        StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.updateLayout, this);
        this._isShow = false;
    };
    EasyLoadingPanel.prototype.updateLayout = function () {
        var stageW = StageUtils.getStageWidth();
        var stageH = StageUtils.getStageHeight();
        var g = this.graphics;
        g.clear();
        g.beginFill(this.bgColor, this.opacity);
        g.drawRect(0, 0, stageW, stageH);
        g.endFill();
        // this.bmt_text.x = this.roller.x = this.width>>1;
        this.roller.x = this.width >> 1;
        this.roller.y = this.height >> 1;
        // this.bmt_text.y = this.roller.y + (this.roller.height >> 1) + 10;
    };
    EasyLoadingPanel.prototype.roll = function () {
        var roller = this.roller;
        if (roller.rotation > 360) {
            roller.rotation = roller.rotation - 360 + this.rollSpeed;
        }
        else {
            roller.rotation += this.rollSpeed;
        }
    };
    Object.defineProperty(EasyLoadingPanel.prototype, "isShow", {
        get: function () {
            return this._isShow;
        },
        enumerable: true,
        configurable: true
    });
    return EasyLoadingPanel;
}(egret.Sprite));
__reflect(EasyLoadingPanel.prototype, "EasyLoadingPanel");
window['EasyLoadingPanel'] = EasyLoadingPanel;
//# sourceMappingURL=EasyLoadingPanel.js.map