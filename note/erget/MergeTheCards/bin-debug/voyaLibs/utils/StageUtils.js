var StageUtils;
(function (StageUtils) {
    var stage;
    /**
     * 获取游戏Stage对象
     * @returns {egret.MainContext}
     */
    function getStage() {
        if (!stage) {
            stage = egret.MainContext.instance.stage;
        }
        return stage;
    }
    StageUtils.getStage = getStage;
    /**
     * 获取终端窗口的高度
     * @returns {number}
     */
    function getStageHeight() {
        return getStage().stageHeight;
    }
    StageUtils.getStageHeight = getStageHeight;
    /**
     * 获取终端窗口的宽度
     * @returns {number}
     */
    function getStageWidth() {
        return getStage().stageWidth;
    }
    StageUtils.getStageWidth = getStageWidth;
    /**
     * 获取舞台对象自身的实际高度
     * @returns {number}
     */
    function getGameHeight() {
        return getStage().height;
    }
    StageUtils.getGameHeight = getGameHeight;
    /**
     * 获取舞台对象自身的实际宽度
     * @returns {number}
     */
    function getGameWidth() {
        return getStage().width;
    }
    StageUtils.getGameWidth = getGameWidth;
    /**
     * 指定此对象的子项以及子孙项是否接收鼠标/触摸事件
     * @param value
     */
    function setTouchChildren(value) {
        getStage().touchChildren = value;
    }
    StageUtils.setTouchChildren = setTouchChildren;
    /**
     * 设置同时可触发几个点击事件，默认为2
     * @param value
     */
    function setMaxTouches(value) {
        getStage().maxTouches = value;
    }
    StageUtils.setMaxTouches = setMaxTouches;
    /**
     * 设置帧频
     * @param value
     */
    function setFrameRate(value) {
        getStage().frameRate = value;
    }
    StageUtils.setFrameRate = setFrameRate;
    /**
     * 设置适配方式
     * @param value egret.StageScaleMode里的成员
     */
    function setScaleMode(value) {
        getStage().scaleMode = value;
    }
    StageUtils.setScaleMode = setScaleMode;
})(StageUtils || (StageUtils = {}));
//# sourceMappingURL=StageUtils.js.map