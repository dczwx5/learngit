var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var ContextEventDispatcher = (function () {
    function ContextEventDispatcher() {
    }
    ContextEventDispatcher.prototype.addEventListener = function (type, listener, thisObject, useCapture, priority) {
        ContextEventDispatcher.eventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    };
    ContextEventDispatcher.prototype.once = function (type, listener, thisObject, useCapture, priority) {
        ContextEventDispatcher.eventDispatcher.once(type, listener, thisObject, useCapture, priority);
    };
    ContextEventDispatcher.prototype.removeEventListener = function (type, listener, thisObject, useCapture) {
        ContextEventDispatcher.eventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    };
    ContextEventDispatcher.prototype.hasEventListener = function (type) {
        return ContextEventDispatcher.eventDispatcher.hasEventListener(type);
    };
    ContextEventDispatcher.prototype.dispatchEvent = function (event) {
        return ContextEventDispatcher.eventDispatcher.dispatchEvent(event);
    };
    ContextEventDispatcher.prototype.willTrigger = function (type) {
        return ContextEventDispatcher.eventDispatcher.willTrigger(type);
    };
    ContextEventDispatcher.eventDispatcher = new egret.EventDispatcher();
    return ContextEventDispatcher;
}());
__reflect(ContextEventDispatcher.prototype, "ContextEventDispatcher", ["IEventDispatcher"]);
//# sourceMappingURL=ContextEventDispatcher.js.map