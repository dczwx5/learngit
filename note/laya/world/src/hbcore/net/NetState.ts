export default class NetState {
    constructor() {
        this.m_netStateMap = {};
    }
    private _getNetState(type:string) : NetStateInfo {
        let ret:NetStateInfo;
        ret = this.m_netStateMap[type];
        return ret;
    }
    setNetStateBusy(type:string) {
        let state:NetStateInfo = this._getNetState(type);
        if (!state) {
            state = new NetStateInfo();
            this.m_netStateMap[type] = state;
        }             
        state.isBusy = true;
    }
    setNetStateIdle(type:string) {
        let state:NetStateInfo = this._getNetState(type);
        if (!state) {
            state = new NetStateInfo();
            this.m_netStateMap[type] = state;
        }             
        state.isBusy = false;
    }
    isNetStateBusy(type:string) : boolean {
        let state:NetStateInfo = this._getNetState(type);
        if (!state) {
            return false;
        }
        return state.isBusy;
    }

    private m_netStateMap:Object; // 网络状态
}

class NetStateInfo {
    isBusy:boolean;
}