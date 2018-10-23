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
        return _this;
    }
    MsgHandler.prototype.execute = function () {
    };
    MsgHandler.prototype.clear = function () {
    };
    return MsgHandler;
}(Command));
__reflect(MsgHandler.prototype, "MsgHandler");
//# sourceMappingURL=MsgHandler.js.map