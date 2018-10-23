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
var UpdatePlayerDataHandler = (function (_super) {
    __extends(UpdatePlayerDataHandler, _super);
    function UpdatePlayerDataHandler() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    UpdatePlayerDataHandler.prototype.init = function (data) {
        this.data = data;
        return this;
    };
    UpdatePlayerDataHandler.prototype.execute = function () {
        GlobalData.instance.playerData = this.data;
        this.closeAsync();
    };
    UpdatePlayerDataHandler.prototype.clear = function () {
        this.data = null;
    };
    return UpdatePlayerDataHandler;
}(MsgHandler));
__reflect(UpdatePlayerDataHandler.prototype, "UpdatePlayerDataHandler");
//# sourceMappingURL=UpdatePlayerDataHandler.js.map