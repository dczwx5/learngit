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
var PopupMsg;
(function (PopupMsg) {
    var ShowPopup = (function (_super) {
        __extends(ShowPopup, _super);
        function ShowPopup() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ShowPopup;
    }(VoyaMVC.Msg));
    PopupMsg.ShowPopup = ShowPopup;
    __reflect(ShowPopup.prototype, "PopupMsg.ShowPopup");
    var HidePopup = (function (_super) {
        __extends(HidePopup, _super);
        function HidePopup() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return HidePopup;
    }(VoyaMVC.Msg));
    PopupMsg.HidePopup = HidePopup;
    __reflect(HidePopup.prototype, "PopupMsg.HidePopup");
})(PopupMsg || (PopupMsg = {}));
//# sourceMappingURL=PopupMsg.js.map