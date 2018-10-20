namespace VoyaMVC{
    export interface IModelMap{
        getModel<T>(modelClass:new()=>T):T;
    }
}
