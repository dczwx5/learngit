namespace VoyaMVC {

    class EventMap implements IEventMap{
        private _map:{[className:string]: IEvent};

        constructor(){
            this._map = {};
        }

        getEvent<T extends IEvent>(eventClass:  new()=>T ): T {
            let className = getClassName(eventClass);
            if(!this._map[className]){
                this._map[className] = new eventClass();
            }
            return this._map[className] as T;
        }
    }

    class ModelMap implements IModelMap{

        private _map:{[className:string]: IModel};

        constructor(){
            this._map = {};
        }

        getModel<T extends IModel>(modelClass:  new()=>T ): T {
            let className = getClassName(modelClass);
            if(!this._map[className]){
                this._map[className] = new modelClass();
            }
            return this._map[className] as T;
        }
    }

    class MediatorMap implements IMediatorMap{

        private _map:{[className:string]: IMediator} = {};

        registerMediator(mediator: VoyaMVC.IMediator) {
            let temp = this._map[getClassName(mediator)];
            if(temp){
                temp.deactivate();
            }
            this._map[getClassName(mediator)] = mediator;
            mediator.activate();
        }

        removeMediator(mediator: VoyaMVC.IMediator) {
            mediator.deactivate();
            delete this._map[getClassName(mediator)];
        }

        getMediator<T extends IMediator>(mediatorClass: new()=>T ): T {
            return this._map[getClassName(mediatorClass)] as T;
        }
    }

    class ControllerMap implements IControllerMap{

        private _map:{[className:string]: IController};

        constructor(){
            this._map = {};
        }

        registerController(controller: VoyaMVC.IController) {
            let temp = this._map[getClassName(controller)];
            if(temp){
                temp.deactivate();
            }
            this._map[getClassName(controller)] = controller;
            controller.activate();
        }

        removeController(controller: VoyaMVC.IController) {
            controller.deactivate();
            delete this._map[getClassName(controller)];
        }
    }

    class MvcCore implements IModelMap, IEventMap, IMediatorMap, IControllerMap, IMsgSender{
        
        private static _instance:MvcCore;
        public static get instance():MvcCore{
            if(!this._instance){
                this._instance = new MvcCore();
            }
            return this._instance;
        }

        private _controllerMap:ControllerMap;
        private _mediatorMap:MediatorMap;
        private _modelMap:ModelMap;
        private _eventMap:EventMap;

        private _msgSender:MsgSender;

        constructor(){
            if(MvcCore._instance){
                throw new Error('单利模式，别乱new');
            }
            this._controllerMap = new ControllerMap();
            this._mediatorMap = new MediatorMap();
            this._modelMap = new ModelMap();
            this._eventMap = new EventMap();
            this._msgSender = new MsgSender();
        }

        sendMsg(msg: IMsg) {
            this._msgSender.sendMsg(msg);
        }
        regMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any, checkExist: boolean = false) {
            this._msgSender.regMsg(msgClass, handler, thisObj, checkExist);
        }
        unregMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any) {
            this._msgSender.unregMsg(msgClass, handler, thisObj);
        }
        existMsgHandler<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any): boolean {
            return this._msgSender.existMsgHandler(msgClass, handler, thisObj);
        }

        getModel<T extends VoyaMVC.IModel>(modelClass:  new()=>T ): T {
            return this._modelMap.getModel(modelClass);
        }

        getEvent<T extends VoyaMVC.IEvent>(eventClass:  new()=>T ): T {
            return this._eventMap.getEvent(eventClass);
        }

        registerMediator(mediator: VoyaMVC.IMediator) {
            this._mediatorMap.registerMediator(mediator);
        }

        removeMediator(mediator: VoyaMVC.IMediator) {
            this._mediatorMap.removeMediator(mediator);
        }

        getMediator<T extends VoyaMVC.IMediator>(mediatorClass:  new()=>T ): T {
            return this._mediatorMap.getMediator(mediatorClass);
        }

        registerController(controller: VoyaMVC.IController) {
            this._controllerMap.registerController(controller);
        }

        removeController(controller: VoyaMVC.IController) {
            this._controllerMap.removeController(controller);
        }
    }

    export abstract class Model implements IModel{
        protected sendMsg(msg: IMsg) {
            MvcCore.instance.sendMsg(msg);
        }
    }

    export abstract class Mediator implements IMediator{

        protected getModel<T extends IModel>(modelClass: new() => T): T {
            return MvcCore.instance.getModel(modelClass);
        }

        protected getEvent<T extends VoyaMVC.IEvent>(eventClass: new() => T): T {
            return MvcCore.instance.getEvent(eventClass);
        }

        protected sendMsg(msg: IMsg) {
            MvcCore.instance.sendMsg(msg);
        }
        protected regMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any, checkExist: boolean = false) {
            MvcCore.instance.regMsg(msgClass, handler, thisObj, checkExist);
        }
        protected unregMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any) {
            MvcCore.instance.unregMsg(msgClass, handler, thisObj);
        }
        protected existMsgHandler<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any): boolean {
            return MvcCore.instance.existMsgHandler(msgClass, handler, thisObj);
        }

        abstract activate(...params) ;

        abstract deactivate() ;
    }

    export abstract class Controller implements IController {

        protected registerMediator(mediator: VoyaMVC.IMediator) {
            MvcCore.instance.registerMediator(mediator);
        }

        protected removeMediator(mediator: VoyaMVC.IMediator) {
            MvcCore.instance.removeMediator(mediator);
        }
        protected getMediator<T extends VoyaMVC.IMediator>(mediatorClass:  new()=>T ): T {
            return MvcCore.instance.getMediator(mediatorClass);
        }

        protected getModel<T extends IModel>(modelClass: new() => T): T {
            return MvcCore.instance.getModel(modelClass);
        }

        protected getEvent<T extends VoyaMVC.IEvent>(eventClass: new() => T): T {
            return MvcCore.instance.getEvent(eventClass);
        }

        protected sendMsg(msg: IMsg) {
            MvcCore.instance.sendMsg(msg);
        }
        protected regMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any, checkExist: boolean = false) {
            MvcCore.instance.regMsg(msgClass, handler, thisObj, checkExist);
        }
        protected unregMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any) {
            MvcCore.instance.unregMsg(msgClass, handler, thisObj);
        }
        protected existMsgHandler<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any): boolean {
            return MvcCore.instance.existMsgHandler(msgClass, handler, thisObj);
        }

        protected registerController(controller: VoyaMVC.IController) {
            MvcCore.instance.registerController(controller);
        }

        protected removeController(controller: VoyaMVC.IController) {
            MvcCore.instance.removeController(controller);
        }


        abstract activate(...params) ;

        abstract deactivate() ;
    }

    export abstract class MVC {

        protected get core():MvcCore{
            return MvcCore.instance;
        }

        public configure(moduleConfigs: IMvcConfig[]) {
            let cfg: IMvcConfig;
            for (let i = 0, l = moduleConfigs.length; i < l; i++) {
                cfg = moduleConfigs[i];
                if (cfg.mediatorList && cfg.mediatorList.length > 0) {
                    this.regMediators(cfg.mediatorList);
                }
                if (cfg.handlerList && cfg.handlerList.length > 0) {
                    this.regControllers(cfg.handlerList);
                }
            }
        }

        public regMediators(mediators: IMediator[]) {
            let mediator: IMediator;
            for (let i = 0, l = mediators.length; i < l; i++) {
                mediator = mediators[i];
                MvcCore.instance.registerMediator(mediator);
            }
        }

        public regControllers(controllers: IController[]) {
            let handler: IController;
            for (let i = 0, l = controllers.length; i < l; i++) {
                handler = controllers[i];
                MvcCore.instance.registerController(handler);
            }
        }

        public regMediator(mediator: IMediator) {
            MvcCore.instance.registerMediator(mediator);
        }

        public regController(controller: IController) {
            MvcCore.instance.registerController(controller);
        }

        public abstract startup();
    }


}
