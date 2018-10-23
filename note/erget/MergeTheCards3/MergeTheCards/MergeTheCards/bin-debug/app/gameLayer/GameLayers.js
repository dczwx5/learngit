var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
/**
 * 游戏层级类
 */
var App;
(function (App) {
    var GameLayers = (function () {
        function GameLayers() {
        }
        /**
             * 游戏背景层
             * @type {BaseSpriteLayer}
             */
        GameLayers.Game_Bg = new App.BaseSpriteLayer();
        /**
         * 主游戏层
         * @type {BaseSpriteLayer}
         */
        GameLayers.Game_Main = new App.BaseSpriteLayer();
        /**
         * UI主界面
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Main = new App.BaseEuiLayer();
        /**
         * UI弹出框层
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Popup = new App.BaseEuiLayer();
        /**
         * 新手引导层
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Guide = new App.BaseEuiLayer();
        /**
         * UI警告消息层
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Message = new App.BaseEuiLayer();
        /**
         * UITips层
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Tips = new App.BaseEuiLayer(false, false);
        /**
         * UI顶层(比如放EasyLoading)
         * @type {BaseEuiLayer}
         */
        GameLayers.UI_Top = new App.BaseEuiLayer();
        return GameLayers;
    }());
    App.GameLayers = GameLayers;
    __reflect(GameLayers.prototype, "App.GameLayers");
})(App || (App = {}));
//# sourceMappingURL=GameLayers.js.map