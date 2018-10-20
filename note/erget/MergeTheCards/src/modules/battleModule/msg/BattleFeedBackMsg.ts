namespace BattleMsg {
    export namespace feedBack {

        export class NewGame extends VoyaMVC.Msg { }
        /**
         * 卡牌发生合并
         * 牌组
         */
        export class CardMerged extends VoyaMVC.Msg<{groupIdx:number, distCards:CardConfig[], scoreList:number[]}> { }
        /**
         * 手牌加入了牌组
         * 牌组 放入的牌
         */
        export class CurrCardAppendedToGroup extends VoyaMVC.Msg<{groupIdx:number, card:CardConfig}> { }

        /**
         * 重置了某个牌组
         * 牌组 原因
         */
        export class CardGroupReset extends VoyaMVC.Msg<{groupIdx:number, reason:Enum_ResetCardGroupReason}> { }

        /**
         * 手牌加入了一张卡牌
         * 新牌
         */
        export class UnshiftNewHandCard extends VoyaMVC.Msg<{card:CardConfig}> { }

        /**
         * 刷新所有手牌
         * 新的手牌们
         */
        export class RefreshedHandCards extends VoyaMVC.Msg<{cards:CardConfig[]}> { }

        /**
         * 刷新手牌次数变更
         */
        export class RefreshedHandCardsChanceChanged extends VoyaMVC.Msg<{chanceCount:number}> { }
        /**
         * 重置 刷新手牌机会 的次数变更
         */
        export class ResetRefreshedHandCardsChanceChanceChanged extends VoyaMVC.Msg<{chanceCount:number}> { }


        /**
         * 清理垃圾桶次数变更
         */
        export class ClearRubbishCellChanceChanged extends VoyaMVC.Msg<{chanceCount:number}> { }

        /**
         * 当前手牌被丢弃
         */
        export class AbandonedCurrHandCard extends VoyaMVC.Msg { }

        /**
         * 垃圾桶移除了一张卡牌
         * 垃圾桶剩余卡牌数
         */
        export class RubbishCountChanged extends VoyaMVC.Msg<{remainRubbishCount:number}> { }

        /**
         * 升级了
         */
        export class LvUp extends VoyaMVC.Msg<{currLv:number}> { }

        /**
         * 复活了
         */
        export class Rebirth extends VoyaMVC.Msg { }

    }
}
