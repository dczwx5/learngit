import CLoginView from "./CLoginView";
import { ApiFacade } from "../../gm/ApiFacade";
import { CGameStage } from "../../gm/CGameStage";


export default class CLoginController extends Laya.Script {

    onEnable() {
        this.m_pView = this.owner as CLoginView;
        this.m_entered = false;
     
        this.m_pView.startBtn.clickHandler = ApiFacade.createHandler(this, this._onLoginClick_uiHandler);
    }

    onDisable() {
        this.m_pView.startBtn.clickHandler = null;
    }

    private _onLoginClick_uiHandler() {
        if (this.m_entered) {
            return ;
        }
       
        this.m_entered = true;

        let eventDispatcher = CGameStage.GameSystem.eventDispatcher;
        eventDispatcher.dispatchEvent(eventDispatcher.GameEvent.EVENT_TO_GAMING);
    }
    
    private m_pView: CLoginView;
    private m_entered:boolean;
}