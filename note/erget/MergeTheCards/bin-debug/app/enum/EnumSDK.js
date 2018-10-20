/**
 * Created by MuZi on 2018/9/10.
 */
var E_SAHRE_IMG_TYPE;
(function (E_SAHRE_IMG_TYPE) {
    /*自定义图片*/
    E_SAHRE_IMG_TYPE[E_SAHRE_IMG_TYPE["DIY"] = 1] = "DIY";
    /**游戏图标*/
    E_SAHRE_IMG_TYPE[E_SAHRE_IMG_TYPE["GAME_ICON"] = 2] = "GAME_ICON";
    /**当前游戏头像*/
    E_SAHRE_IMG_TYPE[E_SAHRE_IMG_TYPE["HEAD_ICON"] = 3] = "HEAD_ICON";
})(E_SAHRE_IMG_TYPE || (E_SAHRE_IMG_TYPE = {}));
var E_SHARE_TYPE;
(function (E_SHARE_TYPE) {
    /**普通的*/
    E_SHARE_TYPE[E_SHARE_TYPE["COMMON"] = 1] = "COMMON";
    /**拉起分享面板*/
    E_SHARE_TYPE[E_SHARE_TYPE["CALL_PANEL"] = 2] = "CALL_PANEL";
    /**发消息*/
    E_SHARE_TYPE[E_SHARE_TYPE["SEND_MSG"] = 3] = "SEND_MSG";
    /*QQ空间*/
    E_SHARE_TYPE[E_SHARE_TYPE["QZONE"] = 4] = "QZONE";
})(E_SHARE_TYPE || (E_SHARE_TYPE = {}));
/**
 * 操作平台类型
 */
var E_PLATFORM_TYPE;
(function (E_PLATFORM_TYPE) {
    E_PLATFORM_TYPE[E_PLATFORM_TYPE["ANDROID"] = 1] = "ANDROID";
    E_PLATFORM_TYPE[E_PLATFORM_TYPE["IOS"] = 2] = "IOS";
})(E_PLATFORM_TYPE || (E_PLATFORM_TYPE = {}));
/**
 * 渠道类型
 */
var E_PF_TYPE;
(function (E_PF_TYPE) {
    E_PF_TYPE[E_PF_TYPE["undefined"] = "undefined"] = "undefined";
    E_PF_TYPE[E_PF_TYPE["LOCAL"] = ""] = "LOCAL";
    E_PF_TYPE[E_PF_TYPE["WEIXIN"] = "weixin"] = "WEIXIN";
})(E_PF_TYPE || (E_PF_TYPE = {}));
