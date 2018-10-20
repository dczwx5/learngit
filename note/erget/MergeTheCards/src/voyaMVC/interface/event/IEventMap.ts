namespace VoyaMVC{
    export interface IEventMap{
        getEvent<T extends IEvent>(eventClass:new()=>T):T;
    }
}
