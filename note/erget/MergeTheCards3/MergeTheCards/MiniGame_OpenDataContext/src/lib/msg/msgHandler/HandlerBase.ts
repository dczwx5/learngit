abstract class HandlerBase extends Command{

    private contextEventDispatcher:ContextEventDispatcher;

    private static _viewManager:ViewManager;
    private get viewManager():ViewManager{
        if(!HandlerBase._viewManager){
            HandlerBase._viewManager = new ViewManager();
        }
        return HandlerBase._viewManager;
    }

    protected get globalData():GlobalData{
        return GlobalData.instance;
    }

    constructor(){
        super();
        this.autoRestore = false;
        this.contextEventDispatcher = new ContextEventDispatcher();
    }

    public abstract init(data?:any):HandlerBase;

    protected abstract execute();

    protected abstract clear();

    protected onOpenView<T extends egret.DisplayObject>(viewClass:new()=>T):T{
        return this.viewManager.onOpenView(viewClass);
    }

    protected closeView<T extends egret.DisplayObject>(viewClass:new()=>T){
        this.viewManager.onCloseView(viewClass);
    }

    protected closeAllView(){
        this.viewManager.onCloseAllView();
    }

    protected addContextEvent(type: string, listener: Function, thisObject: any, useCapture?: boolean, priority?: number): void {
        this.contextEventDispatcher.addEventListener(type, listener, thisObject, useCapture, priority);
    }

    protected removeContextEvent(type: string, listener: Function, thisObject: any, useCapture?: boolean): void {
        this.contextEventDispatcher.removeEventListener(type, listener, thisObject, useCapture);
    }

    protected hasContextEvent(type: string): boolean {
        return this.contextEventDispatcher.hasEventListener(type);
    }

    protected dispatchContextEvent(event: egret.Event): boolean {
        return this.contextEventDispatcher.dispatchEvent(event);
    }
}
