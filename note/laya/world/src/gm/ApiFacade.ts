import Handler = Laya.Handler;

export module ApiFacade {
    
    export function openScene(url: string, closeOther?: boolean, complete?: Handler) {
    //  MiniLoadingController.instance().show();
        Laya.Scene.open(this._nextScene, true, Laya.Handler.create(this, _onSceneOpenedHandler, null, false));
        
    }
    function _onSceneOpenedHandler() {
        // MiniLoadingController.instance().hide();
    }
  
    export function createHandler(caller: any, method: Function, args: Array<any> = null, isRecover:boolean = false): Laya.Handler {
        if (isRecover) {
            return Laya.Handler.create(caller, method, args, isRecover);
        } else {
            return new Laya.Handler(caller, method, args, false);
        }
    }
    export function recoverHandler(handler: Laya.Handler) {
        if (handler) {
            handler.recover();
        }
    }
}