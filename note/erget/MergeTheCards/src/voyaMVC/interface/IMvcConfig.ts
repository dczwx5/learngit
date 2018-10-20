namespace VoyaMVC{
    export interface IMvcConfig{
        readonly mediatorList:IMediator[];
        readonly handlerList:IController[];
    }
}

