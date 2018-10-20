class TestModuleCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new TestMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return [
            new TestController()
        ];
    }

}