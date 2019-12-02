import { CGameSystem } from "../CGameSystem";
import { framework } from "../../hbcore/framework/FrameWork";

export default class CGameConfigComponent extends framework.CBean {
 
    protected onDestroy() {
        super.onDestroy();

    }
    protected onStart() {
        let ret = super.onStart();

        return ret;
    }
    initConf(v:any) { this.m_conf = v; };
 
    private m_conf:any;

    get conf() : any { return this.m_conf; }
    
}