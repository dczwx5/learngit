namespace SDKMsg {
    /**app是否激活状态*/
    // export class ON_APP_ACTIVE extends VoyaMVC.Msg<{active: boolean }> { }
    // /**登陆是否成功*/
    // export class ON_LOGIN_SUCCESS extends VoyaMVC.Msg<{isLoginSuccess: boolean }> { }
    // /**分享是否成功*/
    // export class ON_SHARE_SUCCESS extends VoyaMVC.Msg<{isSuccess:boolean}> {}

    /**
     * 初始化SDK模块
     */
    export class InitSdk extends VoyaMVC.Msg<{pf:string}> {}

    /**
     * 登录
     */
    export class Login extends VoyaMVC.Msg {}



}