/**
 * 命令基类，主要用于执行逻辑，随创建随用
 */
abstract class Command extends CacheableClass implements ICommand{

    public hashCode;
    public $hashCode;

    public static get COMMAND_COMPLETE():string{
        return "commandComplete";
    }
    public static get COMMAND_ABORT():string{
        return "commandAbort";
    }

    constructor(){
        super();
        this.eventDispatcher = new egret.EventDispatcher();
    }

    public abstract init(...args:any[]):Command;

    public context:any;
    /**
     * 执行完毕时是否自动回收回对象池
     * @type {boolean}
     */
    protected _autoRestore:boolean = true;

    /**
     * 该命令是否已经打开
     * @type {boolean}
     * @private
     */
    private _isOpened:boolean = false;
    /**
     * 打开
     */
    public openAsync() {
        if(this._isOpened)
            return;
        this._isOpened = true;
        this.execute();
    }

    /**
     * 关闭
     * @param abort 是否是被中断的
     */
    public closeAsync(abort:boolean=false):void {
        if(!this._isOpened)
            return;
        this.clear();
        this.context = null;
        this._isOpened = false;
        this.dispatchEvent(egret.Event.create(egret.Event, abort?Command.COMMAND_ABORT:Command.COMMAND_COMPLETE));
        if(this.autoRestore){
            this.restore();
        }
    }
    /** 立即执行打开并关闭 */
    public run():void {
        this.openAsync();
        this.closeAsync();
    }
   /** 执行 */
    protected abstract execute();
    /** 清理 */
    protected abstract clear();


    /**
     * 该命令是否已经执行完毕
     */
    public get isOpened(){
        return this._isOpened;
    }

    /**
     * 是否自动回收
     * @returns {boolean}
     */
    public get autoRestore():boolean{
        return this._autoRestore;
    }

    public set autoRestore(value:boolean){
        this._autoRestore = value;
    }


    private eventDispatcher:egret.EventDispatcher;
    addEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void {
        this.eventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    }

    once(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void {
        this.eventDispatcher.once(type, listener, thisObject, useCapture, priority);
    }

    removeEventListener(type: string, listener: Function, thisObject: any, useCapture?: boolean): void {
        this.eventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    }

    hasEventListener(type: string): boolean {
        return this.eventDispatcher.hasEventListener(type);
    }

    dispatchEvent(event: egret.Event): boolean {
        return this.eventDispatcher.dispatchEvent(event);
    }

    willTrigger(type: string): boolean {
        return this.eventDispatcher.willTrigger(type);
    }
}