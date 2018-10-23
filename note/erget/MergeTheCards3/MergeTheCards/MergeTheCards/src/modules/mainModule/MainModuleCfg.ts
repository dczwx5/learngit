class MainModuleCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new MainViewMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return null;
    }
}
