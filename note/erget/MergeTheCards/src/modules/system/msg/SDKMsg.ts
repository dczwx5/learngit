/**
 * Created by MuZi on 2018/9/11.
 */
namespace SDKMsg {
    /**app是否激活状态*/
    export class ON_APP_ACTIVE extends VoyaMVC.Msg<{active: boolean }> { }
    /**登陆是否成功*/
    export class ON_LOGIN_SUCCESS extends VoyaMVC.Msg<{isLoginSuccess: boolean }> { }
    /**分享是否成功*/
    export class ON_SHARE_SUCCESS extends VoyaMVC.Msg<{isSuccess:boolean}> {}
}