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
var CloseContextHandler = (function (_super) {
    __extends(CloseContextHandler, _super);
    function CloseContextHandler() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    CloseContextHandler.prototype.init = function (data) {
        return this;
    };
    CloseContextHandler.prototype.execute = function () {
        var evt = ContextEvent.create(ContextEvent, ContextEvent.CLOSE_CONTEXT);
        this.dispatchContextEvent(evt);
        ContextEvent.release(evt);
        this.closeAsync();
    };
    CloseContextHandler.prototype.clear = function () {
    };
    return CloseContextHandler;
}(MsgHandler));
__reflect(CloseContextHandler.prototype, "CloseContextHandler");
//# sourceMappingURL=CloseContextHandler.js.map