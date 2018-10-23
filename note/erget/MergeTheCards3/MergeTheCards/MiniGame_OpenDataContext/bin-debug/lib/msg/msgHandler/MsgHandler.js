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
var MsgHandler = (function (_super) {
    __extends(MsgHandler, _super);
    function MsgHandler() {
        var _this = _super.call(this) || this;
        _this.autoRestore = false;
        _this.contextEventDispatcher = new ContextEventDispatcher();
        return _this;
    }
    Object.defineProperty(MsgHandler.prototype, "viewManager", {
        get: function () {
            if (!MsgHandler._viewManager) {
                MsgHandler._viewManager = new ViewManager();
            }
            return MsgHandler._viewManager;
        },
        enumerable: true,
        configurable: true
    });
    MsgHandler.prototype.onOpenView = function (viewClass) {
        return this.viewManager.onOpenView(viewClass);
    };
    MsgHandler.prototype.closeView = function (viewClass) {
        this.viewManager.onCloseView(viewClass);
    };
    MsgHandler.prototype.closeAllView = function () {
        this.viewManager.onCloseAllView();
    };
    MsgHandler.prototype.addContextEvent = function (type, listener, thisObject, useCapture, priority) {
        this.contextEventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    };
    MsgHandler.prototype.removeContextEvent = function (type, listener, thisObject, useCapture) {
        this.contextEventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    };
    MsgHandler.prototype.hasContextEvent = function (type) {
        return this.contextEventDispatcher.hasEventListener(type);
    };
    MsgHandler.prototype.dispatchContextEvent = function (event) {
        return this.contextEventDispatcher.dispatchEvent(event);
    };
    return MsgHandler;
}(Command));
__reflect(MsgHandler.prototype, "MsgHandler");
//# sourceMappingURL=MsgHandler.js.map