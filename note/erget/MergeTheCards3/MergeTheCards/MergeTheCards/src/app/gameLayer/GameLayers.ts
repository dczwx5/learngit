/**
 * 游戏层级类
 */
namespace App {

    export class GameLayers {
        /**
             * 游戏背景层
             * @type {BaseSpriteLayer}
             */
        static readonly Game_Bg: BaseSpriteLayer = new BaseSpriteLayer();
        /**
         * 主游戏层
         * @type {BaseSpriteLayer}
         */
        static readonly Game_Main: BaseSpriteLayer = new BaseSpriteLayer();

        /**
         * UI主界面
         * @type {BaseEuiLayer}
         */
        static readonly UI_Main: BaseEuiLayer = new BaseEuiLayer();
        /**
         * UI弹出框层
         * @type {BaseEuiLayer}
         */
        static readonly UI_Popup: BaseEuiLayer = new BaseEuiLayer();

        /**
         * 新手引导层
         * @type {BaseEuiLayer}
         */
        static readonly UI_Guide: BaseEuiLayer = new BaseEuiLayer();
        /**
         * UI警告消息层
         * @type {BaseEuiLayer}
         */
        static readonly UI_Message: BaseEuiLayer = new BaseEuiLayer();
        /**
         * UITips层
         * @type {BaseEuiLayer}
         */
        static readonly UI_Tips: BaseEuiLayer = new BaseEuiLayer(false, false);

        /**
         * UI顶层(比如放EasyLoading)
         * @type {BaseEuiLayer}
         */
        static readonly UI_Top: BaseEuiLayer = new BaseEuiLayer();
    }


}