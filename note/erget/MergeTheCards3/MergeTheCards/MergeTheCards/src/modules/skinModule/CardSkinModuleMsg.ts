namespace CardSkinModuleMsg{
    export class OpenCardSkinWindow extends VoyaMVC.Msg{}
    export class CloseCardSkinWindow extends VoyaMVC.Msg{}

    export class ChangeSkin extends VoyaMVC.Msg<{skinCfg:SkinConfig}>{}
}
