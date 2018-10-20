class PlayerModel extends VoyaMVC.Model{
    /**
     * 全服唯一ID
     */
    private _uid: string;

    private _lv:number = 1;
    private _highScore:number = 0;

    private _skinId:number = 1;

    saveBattleRecord(lv:number, score?:number){
        // return new Promise((resolve, reject) => {
        //
        //     resolve();
        // });
        let storageData = this.storageData;
        if(score && score > this.highScore){
            this.highScore = score;
            storageData.highScore = score;
            // app.sdkProxy.setStorageData("highScore", this.highScore.toString());
        }
        if(lv > this.lv){
            this.lv = lv;
            storageData.lv = lv;
            // app.sdkProxy.setStorageData("lv", this.lv.toString());
        }
        this.storageData = storageData;
        app.appHttp.submitBattleRecord(this.lv, this.highScore);

        this.sendMsg(create(WxSdkMsg.SetUserCloudStorage).init({
            KVDataList:[
                {key:"score_max", value:this.highScore.toString()}
            ],
            success:()=>{
                app.log(`==== SetUserCloudStorage ====  success `);
            },
            fail:()=>{
                app.log(`==== SetUserCloudStorage ====  fail `);
            }
        }));
    }
    public get storageData():{lv:number, highScore:number}{
        let res:any = egret.localStorage.getItem("playerData");
        if(typeof res == 'string'){
            res = JSON.parse(res as string);
        }
        if(!res){
            res = this.storageData = {lv:1, highScore:0};
        }
        return res;
    }
    public set storageData(data:{lv:number, highScore:number}){
        // app.sdkProxy.setStorageData("playerData", data);
        egret.localStorage.setItem("playerData", JSON.stringify(data));
    }

    set lv(value: number) {
        this._lv = value;
    }

    get lv():number{
        return this._lv;
    }

    get highScore(): number {
        return this._highScore;
    }

    set highScore(value: number) {
        this._highScore = value;
    }

    get exp(): number {
        return LvConfigHelper.getExpByLv(this.lv);
    }


    get skinId(): number {
        return this._skinId;
    }

    set skinId(value: number) {
        this._skinId = value;
    }

    get uid(): string {
        return this._uid;
    }

    set uid(value: string) {
        this._uid = value;
    }
}
