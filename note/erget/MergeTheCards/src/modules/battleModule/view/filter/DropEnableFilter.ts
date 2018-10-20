class DropEnableFilter extends egret.GlowFilter{

    private static _instance:DropEnableFilter;
    constructor(){
        super(0,1,20,20,2);
    }
    public static get instance():DropEnableFilter{
        if(!this._instance){
            this._instance = new DropEnableFilter();
        }
        return this._instance;
    }
}
