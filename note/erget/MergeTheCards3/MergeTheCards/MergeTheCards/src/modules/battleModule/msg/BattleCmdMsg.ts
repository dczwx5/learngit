namespace BattleMsg {
    export namespace cmd {
        /**进入战斗*/
        export class EnterBattle extends VoyaMVC.Msg { }
        /**打开战斗界面*/
        export class OpenBattleView extends VoyaMVC.Msg{ }
        /**关闭战斗界面*/
        export class CloseBattleView extends VoyaMVC.Msg{ }

        /**打开战斗菜单界面*/
        export class OpenBattleMenu extends VoyaMVC.Msg{ }
        /**关闭战斗菜单界面*/
        export class CloseBattleMenu extends VoyaMVC.Msg{ }

        /**打开战斗菜单界面*/
        export class OpenBattleSettleView extends VoyaMVC.Msg{ }
        /**关闭战斗菜单界面*/
        export class CloseBattleSettleView extends VoyaMVC.Msg{ }

        /**打开复活窗口*/
        export class OpenRebirthWindow extends VoyaMVC.Msg<{onClose:()=>void}>{ }
        /**关闭复活窗口*/
        export class CloseRebirthWindow extends VoyaMVC.Msg{ }

        /**从战斗中回到主界面*/
        export class BackToMainView extends VoyaMVC.Msg{ }
        /**重新开一局*/
        export class PlayAgain extends VoyaMVC.Msg{ }


        /**将当前卡牌添加到组*/
        export class AppendHandCardToGroup extends VoyaMVC.Msg<{ groupId:number, card:Card }>{ }

        /** 将当前手牌扔到垃圾箱 */
        export class DropCurrCardToRubbishBin extends VoyaMVC.Msg<{ card:Card }>{ }

        /** 清理一个垃圾格子 */
        export class ClearOneRubbishCell extends VoyaMVC.Msg{ }

        /** 刷新手牌 */
        export class RefreshHandCard extends VoyaMVC.Msg{ }

        /** 复活 */
        export class Rebirth extends VoyaMVC.Msg{ }


    }
}

