namespace TestModuleMsg {
    export class RunTest extends VoyaMVC.Msg { }

    export class SetTfVisible extends VoyaMVC.Msg<{ visible: boolean }>{ }
    export class SetTfContent extends VoyaMVC.Msg<{ num: number, str: string }>{ }

    export class OpenTestView extends VoyaMVC.Msg{ }
    export class CloseTestView extends VoyaMVC.Msg{ }
}
