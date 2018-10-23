class LocalSdkController extends VoyaMVC.Controller {

    activate() {
        this.regMsg(SDKMsg.Login, this.onLogin, this);
    }

    deactivate() {
        this.unregMsg(SDKMsg.Login, this.onLogin, this);
    }

    private onLogin(msg: SDKMsg.Login) {

    }

    private get playerModel():PlayerModel{
        return this.getModel(PlayerModel);
    }
}
