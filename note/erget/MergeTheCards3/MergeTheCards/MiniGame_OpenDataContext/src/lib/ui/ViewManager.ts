class ViewManager{

    private openedViewList:{[viewName:string]:egret.DisplayObject};

    // private static _instance:ViewManager;
    // public static get instance():ViewManager{
    //     if(!this._instance){
    //         this._instance = new ViewManager();
    //     }
    //     return this._instance;
    // }
    constructor(){
        // if(ViewManager._instance){
        //     throw new Error(`单利模式，别乱new~~`);
        // }

        this.openedViewList = {};
    }

    public onOpenView<T extends egret.DisplayObject>(viewClass:new()=>T):T{
        let className = getClassName(viewClass);
        let view:T;
        if(!this.openedViewList[className]){
            view = new viewClass();
            this.openedViewList[className] = view;
        }else{
            view = this.openedViewList[className] as T;
        }
        Main.stage.addChild(view);
        return view;
    }

    public onCloseView<T extends egret.DisplayObject>(viewClass:new()=>T){
        let className = getClassName(viewClass);
        let view:egret.DisplayObject = this.openedViewList[className];
        if(view && view.parent){
            view.parent.removeChild(view);
            delete this.openedViewList[className];
        }
        LogUtil.log(`开放域移除界面:${className}`);
    }

    public onCloseAllView(){
        let view:egret.DisplayObject;
        for(let className in this.openedViewList){
            view = this.openedViewList[className];
            view.parent.removeChild(view);
            delete this.openedViewList[className];
        }
    }
}
