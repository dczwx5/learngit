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
var MainModuleMsg;
(function (MainModuleMsg) {
    /**打开主界面*/
    var OpenMainView = (function (_super) {
        __extends(OpenMainView, _super);
        function OpenMainView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return OpenMainView;
    }(VoyaMVC.Msg));
    MainModuleMsg.OpenMainView = OpenMainView;
    __reflect(OpenMainView.prototype, "MainModuleMsg.OpenMainView");
    /**关闭主界面*/
    var CloseMainView = (function (_super) {
        __extends(CloseMainView, _super);
        function CloseMainView() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseMainView;
    }(VoyaMVC.Msg));
    MainModuleMsg.CloseMainView = CloseMainView;
    __reflect(CloseMainView.prototype, "MainModuleMsg.CloseMainView");
})(MainModuleMsg || (MainModuleMsg = {}));
//# sourceMappingURL=MainModuleMsg.js.map