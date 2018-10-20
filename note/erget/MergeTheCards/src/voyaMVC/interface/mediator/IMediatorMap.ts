namespace VoyaMVC{
    export interface IMediatorMap{
        registerMediator(mediator:IMediator);
        removeMediator(mediator:IMediator);
        getMediator<T extends IMediator>(mediatorClass:new()=>T):T;
    }
}

