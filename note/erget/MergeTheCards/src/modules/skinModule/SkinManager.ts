class SkinManager {
    private _skinId: number;

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
        return this._skinId;
    }

    set skinId(value: number) {
        if (value == this._skinId) {
            return;
        }
        this._skinId = value;
        this.dg_SkinChanged.boardcast({skinId: this._skinId});
    }
}
