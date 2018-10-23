namespace SystemMsg {

    export class EnterScene extends VoyaMVC.Msg<{ scene: new() => App.BaseScene }> { }
    export class CloseAllViews extends VoyaMVC.Msg<{ closeSystemView: boolean }> { }
    /**
     * 程序被切换前后台时的消息
     */
    export class APP_ACTIVE_CHANGED extends VoyaMVC.Msg<{ isActive: boolean }> { }

}
