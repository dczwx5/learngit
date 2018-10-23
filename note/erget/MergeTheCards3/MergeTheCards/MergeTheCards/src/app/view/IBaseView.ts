namespace App {
    /**
     * View接口
     */
    export interface IBaseView extends IBaseComponent {

        readonly dg_inited:VL.Delegate;

        // init();

        /**
         * 初次打开需要加载资源时是否需要显示加载面板
         */
        // showLoading: boolean;

        /**
         * 添加到父级
         */
        // addToParent(): void;

        /**
         * 从父级移除
         */
        // removeFromParent(): void;

        /**
         * 面板开启执行函数，用于子类继承
         * @param param 参数
         */
        open(param?:any): void;

        /**
         * 面板关闭执行函数，用于子类继承
         * @param param 参数
         */
        close(param?:any): void;

        /**
         * 面板是否显示
         * @return
         */
        isOpened: boolean;

        /**
         * 设置所需资源
         */
        readonly resources: string[];


        /**
         * 分模块加载资源
         */
        // loadResource(loadComplete: (loadTarget?: any) => void, initComplete: (e?: eui.UIEvent) => void): void;

    }
}