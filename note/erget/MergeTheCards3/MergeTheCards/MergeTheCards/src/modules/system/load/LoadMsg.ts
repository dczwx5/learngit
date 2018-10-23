namespace LoadMsg {
    export enum Enum_LoadStyle{
        VIEW,
        MASK,
        NONE
    }
    export class LoadRes extends VoyaMVC.Msg<{ sources: string[], taskName:string }>{ }
    
    export class AddEasyLoadingTask extends VoyaMVC.Msg<{ sources: string[], taskName?:string }>{ }

    export class OpenLoadingView extends VoyaMVC.Msg<{ taskName:string, closeAfterComplete:boolean }>{ }
    export class CloseLoadingView extends VoyaMVC.Msg{ }



    export class OnTaskProgress extends VoyaMVC.Msg<{ taskName: string; curr: number; total: number; }>{ }
    export class OnTaskCancel extends VoyaMVC.Msg<{ taskName: string }>{ }
    export class OnTaskComplete extends VoyaMVC.Msg<{ taskName: string }>{ }
}