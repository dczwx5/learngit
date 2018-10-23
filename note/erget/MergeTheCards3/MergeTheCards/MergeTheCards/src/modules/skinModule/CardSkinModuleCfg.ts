class CardSkinModuleCfg extends VoyaMVC.MvcConfigBase{

    protected getMediatorList(): VoyaMVC.IMediator[] {
        return [
            new CardSkinWindowMediator()
        ];
    }

    protected getControllerList(): VoyaMVC.IController[] {
        return [];
    }
}
