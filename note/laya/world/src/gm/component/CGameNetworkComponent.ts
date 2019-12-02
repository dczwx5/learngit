import { CComponent } from "../../hbcore/framework/pattern/CComponent";
import { CGameSystem } from "../CGameSystem";
import { framework } from "../../hbcore/framework/FrameWork";

export default class CGameNetworkComponent extends framework.CBean {
   
    protected onDestroy() {
        super.onDestroy();

    }
    protected onStart() {
        let ret = super.onStart();

        return ret;
    }
    initNetConect() {
        
    }
}