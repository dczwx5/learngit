import { CGameSystem } from "../CGameSystem";
import { framework } from "../../hbcore/framework/FrameWork";

export default class CGameEventComponent extends framework.CBean {
    GameEvent = {
        EVENT_TO_LOGIN:'to_login', EVENT_TO_GAMING:'to_gaming'
    }
  
    protected onDestroy() {
        super.onDestroy();

    }
    protected onStart() {
        let ret = super.onStart();

        return ret;
    }

    dispatchEvent(type:string) {
        this.event(type);
    }
    listenEvent(type:string, caller:any, method:Function, args:Array<any> = null) {
        this.on(type, caller, method, args);
    }
    unlistenEvent(type:string, caller:any, method:Function) {
        this.off(type, caller, method);
    }
}