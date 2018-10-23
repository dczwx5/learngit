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
var Card = (function (_super) {
    __extends(Card, _super);
    function Card() {
        var _this = _super.call(this) || this;
        _this._isChildCreated = false;
        _this.skinName = "CardSkin";
        _this.touchChildren = false;
        _this.dragItemCtrl = new DragCardCtrl(_this);
        return _this;
    }
    Card.prototype.childrenCreated = function () {
        _super.prototype.childrenCreated.call(this);
        this._isChildCreated = true;
        this.updateByData();
    };
    Card.prototype.updateByData = function () {
        return __awaiter(this, void 0, void 0, function () {
            var cfg, color, bgUrl, bg, _a;
            return __generator(this, function (_b) {
                switch (_b.label) {
                    case 0:
                        cfg = this.cfg;
                        if (!cfg) return [3 /*break*/, 4];
                        this.lb_value.text = this.cfg.value > 0 ? this.cfg.value.toString() : "";
                        color = this._skinMng.getCardColor(this.cfg);
                        bgUrl = this._skinMng.getCardImg(this.cfg);
                        if (!(bgUrl.length > 0)) return [3 /*break*/, 2];
                        return [4 /*yield*/, app.resManager.getResAsync_promise(bgUrl)];
                    case 1:
                        _a = _b.sent();
                        return [3 /*break*/, 3];
                    case 2:
                        _a = null;
                        _b.label = 3;
                    case 3:
                        bg = _a;
                        if (bg) {
                            this.img_bg.source = bg;
                            this.img_bg.visible = true;
                            this.rect_bg.visible = false;
                        }
                        else {
                            this.rect_bg.fillColor = color;
                            this.img_bg.visible = false;
                            this.rect_bg.visible = true;
                        }
                        return [3 /*break*/, 5];
                    case 4:
                        this.lb_value.text = "";
                        this.rect_bg.fillColor = 0;
                        this.img_bg.source = null;
                        this.img_bg.visible = false;
                        this.rect_bg.visible = true;
                        _b.label = 5;
                    case 5: return [2 /*return*/];
                }
            });
        });
    };
    Card.prototype.init = function (cfg, skinMng) {
        this._skinMng = skinMng;
        this._skinMng.dg_SkinChanged.register(this.onSkinChanged, this);
        this.cfg = cfg;
        return this;
    };
    Card.prototype.onSkinChanged = function (param) {
        this.updateByData();
    };
    Card.prototype.clear = function () {
        this._skinMng.dg_SkinChanged.unregister(this.onSkinChanged);
        this._skinMng = null;
        this.cfg = null;
        app.dragDropManager.unregDragItem(this);
        this.x = this.y = 0;
        if (this.parent) {
            this.parent.removeChild(this);
        }
    };
    Card.prototype.restore = function (maxCacheCount) {
        if (maxCacheCount === void 0) { maxCacheCount = Card.MAX_CACHE_COUNT; }
        restore(this, maxCacheCount);
    };
    Object.defineProperty(Card.prototype, "cfg", {
        get: function () {
            return this._cfg;
        },
        set: function (value) {
            if (this._cfg == value) {
                return;
            }
            this._cfg = value;
            if (this._isChildCreated) {
                this.updateByData();
            }
        },
        enumerable: true,
        configurable: true
    });
    Card.MAX_CACHE_COUNT = 35;
    return Card;
}(eui.Component));
__reflect(Card.prototype, "Card", ["VL.ObjectCache.ICacheable", "VL.DragDrop.IDragItem"]);
window['Card'] = Card;
//# sourceMappingURL=Card.js.map