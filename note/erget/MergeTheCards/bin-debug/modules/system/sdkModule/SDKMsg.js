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
var SDKMsg;
(function (SDKMsg) {
    /**app是否激活状态*/
    // export class ON_APP_ACTIVE extends VoyaMVC.Msg<{active: boolean }> { }
    // /**登陆是否成功*/
    // export class ON_LOGIN_SUCCESS extends VoyaMVC.Msg<{isLoginSuccess: boolean }> { }
    // /**分享是否成功*/
    // export class ON_SHARE_SUCCESS extends VoyaMVC.Msg<{isSuccess:boolean}> {}
    /**
     * 初始化SDK模块
     */
    var InitSdk = (function (_super) {
        __extends(InitSdk, _super);
        function InitSdk() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return InitSdk;
    }(VoyaMVC.Msg));
    SDKMsg.InitSdk = InitSdk;
    __reflect(InitSdk.prototype, "SDKMsg.InitSdk");
    /**
     * 登录
     */
    var Login = (function (_super) {
        __extends(Login, _super);
        function Login() {
            return _super !== null && _super.apply(this, arguments) || this;
        }
        return Login;
    }(VoyaMVC.Msg));
    SDKMsg.Login = Login;
    __reflect(Login.prototype, "SDKMsg.Login");
})(SDKMsg || (SDKMsg = {}));
//# sourceMappingURL=SDKMsg.js.map