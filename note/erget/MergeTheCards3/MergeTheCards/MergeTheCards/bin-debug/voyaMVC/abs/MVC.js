var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VoyaMVC;
(function (VoyaMVC) {
    var EventMap = (function () {
        function EventMap() {
            this._map = {};
        }
        EventMap.prototype.getEvent = function (eventClass) {
            var className = getClassName(eventClass);
            if (!this._map[className]) {
                this._map[className] = new eventClass();
            }
            return this._map[className];
        };
        return EventMap;
    }());
    __reflect(EventMap.prototype, "EventMap", ["VoyaMVC.IEventMap"]);
    var ModelMap = (function () {
        function ModelMap() {
            this._map = {};
        }
        ModelMap.prototype.getModel = function (modelClass) {
            var className = getClassName(modelClass);
            if (!this._map[className]) {
                this._map[className] = new modelClass();
            }
            return this._map[className];
        };
        return ModelMap;
    }());
    __reflect(ModelMap.prototype, "ModelMap", ["VoyaMVC.IModelMap"]);
    var MediatorMap = (function () {
        function MediatorMap() {
            this._map = {};
        }
        MediatorMap.prototype.registerMediator = function (mediator) {
            var temp = this._map[getClassName(mediator)];
            if (temp) {
                temp.deactivate();
            }
            this._map[getClassName(mediator)] = mediator;
            mediator.activate();
        };
        MediatorMap.prototype.removeMediator = function (mediator) {
            mediator.deactivate();
            delete this._map[getClassName(mediator)];
        };
        MediatorMap.prototype.getMediator = function (mediatorClass) {
            return this._map[getClassName(mediatorClass)];
        };
        return MediatorMap;
    }());
    __reflect(MediatorMap.prototype, "MediatorMap", ["VoyaMVC.IMediatorMap"]);
    var ControllerMap = (function () {
        function ControllerMap() {
            this._map = {};
        }
        ControllerMap.prototype.registerController = function (controller) {
            var temp = this._map[getClassName(controller)];
            if (temp) {
                temp.deactivate();
            }
            this._map[getClassName(controller)] = controller;
            controller.activate();
        };
        ControllerMap.prototype.removeController = function (controller) {
            controller.deactivate();
            delete this._map[getClassName(controller)];
        };
        return ControllerMap;
    }());
    __reflect(ControllerMap.prototype, "ControllerMap", ["VoyaMVC.IControllerMap"]);
    var MvcCore = (function () {
        function MvcCore() {
            if (MvcCore._instance) {
                throw new Error('单利模式，别乱new');
            }
            this._controllerMap = new ControllerMap();
            this._mediatorMap = new MediatorMap();
            this._modelMap = new ModelMap();
            this._eventMap = new EventMap();
            this._msgSender = new VoyaMVC.MsgSender();
        }
        Object.defineProperty(MvcCore, "instance", {
            get: function () {
                if (!this._instance) {
                    this._instance = new MvcCore();
                }
                return this._instance;
            },
            enumerable: true,
            configurable: true
        });
        MvcCore.prototype.sendMsg = function (msg) {
            this._msgSender.sendMsg(msg);
        };
        MvcCore.prototype.regMsg = function (msgClass, handler, thisObj, checkExist) {
            if (checkExist === void 0) { checkExist = false; }
            this._msgSender.regMsg(msgClass, handler, thisObj, checkExist);
        };
        MvcCore.prototype.unregMsg = function (msgClass, handler, thisObj) {
            this._msgSender.unregMsg(msgClass, handler, thisObj);
        };
        MvcCore.prototype.existMsgHandler = function (msgClass, handler, thisObj) {
            return this._msgSender.existMsgHandler(msgClass, handler, thisObj);
        };
        MvcCore.prototype.getModel = function (modelClass) {
            return this._modelMap.getModel(modelClass);
        };
        MvcCore.prototype.getEvent = function (eventClass) {
            return this._eventMap.getEvent(eventClass);
        };
        MvcCore.prototype.registerMediator = function (mediator) {
            this._mediatorMap.registerMediator(mediator);
        };
        MvcCore.prototype.removeMediator = function (mediator) {
            this._mediatorMap.removeMediator(mediator);
        };
        MvcCore.prototype.getMediator = function (mediatorClass) {
            return this._mediatorMap.getMediator(mediatorClass);
        };
        MvcCore.prototype.registerController = function (controller) {
            this._controllerMap.registerController(controller);
        };
        MvcCore.prototype.removeController = function (controller) {
            this._controllerMap.removeController(controller);
        };
        return MvcCore;
    }());
    __reflect(MvcCore.prototype, "MvcCore", ["VoyaMVC.IModelMap", "VoyaMVC.IEventMap", "VoyaMVC.IMediatorMap", "VoyaMVC.IControllerMap", "VoyaMVC.IMsgSender"]);
    var Model = (function () {
        function Model() {
        }
        Model.prototype.sendMsg = function (msg) {
            MvcCore.instance.sendMsg(msg);
        };
        return Model;
    }());
    VoyaMVC.Model = Model;
    __reflect(Model.prototype, "VoyaMVC.Model", ["VoyaMVC.IModel"]);
    var Mediator = (function () {
        function Mediator() {
        }
        Mediator.prototype.getModel = function (modelClass) {
            return MvcCore.instance.getModel(modelClass);
        };
        Mediator.prototype.getEvent = function (eventClass) {
            return MvcCore.instance.getEvent(eventClass);
        };
        Mediator.prototype.sendMsg = function (msg) {
            MvcCore.instance.sendMsg(msg);
        };
        Mediator.prototype.regMsg = function (msgClass, handler, thisObj, checkExist) {
            if (checkExist === void 0) { checkExist = false; }
            MvcCore.instance.regMsg(msgClass, handler, thisObj, checkExist);
        };
        Mediator.prototype.unregMsg = function (msgClass, handler, thisObj) {
            MvcCore.instance.unregMsg(msgClass, handler, thisObj);
        };
        Mediator.prototype.existMsgHandler = function (msgClass, handler, thisObj) {
            return MvcCore.instance.existMsgHandler(msgClass, handler, thisObj);
        };
        return Mediator;
    }());
    VoyaMVC.Mediator = Mediator;
    __reflect(Mediator.prototype, "VoyaMVC.Mediator", ["VoyaMVC.IMediator"]);
    var Controller = (function () {
        function Controller() {
        }
        Controller.prototype.registerMediator = function (mediator) {
            MvcCore.instance.registerMediator(mediator);
        };
        Controller.prototype.removeMediator = function (mediator) {
            MvcCore.instance.removeMediator(mediator);
        };
        Controller.prototype.getMediator = function (mediatorClass) {
            return MvcCore.instance.getMediator(mediatorClass);
        };
        Controller.prototype.getModel = function (modelClass) {
            return MvcCore.instance.getModel(modelClass);
        };
        Controller.prototype.getEvent = function (eventClass) {
            return MvcCore.instance.getEvent(eventClass);
        };
        Controller.prototype.sendMsg = function (msg) {
            MvcCore.instance.sendMsg(msg);
        };
        Controller.prototype.regMsg = function (msgClass, handler, thisObj, checkExist) {
            if (checkExist === void 0) { checkExist = false; }
            MvcCore.instance.regMsg(msgClass, handler, thisObj, checkExist);
        };
        Controller.prototype.unregMsg = function (msgClass, handler, thisObj) {
            MvcCore.instance.unregMsg(msgClass, handler, thisObj);
        };
        Controller.prototype.existMsgHandler = function (msgClass, handler, thisObj) {
            return MvcCore.instance.existMsgHandler(msgClass, handler, thisObj);
        };
        Controller.prototype.registerController = function (controller) {
            MvcCore.instance.registerController(controller);
        };
        Controller.prototype.removeController = function (controller) {
            MvcCore.instance.removeController(controller);
        };
        return Controller;
    }());
    VoyaMVC.Controller = Controller;
    __reflect(Controller.prototype, "VoyaMVC.Controller", ["VoyaMVC.IController"]);
    var MVC = (function () {
        function MVC() {
        }
        Object.defineProperty(MVC.prototype, "core", {
            get: function () {
                return MvcCore.instance;
            },
            enumerable: true,
            configurable: true
        });
        MVC.prototype.configure = function (moduleConfigs) {
            var cfg;
            for (var i = 0, l = moduleConfigs.length; i < l; i++) {
                cfg = moduleConfigs[i];
                if (cfg.mediatorList && cfg.mediatorList.length > 0) {
                    this.regMediators(cfg.mediatorList);
                }
                if (cfg.handlerList && cfg.handlerList.length > 0) {
                    this.regControllers(cfg.handlerList);
                }
            }
        };
        MVC.prototype.regMediators = function (mediators) {
            var mediator;
            for (var i = 0, l = mediators.length; i < l; i++) {
                mediator = mediators[i];
                MvcCore.instance.registerMediator(mediator);
            }
        };
        MVC.prototype.regControllers = function (controllers) {
            var handler;
            for (var i = 0, l = controllers.length; i < l; i++) {
                handler = controllers[i];
                MvcCore.instance.registerController(handler);
            }
        };
        MVC.prototype.regMediator = function (mediator) {
            MvcCore.instance.registerMediator(mediator);
        };
        MVC.prototype.regController = function (controller) {
            MvcCore.instance.registerController(controller);
        };
        return MVC;
    }());
    VoyaMVC.MVC = MVC;
    __reflect(MVC.prototype, "VoyaMVC.MVC");
})(VoyaMVC || (VoyaMVC = {}));
//# sourceMappingURL=MVC.js.map