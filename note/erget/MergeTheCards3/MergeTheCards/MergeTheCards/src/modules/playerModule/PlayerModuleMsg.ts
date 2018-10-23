namespace PlayerModuleMsg{
    export namespace feedBack{
        /**
         * 玩家数据改变
         * 变更了的的数据
         */
        export class PlayerDataChanged extends VoyaMVC.Msg<{exp?:number, lv?:number}> { }
    }
}
