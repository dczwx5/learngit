var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var EventHelper = (function () {
        function EventHelper() {
        }
        EventHelper.prototype.addTapEvent = function (target, handler, thisObj) {
            target.addEventListener(egret.TouchEvent.TOUCH_TAP, handler, thisObj);
        };
        EventHelper.prototype.removeTapEvent = function (target, handler, thisObj) {
            target.removeEventListener(egret.TouchEvent.TOUCH_TAP, handler, thisObj);
        };
        return EventHelper;
    }());
    App.EventHelper = EventHelper;
    __reflect(EventHelper.prototype, "App.EventHelper");
})(App || (App = {}));
var EventHelper = new App.EventHelper();
//# sourceMappingURL=EventHelper.js.map