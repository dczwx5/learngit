namespace VoyaMVC {
    export class MsgSender implements IMsgSender {

        private msgHandlerMap: { [msgName: string]: { handler: (msg: IMsg) => void, thisObj: any }[] };

        constructor() {
            this.msgHandlerMap = {};
        }

        sendMsg(msg: IMsg) {
            let msgName = getClassName(msg);
            let handlers = this.msgHandlerMap[msgName];
            if(handlers && handlers.length > 0){
                for (let i = 0; i < handlers.length; i++) {
                    let handlerVo = handlers[i];
                    handlerVo.handler.call(handlerVo.thisObj, msg);
                }
            }
            msg.restore();
        }

        regMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any, checkExist: boolean = false) {
            let msgName = getClassName(msgClass);
            let handlers = this.msgHandlerMap[msgName];
            if (!handlers) {
                this.msgHandlerMap[msgName] = [];
            }
            if (checkExist) {
                if(!this.existMsgHandler(msgClass, handler, thisObj)){
                    this.msgHandlerMap[msgName].push({handler:handler, thisObj:thisObj });
                }
            }else {
                this.msgHandlerMap[msgName].push({handler:handler, thisObj:thisObj });
            }
        }

        unregMsg<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void, thisObj: any = null) {
            let msgName = getClassName(msgClass);
            let handlers = this.msgHandlerMap[msgName];
            if (handlers && handlers.length > 0) {
                if (handler) {
                    let h: { handler: (msg: IMsg) => void, thisObj: any };
                    for (let i = 0; i < handlers.length; i++) {
                        h = handlers[i];
                        if (h.handler == handler) {
                            if(thisObj){
                                if(h.thisObj == thisObj){
                                    handlers.splice(i--, 1);
                                }
                            }else {
                                handlers.splice(i--, 1);
                            }
                        }
                    }
                }
            }
        }

        existMsgHandler<T extends IMsg>(msgClass: new(...args)=>T, handler: (msg: T) => void = null, thisObj: any = null): boolean {
            let msgName = getClassName(msgClass);
            let handlers = this.msgHandlerMap[msgName];
            let result = false;
            if (handlers && handlers.length > 0) {
                if (handler) {
                    let h: { handler: (msg: T) => void, thisObj: any };
                    for (let i = 0, l = handlers.length; i < l; i++) {
                        h = handlers[i];
                        if (h.handler == handler) {
                            if(thisObj){
                                if(h.thisObj == thisObj){
                                    result = true;
                                    break;
                                }
                            }else {
                                result = true;
                                break;
                            }
                        }
                    }
                }else {
                    result = true;
                }
            }
            return result;
        }
    }
}
