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
var CardSkinModuleMsg;
(function (CardSkinModuleMsg) {
    var OpenCardSkinWindow = (function (_super) {
        __extends(OpenCardSkinWindow, _super);
        function OpenCardSkinWindow() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OpenCardSkinWindow;
    }(VoyaMVC.Msg));
    CardSkinModuleMsg.OpenCardSkinWindow = OpenCardSkinWindow;
    __reflect(OpenCardSkinWindow.prototype, "CardSkinModuleMsg.OpenCardSkinWindow");
    var CloseCardSkinWindow = (function (_super) {
        __extends(CloseCardSkinWindow, _super);
        function CloseCardSkinWindow() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseCardSkinWindow;
    }(VoyaMVC.Msg));
    CardSkinModuleMsg.CloseCardSkinWindow = CloseCardSkinWindow;
    __reflect(CloseCardSkinWindow.prototype, "CardSkinModuleMsg.CloseCardSkinWindow");
    var ChangeSkin = (function (_super) {
        __extends(ChangeSkin, _super);
        function ChangeSkin() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ChangeSkin;
    }(VoyaMVC.Msg));
    CardSkinModuleMsg.ChangeSkin = ChangeSkin;
    __reflect(ChangeSkin.prototype, "CardSkinModuleMsg.ChangeSkin");
})(CardSkinModuleMsg || (CardSkinModuleMsg = {}));
//# sourceMappingURL=CardSkinModuleMsg.js.map