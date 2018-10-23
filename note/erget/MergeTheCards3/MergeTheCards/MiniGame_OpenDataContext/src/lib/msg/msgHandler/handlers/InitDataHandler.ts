class InitDataHandler extends HandlerBase{
    private data:InitData;
    public init(data: InitData):InitDataHandler {
        this.data = data;
        return this;
    }

    protected execute() {
        this.globalData.resBaseUrl = this.data.resBaseUrl;
        let lvCfg = new Dictionary<LevelConfig>();
        lvCfg.setDatas(this.data.lvCfg);
        this.globalData.lvCfg = lvCfg;
        this.closeAsync();
    }

    protected clear() {
        this.data = null;
    }
}
window["InitDataHandler"] = InitDataHandler;