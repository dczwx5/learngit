class SkinModel extends VoyaMVC.Model{
    private readonly _skinMng:SkinManager;
    constructor(){
        super();
        this._skinMng = new SkinManager();
        this._skinMng.skinId = 1;
    }
    public set skinId(id:number){
        this._skinMng.skinId = id;
    }
    public get skinId():number{
        return this._skinMng.skinId;
    }

    public get skinMng():SkinManager{
        return this._skinMng;
    }

}
