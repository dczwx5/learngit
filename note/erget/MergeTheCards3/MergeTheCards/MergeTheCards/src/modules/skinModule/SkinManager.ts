class SkinManager {
    private _skinId: number;

    private _uid:string;


    public readonly dg_SkinChanged: VL.Delegate<{ skinId: number }>;

    constructor() {
        this._skinId = 0;
        this.dg_SkinChanged = new VL.Delegate<{ skinId: number }>();
    }

    public getCardColor(cardCfg:CardConfig):number{
        return SkinConfigHelper.getCardColor(this.skinId, cardCfg);
    }

    public getCardImg(cardCfg:CardConfig):string{
        return SkinConfigHelper.getCardImg(this.skinId, cardCfg);
    }

    public getLvColor(lv:number):number{
        return SkinConfigHelper.getLvColor(this.skinId, lv);
    }

    get skinId(): number {
        if(!this._skinId){
            let cache = egret.localStorage.getItem(`skinId_${this._uid}`);
            if(!cache || cache.length == 0){
                cache = "1";
            }
            this._skinId = parseInt(cache);
        }
        return this._skinId;
    }

    set skinId(value: number) {
        if (value == this._skinId) {
            return;
        }
        this._skinId = value;
        egret.localStorage.setItem(`skinId_${this._uid}`, this._skinId.toString());
        this.dg_SkinChanged.boardcast({skinId: this._skinId});
    }

    set uid(value:string){
        this._uid = value;
    }
}
