class UpdatePlayerDataHandler extends HandlerBase{

    private data:WxPlayerData;
    public init(data: WxPlayerData):UpdatePlayerDataHandler {
        this.data = data;
        return this;
    }

    protected execute() {
        this.globalData.playerData = this.data;
        this.closeAsync();
    }

    protected clear() {
        this.data = null;
    }
}
window["UpdatePlayerDataHandler"] = UpdatePlayerDataHandler;