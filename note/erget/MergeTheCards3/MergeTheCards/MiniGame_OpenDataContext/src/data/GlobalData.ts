class GlobalData{
    public playerData:UserData;

    public resBaseUrl:string;

    public lvCfg:Dictionary<LevelConfig>;

    private static _instance:GlobalData;
    public static get instance():GlobalData{
        if(!this._instance){
            this._instance = new GlobalData().init();
        }
        return this._instance;
    }

    constructor(){
        if(GlobalData._instance){
            throw new Error(`单利模式，别乱new~~`);
        }
    }

    private init():GlobalData{
        this.playerData = {
            openId:"",
            nickName:""
        };

        return this;
    }

}
