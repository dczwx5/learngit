class MsgRouter{

    private handlerClassRefMap:{[msgHead:string]:new()=>Command};

    constructor(){
        this.handlerClassRefMap = {};
    }

    public regMsgHandler<T extends Command | HandlerBase>(msgHead:string, handler:new()=>T){
        if(!this.handlerClassRefMap[msgHead]){
            this.handlerClassRefMap[msgHead] = handler;
        }else{
            LogUtil.warn(`注意：开放域程序重复注册了一个消息：${msgHead}`);
        }
    }
    public unregMsgHandler(msgHead:string){
        if(this.handlerClassRefMap[msgHead]){
            delete this.handlerClassRefMap[msgHead];
        }
    }

    public handleMsg(msg:WxOpenDataContextMsg){
        LogUtil.log(`---- handleMsg: ${msg.head}`);
        if(!msg.head){
            LogUtil.warn(`注意：开放域程序接收了一个没有 head 的消息：${msg}`);
            return;
        }
        let handlerClass = this.handlerClassRefMap[msg.head];
        if(handlerClass){
            new handlerClass().init(msg.body).openAsync();
        }else {
            LogUtil.warn(`注意：开放域程序并未添加对 ${msg.head} 的消息处理~！`);
        }
    }
}
