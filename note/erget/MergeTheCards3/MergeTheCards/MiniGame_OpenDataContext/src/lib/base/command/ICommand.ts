interface ICommand extends egret.IEventDispatcher{
    /**
     * 该命令是否已经打开
     */
    isOpened:boolean;
    /**
     * 异步打开命令
     */
    openAsync():void;
    /**
     * 异步关闭命令
     */
    closeAsync():void;
    /**
     * 执行命令
     */
    run():void;
}