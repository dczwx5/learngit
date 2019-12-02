import { CGameSystem } from "../CGameSystem";
import { framework } from "../../hbcore/framework/FrameWork";
import CGameConfigComponent from "./CGameConfigComponent";

export default class CGameEnvironmentComponent extends framework.CBean {
 
    protected onDestroy() {
        super.onDestroy();

    }
    protected onStart() {
        let ret = super.onStart();

        return ret;
    }
   
    get isLocal(): boolean {
        if (this.m_isLocal > 0) {
            return this.m_isLocal == 1;
        }

        let confComponent = (this.system.getBean(CGameConfigComponent) as CGameConfigComponent).conf;
        if (!confComponent || !confComponent.conf) {
            return false;
        }
        
        let tempConfig: any = confComponent.conf;
        let host: string = tempConfig.host;
        let isLocal: boolean = host.indexOf('192.168') != -1;
        if (isLocal) {
            this.m_isLocal = 1;
        } else {
            this.m_isLocal = 2;
        }
        return isLocal;
    }
    private m_isLocal: number = -1;
    
}