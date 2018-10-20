class HandCardMediator extends VoyaMVC.Mediator{

    private readonly gap:number = 110;

    private _handCards:Card[];

    private grp_HandCard:eui.Group;

    constructor(){
        super();
        this._handCards = [];
    }

    activate(grp_HandCard:eui.Group) {
        this.grp_HandCard = grp_HandCard;

        this.regMsg(BattleMsg.feedBack.UnshiftNewHandCard, this.onUnshiftNewHandCardHandler, this);
        this.regMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCardAppended, this);
        this.regMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);

        this.updateByData();
    }

    deactivate() {

        this.unregMsg(BattleMsg.feedBack.UnshiftNewHandCard, this.onUnshiftNewHandCardHandler, this);
        this.unregMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCardAppended, this);
        this.unregMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.grp_HandCard = null;
    }

    private updateByData(){
        let cards = this._handCards;
        while(cards.length > 0){
            cards.pop().restore();
        }
        let arrCardsCfg = this.battleModel.handCardList;
        let card:Card;
        for(let i = 0, l = arrCardsCfg.length; i < l; i++){
            card = create(Card).init(arrCardsCfg[i], this.getModel(SkinModel).skinMng);
            card.x = i * this.gap;
            this._handCards.push(card);
            this.grp_HandCard.addChild(card);
        }
        this.setLastCardDragable();
    }

    private onRefreshedHandCards(msg:BattleMsg.feedBack.RefreshedHandCards){
        while ( this._handCards.length > 0){
            this._handCards.pop().restore();
        }
        let cardCfgs = msg.body.cards;
        let card:Card;
        for(let i = cardCfgs.length - 1; i >= 0; i--){
            card = create(Card).init(cardCfgs[i], this.getModel(SkinModel).skinMng);
            this.unshiftNewCard(card);
        }
    }

    private onAbandonedCurrHandCard(msg:BattleMsg.feedBack.AbandonedCurrHandCard){
        let card = this._handCards.pop();
        card.restore();
    }

    private onCardAppended(msg:BattleMsg.feedBack.CurrCardAppendedToGroup){
        let card = this._handCards.pop();
        card.restore();
    }

    private onUnshiftNewHandCardHandler(msg:BattleMsg.feedBack.UnshiftNewHandCard){
        let card = create(Card).init(msg.body.card, this.getModel(SkinModel).skinMng);
        // this._handCards.unshift(card);
        // this.grp_HandCard.addChildAt(card, 0);
        // egret.Tween.get(this.lastCard)
        //     .to({x:this.gap * (this._handCards.length-1)}, 300)
        //     .call(()=>{
        //         this.setLastCardDragable();
        //     });
        this.unshiftNewCard(card);
    }

    private unshiftNewCard(card:Card){
        this._handCards.unshift(card);
        this.grp_HandCard.addChildAt(card, 0);
        if(this._handCards.length == 1){
            card.x = 0;
            this.setLastCardDragable();
        }else{
            egret.Tween.get(this.lastCard)
                .to({x:this.gap * (this._handCards.length-1)}, 300)
                .call(()=>{
                    this.setLastCardDragable();
                });
        }
    }

    private get battleModel():BattleModel{
        return this.getModel(BattleModel);
    }

    private setLastCardDragable(){
        app.dragDropManager.regDragItem(this.lastCard);
    }

    private get lastCard():Card{
        return this._handCards[this._handCards.length-1];
    }
}
