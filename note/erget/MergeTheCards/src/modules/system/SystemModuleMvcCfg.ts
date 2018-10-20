class SystemModuleMvcCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new LoadMediator(),
            new MainSceneMediator(),
            new TestSceneMediator(),
            new PopupMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return [
            new LoadResController(),
            new StartupController(),
            new SdkModuleController(),
        ];
    }
}