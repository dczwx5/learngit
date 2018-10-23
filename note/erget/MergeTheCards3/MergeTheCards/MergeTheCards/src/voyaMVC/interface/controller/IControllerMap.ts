namespace VoyaMVC{
    export interface IControllerMap{
        registerController(handler:IController);
        removeController(handler:IController);
    }
}

