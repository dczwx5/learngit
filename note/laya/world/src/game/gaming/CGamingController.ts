import CGamingView from "./CGamingView";
import { ApiFacade } from "../../gm/ApiFacade";
import { CGameStage } from "../../gm/CGameStage";
import CGameEventComponent from "../../gm/component/CGameEventComponent";


export default class CGamingController extends Laya.Script {

    onEnable() {
        this.m_pView = this.owner as CGamingView;
        this.m_entered = false;
     
        this.m_pView.returnBtn.clickHandler = ApiFacade.createHandler(this, this._onGamingClick_uiHandler);
    }

    onDisable() {
        this.m_pView.returnBtn.clickHandler = null;
    }

    private _onGamingClick_uiHandler() {
        if (this.m_entered) {
            return ;
        }
       
        this.m_entered = true;

        let eventDispatcher = CGameStage.GameSystem.eventDispatcher;
        eventDispatcher.dispatchEvent(eventDispatcher.GameEvent.EVENT_TO_LOGIN);
    }
    
    private m_pView: CGamingView;
    private m_entered:boolean;
}