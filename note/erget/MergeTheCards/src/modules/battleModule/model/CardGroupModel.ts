class CardGroupModel extends VoyaMVC.Model{

    /** 牌组编号 */
    public readonly groupIdx:number;

    private _cardList:CardConfig[];

    public readonly dg_cardsMerged:VL.Delegate<{groupIdx:number, distCards:CardConfig[]}>;

    constructor(groupIdx:number){
        super();
        this._cardList = [];
        this.dg_cardsMerged = new VL.Delegate<{groupIdx:number, distCards:CardConfig[]}>();
        this.groupIdx = groupIdx;
    }

    /**
     * 添加一张卡牌
     * @param card
     */
    appendCard(card:CardConfig):boolean{
        if(this.cardList.length >= PublicConfigHelper.MAX_GROUP_CARDS_COUNT ){
            switch (card.type){
                case  Enum_CardType.NORMAL:
                    if(card.value != this.lastCard.value){
                        return false;
                    }
                    break;
            }
        }
        this._cardList.push(card);
        this.sendMsg(create(BattleMsg.feedBack.CurrCardAppendedToGroup).init({groupIdx:this.groupIdx, card:card}));
        return true;
    }
    /**
     * 合并所有能合并的卡牌
     * @returns {CardConfig[]} 合并完成后的卡牌
     */
    mergCard(){
        let distCards:CardConfig[] = [];
        let card:CardConfig;
        while (true){
            card = this.checkMergeCard();
            if(card){
                distCards.push(card);
            }else {
                if(distCards.length > 0){
                    this.dg_cardsMerged.boardcast({groupIdx:this.groupIdx, distCards:distCards});
                }
                break;
            }
        }
        return distCards;
    }

    /**
     * 合并一张卡牌
     * @returns {CardConfig}
     */
    private checkMergeCard():CardConfig{
        let list = this._cardList;
        if(list.length >= 2){
            let from = this.lastCard;
            let to =  this.lastButOneCard;
            if(to.value == from.value){
                let distCard = CardConfigHelper.getNormalCardByValue(to.value << 1);
                if(distCard) {
                    list[list.length - 2] = distCard;
                    list.pop();
                }
                return distCard;
            }
            return null;
        }else{
            return null;
        }
    }

    reset(reason:Enum_ResetCardGroupReason){
        let remainCards:CardConfig[] = [];
        while(this._cardList.length > 0){
            remainCards.push(this._cardList.pop());
        }
        this.sendMsg(create(BattleMsg.feedBack.CardGroupReset).init({groupIdx:this.groupIdx, reason:reason}));
    }

    get cardList(): CardConfig[] {
        return this._cardList;
    }

    get cardsCount():number{
        return this._cardList.length;
    }

    public get lastButOneCard():CardConfig{
        return this._cardList[this._cardList.length - 2];
    }
    public get lastCard():CardConfig{
        return this._cardList[this._cardList.length - 1];
    }
}
