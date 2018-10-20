class HelpModuleMvcCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new HelpWindowMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return null;
    }
}
