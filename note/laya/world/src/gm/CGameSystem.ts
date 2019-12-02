import { framework } from "../hbcore/framework/FrameWork";
import { log } from "../hbcore/framework/log";
import { CComponent } from "../hbcore/framework/pattern/CComponent";
import CGameEventComponent from "./component/CGameEventComponent";
import CGameConfigComponent from "./component/CGameConfigComponent";
import CGameEnvironmentComponent from "./component/CGameEnvironmentComponent";
import CGameNetworkComponent from "./component/CGameNetworkComponent";

/**
 * ...
 * @author auto
 */
export class CGameSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onDestroy() : void {
		super.onDestroy();

	}

	protected onAwake() : void {
		log.log('CGameSystem.onAwake');
		
        this.addBean(this.m_config = new CGameConfigComponent());
        this.addBean(this.m_environment = new CGameEnvironmentComponent());
        this.addBean(this.m_network = new CGameNetworkComponent());
        this.addBean(this.m_eventDispatcher = new CGameEventComponent());

		super.onAwake();
	}

	protected onStart() : boolean {
        let ret:boolean = super.onStart();
		return ret;
    }
    get environment() : CGameEnvironmentComponent { return this.m_environment; }
    private m_environment:CGameEnvironmentComponent;

    get config() : CGameConfigComponent { return this.m_config; }
    private m_config:CGameConfigComponent;

    get network() : CGameNetworkComponent { return this.m_network; }
    private m_network:CGameNetworkComponent;

    get eventDispatcher() : CGameEventComponent { return this.m_eventDispatcher; }
    private m_eventDispatcher:CGameEventComponent;
}
