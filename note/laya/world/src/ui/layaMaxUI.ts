/**This class is automatically generated by LayaAirIDE, please do not make any modifications. */
import View=Laya.View;
import Dialog=Laya.Dialog;
import Scene=Laya.Scene;
export module ui {
    export class Level1UI extends Laya.Scene {
        constructor(){ super()}
        createChildren():void {
            super.createChildren();
            this.loadScene("Level1");
        }
    }
    export class LoginUI extends Laya.Scene {
        constructor(){ super()}
        createChildren():void {
            super.createChildren();
            this.loadScene("Login");
        }
    }
}
export module ui.loading {
    export class LoadingUI extends Laya.Scene {
        constructor(){ super()}
        createChildren():void {
            super.createChildren();
            this.loadScene("loading/Loading");
        }
    }
}