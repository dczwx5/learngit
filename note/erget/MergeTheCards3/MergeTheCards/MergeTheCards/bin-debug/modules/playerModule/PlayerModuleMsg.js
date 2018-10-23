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
var PlayerModuleMsg;
(function (PlayerModuleMsg) {
    var feedBack;
    (function (feedBack) {
        /**
         * 玩家数据改变
         * 变更了的的数据
         */
        var PlayerDataChanged = (function (_super) {
            __extends(PlayerDataChanged, _super);
            function PlayerDataChanged() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return PlayerDataChanged;
        }(VoyaMVC.Msg));
        feedBack.PlayerDataChanged = PlayerDataChanged;
        __reflect(PlayerDataChanged.prototype, "PlayerModuleMsg.feedBack.PlayerDataChanged");
    })(feedBack = PlayerModuleMsg.feedBack || (PlayerModuleMsg.feedBack = {}));
})(PlayerModuleMsg || (PlayerModuleMsg = {}));
//# sourceMappingURL=PlayerModuleMsg.js.map