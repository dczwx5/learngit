class BattleModuleCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new BattleViewMediator(),
            new BattleMenuWindowMediator(),
            new BattleSettleMediator(),
            new RebirthConfirmMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return [
            new BattleModuleCtrl()
        ];
    }
}
