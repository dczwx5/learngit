/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
import CGamingView from "./game/gaming/CGamingView"
import CGamingController from "./game/gaming/CGamingController"
import CLoading from "./game/loading/CLoading"
import CLoginView from "./game/login/CLoginView"
import CLoginController from "./game/login/CLoginController"
/*
* 游戏初始化配置;
*/
export default class GameConfig{
    static width:number=640;
    static height:number=1136;
    static scaleMode:string="fixedwidth";
    static screenMode:string="none";
    static alignV:string="top";
    static alignH:string="left";
    static startScene:any="Level1.scene";
    static sceneRoot:string="";
    static debug:boolean=false;
    static stat:boolean=false;
    static physicsDebug:boolean=false;
    static exportSceneToJson:boolean=true;
    constructor(){}
    static init(){
        var reg: Function = Laya.ClassUtils.regClass;
        reg("game/gaming/CGamingView.ts",CGamingView);
        reg("game/gaming/CGamingController.ts",CGamingController);
        reg("game/loading/CLoading.ts",CLoading);
        reg("game/login/CLoginView.ts",CLoginView);
        reg("game/login/CLoginController.ts",CLoginController);
    }
}
GameConfig.init();