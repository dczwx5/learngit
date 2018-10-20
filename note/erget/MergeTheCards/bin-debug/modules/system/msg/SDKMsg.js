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
/**
 * Created by MuZi on 2018/9/11.
 */
var SDKMsg;
(function (SDKMsg) {
    /**app是否激活状态*/
    var ON_APP_ACTIVE = (function (_super) {
        __extends(ON_APP_ACTIVE, _super);
        function ON_APP_ACTIVE() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ON_APP_ACTIVE;
    }(VoyaMVC.Msg));
    SDKMsg.ON_APP_ACTIVE = ON_APP_ACTIVE;
    __reflect(ON_APP_ACTIVE.prototype, "SDKMsg.ON_APP_ACTIVE");
    /**登陆是否成功*/
    var ON_LOGIN_SUCCESS = (function (_super) {
        __extends(ON_LOGIN_SUCCESS, _super);
        function ON_LOGIN_SUCCESS() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ON_LOGIN_SUCCESS;
    }(VoyaMVC.Msg));
    SDKMsg.ON_LOGIN_SUCCESS = ON_LOGIN_SUCCESS;
    __reflect(ON_LOGIN_SUCCESS.prototype, "SDKMsg.ON_LOGIN_SUCCESS");
    /**分享是否成功*/
    var ON_SHARE_SUCCESS = (function (_super) {
        __extends(ON_SHARE_SUCCESS, _super);
        function ON_SHARE_SUCCESS() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return ON_SHARE_SUCCESS;
    }(VoyaMVC.Msg));
    SDKMsg.ON_SHARE_SUCCESS = ON_SHARE_SUCCESS;
    __reflect(ON_SHARE_SUCCESS.prototype, "SDKMsg.ON_SHARE_SUCCESS");
})(SDKMsg || (SDKMsg = {}));
//# sourceMappingURL=SDKMsg.js.map