namespace VoyaMVC {
    export interface IMsgSender {
        sendMsg(msg: IMsg);
        regMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any, checkExist: boolean);
        unregMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any);
        existMsgHandler<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any): boolean;
    }
}
