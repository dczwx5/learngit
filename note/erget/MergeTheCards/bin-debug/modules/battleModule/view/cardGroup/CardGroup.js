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
var CardGroup = (function (_super) {
    __extends(CardGroup, _super);
    function CardGroup() {
        var _this = _super.call(this) || this;
        _this.marginTop = 10;
        _this.gap = 105;
        _this._isActive = false;
        _this.skinName = "CardGroupSkin";
        _this._cardList = [];
        _this.touchChildren = false;
        _this.touchEnabled = true;
        _this.dg_onDropIn = new VL.Delegate();
        _this.dropContainerCtrl = new CardGroupDropCtrl(_this);
        _this.dg_mergeCardComplete = new VL.Delegate();
        return _this;
    }
    CardGroup.prototype.activate = function (groupId, skinMng) {
        if (!this.stage || this._isActive) {
            return;
        }
        this._groupId = groupId;
        this._skinMng = skinMng;
        app.dragDropManager.regDropContainer(this);
        this.dg_onDropIn.register(this.onDropIn, this);
        this._isActive = true;
        this.updateDropArea();
    };
    CardGroup.prototype.deactivate = function () {
        app.dragDropManager.unregDropContainer(this);
        this.dg_onDropIn.unregister(this.onDropIn);
        this._skinMng = null;
        this._isActive = false;
    };
    CardGroup.prototype.onDropIn = function (data) {
        // this._currDropArea.filters = [];
        this.img_border.visible = false;
    };
    CardGroup.prototype.appendCard = function (card) {
        card.y = this.marginTop + this._cardList.length * this.gap;
        card.x = this.width - card.width >> 1;
        this.addChild(card);
        this._cardList.push(card);
        this.updateDropArea();
    };
    CardGroup.prototype.mergeCard = function (distCardCfg, addScore) {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var lastCard, lastButOneCard;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        // app.log(`cards:`, this._cardList);
                        // app.log(`mergeCardAnim:`, distCardCfg);
                        // this.touchChildren = false;
                        this.touchEnabled = false;
                        lastCard = this.lastCard;
                        lastButOneCard = this.lastButOneCard;
                        this.flyScoreTip(lastCard, distCardCfg, addScore);
                        return [4 /*yield*/, this.moveLastCardToLastButOneCard()];
                    case 1:
                        _a.sent();
                        // egret.Tween.get(lastCard)
                        //    .to({y: lastCard.y - this.gap}, 150)
                        //    .call(()=>{
                        this._cardList.pop();
                        lastCard.restore();
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                egret.Tween.get(lastButOneCard)
                                    .to({ scaleX: 0.7, scaleY: 0.7, x: lastButOneCard.x + lastButOneCard.width * 0.15, y: lastButOneCard.y + lastButOneCard.height * 0.15 }, 150)
                                    .call(function () {
                                    lastButOneCard.cfg = distCardCfg;
                                })
                                    .to({ scaleX: 1, scaleY: 1, x: _this.width - lastButOneCard.width >> 1, y: lastButOneCard.y }, 150)
                                    .call(function () {
                                    // this.touchChildren = true;
                                    _this.touchEnabled = true;
                                    _this.updateDropArea();
                                    // this.dg_mergeCardComplete.boardcast({group:this});
                                    resolve();
                                });
                            })];
                }
            });
        });
    };
    CardGroup.prototype.flyScoreTip = function (card, distCardCfg, addScore) {
        var tip = create(FlyScoreTip).init(this._skinMng.getCardColor(distCardCfg), addScore);
        var x = this.width >> 1;
        var fromY = card.y + (card.height >> 1);
        var toY = fromY - (card.height >> 1);
        egret.Tween.get(tip)
            .set({ alpha: 1, x: x, y: fromY })
            .to({ alpha: 0, y: toY }, 600)
            .call(function () {
            tip.restore();
        });
        this.addChild(tip);
    };
    /**
     * 移除牌组后面几张牌
     * @param count
     */
    CardGroup.prototype.removeCards = function (count) {
        count = Math.min(this._cardList.length, count);
        for (var i = 0; i < count; i++) {
            this._cardList.pop().restore();
        }
        this.updateDropArea();
    };
    CardGroup.prototype.removeAllCards = function () {
        while (this._cardList.length > 0) {
            this._cardList.pop().restore();
        }
        this.updateDropArea();
    };
    CardGroup.prototype.removeAllCardsAsync = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            var lastButOneCard;
            return __generator(this, function (_a) {
                switch (_a.label) {
                    case 0:
                        // this.touchChildren = false;
                        this.touchEnabled = false;
                        _a.label = 1;
                    case 1:
                        if (!(this._cardList.length > 1)) return [3 /*break*/, 3];
                        return [4 /*yield*/, this.moveLastCardToLastButOneCard()];
                    case 2:
                        _a.sent();
                        lastButOneCard = this.lastButOneCard;
                        this.flyScoreTip(lastButOneCard, lastButOneCard.cfg, lastButOneCard.cfg.value);
                        this._cardList.splice(this._cardList.length - 2, 1);
                        lastButOneCard.restore();
                        return [3 /*break*/, 1];
                    case 3: return [2 /*return*/, new Promise(function (resolve) {
                            var lastCard = _this.lastCard;
                            if (lastCard) {
                                egret.Tween.get(lastCard)
                                    .to({ x: _this.width >> 1, y: lastCard.y + lastCard.height >> 1, scaleX: 0, scaleY: 0 }, 300)
                                    .call(function () {
                                    _this._cardList.pop();
                                    lastCard.parent.removeChild(lastCard);
                                    lastCard.scaleY = lastCard.scaleX = 1;
                                    lastCard.restore();
                                    _this.updateDropArea();
                                    // this.touchChildren = true;
                                    _this.touchEnabled = true;
                                    resolve();
                                });
                            }
                            else {
                                _this.updateDropArea();
                                // this.touchChildren = true;
                                _this.touchEnabled = true;
                                resolve();
                            }
                        })];
                }
            });
        });
    };
    CardGroup.prototype.moveLastCardToLastButOneCard = function () {
        return __awaiter(this, void 0, void 0, function () {
            var _this = this;
            return __generator(this, function (_a) {
                return [2 /*return*/, new Promise(function (resolve) {
                        var lastCard = _this.lastCard;
                        var lastButOneCard = _this.lastButOneCard;
                        egret.Tween.get(lastCard)
                            .to({ y: lastButOneCard.y }, 150)
                            .call(function () {
                            resolve();
                        });
                    })];
            });
        });
    };
    CardGroup.prototype.checkHover = function (touchTarget) {
        var result = touchTarget == this._currDropArea;
        this.img_border.visible = result;
        // if(result){
        // 	this._currDropArea.filters = [DropEnableFilter.instance];
        // }else {
        // 	this._currDropArea.filters = [];
        // }
        return result;
    };
    CardGroup.prototype.updateDropArea = function () {
        this._currDropArea = this;
        // return;
        // if(this._cardList.length == 0){
        // 	this._currDropArea = this.img_dropArea;
        // }
        // else{
        // 	this._currDropArea = this.lastCard;
        // }
    };
    Object.defineProperty(CardGroup.prototype, "lastCard", {
        get: function () {
            return this._cardList[this._cardList.length - 1];
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroup.prototype, "lastButOneCard", {
        get: function () {
            return this._cardList[this._cardList.length - 2];
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroup.prototype, "groupId", {
        get: function () {
            return this._groupId;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardGroup.prototype, "cardCount", {
        get: function () {
            return this._cardList.length;
        },
        enumerable: true,
        configurable: true
    });
    return CardGroup;
}(eui.Component));
__reflect(CardGroup.prototype, "CardGroup", ["VL.DragDrop.IDropContainer"]);
window["CardGroup"] = CardGroup;
//# sourceMappingURL=CardGroup.js.map