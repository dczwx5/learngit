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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
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
        return __awaiter(this, void 0, void 0, function () {
            var roller, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        roller = this.roller;
                        if (!!roller.texture) return [3 /*break*/, 2];
                        _a = roller;
                        return [4 /*yield*/, RES.getResAsync(this._rollerRes)];
                    case 1:
                        _a.texture = _b.sent();
                        // AnchorUtil.setAnchor(this.roller, 0.5);
                        roller.anchorOffsetX = roller.width >> 1;
                        roller.anchorOffsetY = roller.height >> 1;
                        this.updateLayout();
                        this.addChild(this.roller);
                        _b.label = 2;
                    case 2:
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
                        return [2 /*return*/];
                }
            });
        });
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