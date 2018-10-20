class BattleViewMediator extends ViewMediator {

    protected view: BattleView;

    private _handCardMediator: HandCardMediator;
    private _recordMediator: BattleRecordMediator;

    private _groupReset:number = -1;
    private _groupResetRemovedCards:CardConfig[];

    constructor() {
        super();
        this._handCardMediator = new HandCardMediator();
        this._recordMediator = new BattleRecordMediator();
    }

    protected onViewOpen() {
        let view = this.view;
        view.rect_bg.fillColor = SkinConfigHelper.getGameBgColor(this.getModel(PlayerModel).skinId);
        let groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        let group:CardGroup;
        let skinMng = this.getModel(SkinModel).skinMng;
        for(let i = 0; i < groupCount; i++){
            group = view.getCardGroup(i);
            group.activate(i, skinMng);
            group.dg_onDropIn.register(this.onCardDropToGroup, this);
        }
        view.rubbishBin.activate(this.getModel(PlayerModel).skinId);

        this._handCardMediator.activate(view.grp_handCards);
        this._recordMediator.activate(view.battlePanel);

        view.rubbishBin.dg_onDropIn.register(this.onCardDropToRubbishBin, this);

        EventHelper.addTapEvent(view.rubbishBin, this.onTap, this);
        EventHelper.addTapEvent(view.btn_refreshHandCard, this.onTap, this);
        EventHelper.addTapEvent(view.btn_menu, this.onTap, this);
        EventHelper.addTapEvent(view.btn_help, this.onTap, this);

        this.regMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.regMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.regMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCarrCardAppendedToGroup, this);
        this.regMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.regMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.regMsg(BattleMsg.feedBack.RubbishCountChanged, this.onRubbishCountChanged, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.regMsg(BattleMsg.feedBack.RefreshedHandCardsChanceChanged, this.onRefreshedHandCardsChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged, this.onResetRefreshedHandCardsChanceChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.ClearRubbishCellChanceChanged, this.onClearRubbishCellChanceChanged, this);
        this.regMsg(BattleMsg.feedBack.Rebirth, this.onRebirth, this);
        this.updateByData();
    }

    protected onViewClose() {
        let view = this.view;
        let groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        let group:CardGroup;
        for(let i = 0; i < groupCount; i++){
            group = view.getCardGroup(i);
            group.dg_onDropIn.unregister(this.onCardDropToGroup);
            group.deactivate();
        }
        view.rubbishBin.deactivate();

        this._handCardMediator.deactivate();
        this._recordMediator.deactivate();

        view.rubbishBin.dg_onDropIn.unregister(this.onCardDropToRubbishBin);


        EventHelper.removeTapEvent(view.rubbishBin, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_refreshHandCard, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_menu, this.onTap, this);
        EventHelper.removeTapEvent(view.btn_help, this.onTap, this);

        this.unregMsg(BattleMsg.feedBack.NewGame, this.onNewGame, this);
        this.unregMsg(BattleMsg.feedBack.CardGroupReset, this.onCardGroupReset, this);
        this.unregMsg(BattleMsg.feedBack.CurrCardAppendedToGroup, this.onCarrCardAppendedToGroup, this);
        this.unregMsg(BattleMsg.feedBack.CardMerged, this.onCardMerged, this);
        this.unregMsg(BattleMsg.feedBack.AbandonedCurrHandCard, this.onAbandonedCurrHandCard, this);
        this.unregMsg(BattleMsg.feedBack.RubbishCountChanged, this.onRubbishCountChanged, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCards, this.onRefreshedHandCards, this);
        this.unregMsg(BattleMsg.feedBack.RefreshedHandCardsChanceChanged, this.onRefreshedHandCardsChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged, this.onResetRefreshedHandCardsChanceChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.ClearRubbishCellChanceChanged, this.onClearRubbishCellChanceChanged, this);
        this.unregMsg(BattleMsg.feedBack.Rebirth, this.onRebirth, this);
    }

    private updateByData() {
        let battleModel = this.battleModel;
        let view = this.view;

        //-----------更新牌组------------
        let skinMng = this.getModel(SkinModel).skinMng;
        let groupCount = PublicConfigHelper.CARD_GROUP_COUNT;
        let groupModel:CardGroupModel;
        let group:CardGroup;
        let cardCfgs:CardConfig[];
        let card:Card;
        for(let i = 0; i < groupCount; i++){
            group = view.getCardGroup(i);
            group.removeAllCards();
            groupModel = battleModel.getCardGroupByIdx(i);
            cardCfgs = groupModel.cardList;
            for(let j = 0, jl = cardCfgs.length; j < jl; j++){
                card = create(Card).init(cardCfgs[i], skinMng);
                group.appendCard(card);
            }
        }
        view.btn_refreshHandCard.enableRefresh = this.battleModel.refreshHandCardChance > 0;

        this.updateRubbishBin();
    }

    private onTap(e:egret.TouchEvent){
        const view = this.view;
        switch (e.currentTarget){
            case view.rubbishBin:
                this.sendMsg(create(BattleMsg.cmd.ClearOneRubbishCell));
                break;
            case view.btn_refreshHandCard:
                this.sendMsg(create(BattleMsg.cmd.RefreshHandCard));
                break;
            case view.btn_menu:
                this.sendMsg(create(BattleMsg.cmd.OpenBattleMenu));
                break;
            case view.btn_help:
                this.sendMsg(create(HelpModuleMsg.OPEN_HELP_VIEW));
                break;
        }
    }

    private onCardDropToRubbishBin(data:{ dragItem: Card; container: RubbishBin }){
        this.sendMsg(create(BattleMsg.cmd.DropCurrCardToRubbishBin).init({card:data.dragItem}));
    }

    private onCardDropToGroup(data:{ dragItem: Card; container: CardGroup }){
        let group = data.container;
        this.sendMsg(create(BattleMsg.cmd.AppendHandCardToGroup).init({groupId:group.groupId, card:data.dragItem}));
    }

    private async onCardMerged(msg:BattleMsg.feedBack.CardMerged){
        let group = this.view.getCardGroup(msg.body.groupIdx);
        let cards = msg.body.distCards;
        let scoreList = msg.body.scoreList;
        for(let i = 0;i < cards.length; i++){
            await group.mergeCard(cards[i], scoreList[i]);
        }
        if(this._groupReset == group.groupId){
            await group.removeAllCardsAsync();
            this._groupReset = -1;
            this._groupResetRemovedCards = null;
        }
    }

    private onCarrCardAppendedToGroup(msg:BattleMsg.feedBack.CurrCardAppendedToGroup){
        // let card = msg.body.card;
        let group = this.view.getCardGroup(msg.body.groupIdx);
        let card = create(Card).init(msg.body.card, this.getModel(SkinModel).skinMng);
        group.appendCard(card);
    }

    private onNewGame(msg:BattleMsg.feedBack.NewGame){
        // this.updateRubbishBin();
        // this.updateRefreshHandCardsChance();
    }

    private onCardGroupReset(msg:BattleMsg.feedBack.CardGroupReset) {
        let groupIdx = msg.body.groupIdx;
        let reason = msg.body.reason;
        switch (reason){
            case Enum_ResetCardGroupReason.NEW_GAME:
                this.view.getCardGroup(groupIdx).removeAllCards();
                break;
            case Enum_ResetCardGroupReason.MAX_CARD_VALUE:
                this._groupReset = groupIdx;
                break;
        }
    }

    private onAbandonedCurrHandCard(msg:BattleMsg.feedBack.AbandonedCurrHandCard){
        this.updateRubbishBin();
    }
    private onRubbishCountChanged(msg:BattleMsg.feedBack.RubbishCountChanged){
        this.updateRubbishBin();
    }
    private onClearRubbishCellChanceChanged(msg:BattleMsg.feedBack.ClearRubbishCellChanceChanged){
        this.updateRubbishBin();
    }
    private updateRubbishBin(){
        let rubbishBin = this.view.rubbishBin;
        let battleModel = this.battleModel;
        let wxModel = this.getModel(WxSDKModel);
        rubbishBin.rubbishCount = battleModel.rubbishCount;
        rubbishBin.clearCellChance = wxModel.isExamine ? 0 : battleModel.clearRubbishCellChance;
    }

    private onRefreshedHandCards(msg:BattleMsg.feedBack.RefreshedHandCards){
        this.updateRefreshHandCardsChance();
    }
    private onRefreshedHandCardsChanceChanged(msg:BattleMsg.feedBack.RefreshedHandCardsChanceChanged){
        this.updateRefreshHandCardsChance();
    }
    private onResetRefreshedHandCardsChanceChanceChanged(msg:BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged){
        this.updateRefreshHandCardsChance();
    }
    private updateRefreshHandCardsChance(){
        this.view.btn_refreshHandCard.enableRefresh = this.battleModel.enableRefreshAllHandCards;
        this.view.btn_refreshHandCard.enableReset = this.battleModel.resetRefreshHandCardChanceChance > 0;
    }

    private onRebirth(msg:BattleMsg.feedBack.Rebirth){
        let removeCardsCount = PublicConfigHelper.MAX_GROUP_CARDS_COUNT >> 1;
        for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
            this.view.getCardGroup(i).removeCards(removeCardsCount);
        }
    }

    protected get viewClass(): new() => BattleView {
        return BattleView;
    }

    protected get openViewMsg() {
        return BattleMsg.cmd.OpenBattleView;
    }

    protected get closeViewMsg() {
        return BattleMsg.cmd.CloseBattleView;
    }

    private get battleModel(){
        return this.getModel(BattleModel);
    }

}
