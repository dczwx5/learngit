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
var HelpModuleMsg;
(function (HelpModuleMsg) {
    var OPEN_HELP_VIEW = (function (_super) {
        __extends(OPEN_HELP_VIEW, _super);
        function OPEN_HELP_VIEW() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OPEN_HELP_VIEW;
    }(VoyaMVC.Msg));
    HelpModuleMsg.OPEN_HELP_VIEW = OPEN_HELP_VIEW;
    __reflect(OPEN_HELP_VIEW.prototype, "HelpModuleMsg.OPEN_HELP_VIEW");
    var CLOSE_HELP_VIEW = (function (_super) {
        __extends(CLOSE_HELP_VIEW, _super);
        function CLOSE_HELP_VIEW() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CLOSE_HELP_VIEW;
    }(VoyaMVC.Msg));
    HelpModuleMsg.CLOSE_HELP_VIEW = CLOSE_HELP_VIEW;
    __reflect(CLOSE_HELP_VIEW.prototype, "HelpModuleMsg.CLOSE_HELP_VIEW");
})(HelpModuleMsg || (HelpModuleMsg = {}));
//# sourceMappingURL=HelpModuleMsg.js.map