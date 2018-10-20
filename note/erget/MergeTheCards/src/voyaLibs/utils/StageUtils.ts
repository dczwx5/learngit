namespace StageUtils {

    let stage:egret.Stage;
    /**
     * 获取游戏Stage对象
     * @returns {egret.MainContext}
     */
    export function getStage(): egret.Stage {
        if(!stage){
            stage = egret.MainContext.instance.stage;
        }
        return stage;
    }

    /**
     * 获取终端窗口的高度
     * @returns {number}
     */
    export function getStageHeight(): number {
        return getStage().stageHeight;
    }

    /**
     * 获取终端窗口的宽度
     * @returns {number}
     */
    export function getStageWidth(): number {
        return getStage().stageWidth;
    }

    /**
     * 获取舞台对象自身的实际高度
     * @returns {number}
     */
    export function getGameHeight(): number {
        return getStage().height;
    }

    /**
     * 获取舞台对象自身的实际宽度
     * @returns {number}
     */
    export function getGameWidth(): number {
        return getStage().width;
    }

    /**
     * 指定此对象的子项以及子孙项是否接收鼠标/触摸事件
     * @param value
     */
    export function setTouchChildren(value: boolean): void {
        getStage().touchChildren = value;
    }

    /**
     * 设置同时可触发几个点击事件，默认为2
     * @param value
     */
    export function setMaxTouches(value: number): void {
        getStage().maxTouches = value;
    }

    /**
     * 设置帧频
     * @param value
     */
    export function setFrameRate(value: number): void {
        getStage().frameRate = value;
    }

    /**
     * 设置适配方式
     * @param value egret.StageScaleMode里的成员
     */
    export function setScaleMode(value: string): void {
        getStage().scaleMode = value;
    }
}