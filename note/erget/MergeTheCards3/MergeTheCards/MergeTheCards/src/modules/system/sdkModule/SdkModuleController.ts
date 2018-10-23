class SdkModuleController extends VoyaMVC.Controller{

    activate() {
        this.regMsg(SDKMsg.InitSdk, this.onInitSdk, this);
    }

    deactivate() {
        this.unregMsg(SDKMsg.InitSdk, this.onInitSdk, this);
    }

    private onInitSdk(msg:SDKMsg.InitSdk){
        // wanba_ts/yingyongbao/空字符串表示本地/weixin/h5sdk
        switch (msg.body.pf){
            case "weixin":
                this.registerController(new WxSdkController());
                this.registerMediator(new SC_FriendsRankMediator());
                break;
            default :
                this.registerController(new LocalSdkController());
                break;
        }
    }
}