/**
 * Component接口
 */
interface IBaseComponent {

    /**
     * 是否已经初始化
     * @returns {boolean}
     */
    isInited: boolean;
    /**
     * 销毁
     */
    destroy():void;


}