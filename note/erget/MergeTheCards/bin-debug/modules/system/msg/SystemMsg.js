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
var SystemMsg;
(function (SystemMsg) {
    var EnterScene = (function (_super) {
        __extends(EnterScene, _super);
        function EnterScene() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return EnterScene;
    }(VoyaMVC.Msg));
    SystemMsg.EnterScene = EnterScene;
    __reflect(EnterScene.prototype, "SystemMsg.EnterScene");
    var CloseAllViews = (function (_super) {
        __extends(CloseAllViews, _super);
        function CloseAllViews() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return CloseAllViews;
    }(VoyaMVC.Msg));
    SystemMsg.CloseAllViews = CloseAllViews;
    __reflect(CloseAllViews.prototype, "SystemMsg.CloseAllViews");
    /**
     * 程序被切换前后台时的消息
     */
    var APP_ACTIVE_CHANGED = (function (_super) {
        __extends(APP_ACTIVE_CHANGED, _super);
        function APP_ACTIVE_CHANGED() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return APP_ACTIVE_CHANGED;
    }(VoyaMVC.Msg));
    SystemMsg.APP_ACTIVE_CHANGED = APP_ACTIVE_CHANGED;
    __reflect(APP_ACTIVE_CHANGED.prototype, "SystemMsg.APP_ACTIVE_CHANGED");
})(SystemMsg || (SystemMsg = {}));
//# sourceMappingURL=SystemMsg.js.map