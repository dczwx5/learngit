class BattleModel extends VoyaMVC.Model {

    /**合成过多少次2048*/
    private _scoreMultiple:number;
    /**分数*/
    private _score: number;
    /**经验*/
    private _baseExp: number;

    /** 当前丢弃了多少张牌 */
    private _rubbishCount: number;
    /**清理一桶垃圾的次数*/
    private _clearRubbishCellChance:number;

    /** 刷新手牌的剩余机会 */
    private _refreshHandCardChance: number;

    /**重置 刷新手牌机会 的次数*/
    private _resetRefreshHandCardChanceChance: number;

    /** 手牌数组 方向是新牌从小的索引进，出牌从大的索引出*/
    private _handCardList: CardConfig[];

    /**牌组数组*/
    private _cardGroupList: CardGroupModel[];

    /**复活机会*/
    private _rebirthChance:number;

    constructor() {
        super();
        this._handCardList = [];
        this._cardGroupList = [];
        let group:CardGroupModel;
        for (let i = 0; i < PublicConfigHelper.CARD_GROUP_COUNT; i++) {
            group = new CardGroupModel(i);
            group.dg_cardsMerged.register(this.onCardMerged, this);
            this._cardGroupList.push(group);
        }
    }

    newGame(playerLv: number) {
        this._score = 0;
        this._baseExp = LvConfigHelper.getExpByLv(playerLv);
        this._scoreMultiple = 1;
        this._rebirthChance = 1;
        // this._rubbishCount = 0;
        // this._clearRubbishCellChance = PublicConfigHelper.MAX_RUBBISH_COUNT;

        this.removeAllRubbish();
        this.resetClearRubbishBinChance();

        for (let i = 0, l = this._cardGroupList.length; i < l; i++) {
            this._cardGroupList[i].reset(Enum_ResetCardGroupReason.NEW_GAME);
        }

        this.refreshAllHandCards();
        this._refreshHandCardChance = PublicConfigHelper.INITIAL_REFRESH_HAND_CARD_CHANCE ;
        this.resetResetRefreshHandCardChanceChance();
        this.sendMsg(create(BattleMsg.feedBack.NewGame));
    }

    /**
     * 生成一张新牌加入手牌列表后面
     * @returns 新进的牌
     */
    unshiftNewHandCard(): CardConfig {
        if (this._handCardList.length < 2) {
            let cfg = this.getRandomCard();
            this._handCardList.unshift(cfg);
            this.sendMsg(create(BattleMsg.feedBack.UnshiftNewHandCard).init({card: cfg}));
            return cfg;
        } else {
            return null;
        }
    }

    private getRandomCard(): CardConfig {
        let cfgs = app.config.getConfig(CardConfig);
        let cfg: CardConfig;
        let lv = this.currLv;
        let cardPool: { lessThan: number, cfg: CardConfig }[] = [];
        let weight: number = 0;
        for (let key in cfgs) {
            cfg = cfgs[key];
            // if (lv >= cfg.unlock) {//TODO: 配置文件将特殊牌权值改为0后用这行代码
            if (lv >= cfg.unlock && cfg.type == Enum_CardType.NORMAL) { //TODO: 因为现在配置文件特殊牌的权值还不是0，所以过滤掉特殊牌
                weight += cfg.weight;
                cardPool.push({lessThan: weight, cfg});
            }
        }
        Utils.ArrayUtils.quickSort(cardPool, (a, b) => {
            return a.lessThan - b.lessThan;
        });
        let random = Math.random() * weight;
        for(let i = 0, l = cardPool.length; i < l; i++){
            if(random <= cardPool[i].lessThan){
                return cardPool[i].cfg;
            }
        }
        return null;
    }

    //------------------------垃圾桶------------------------Begin
    /**是否能将当前卡牌丢到垃圾桶*/
    public get enableAbandonCurrHandCard(): boolean {
        return this._rubbishCount < PublicConfigHelper.MAX_RUBBISH_COUNT;
    }

    /**
     * 将当前手牌丢到垃圾桶
     */
    abandonCurrHandCard(): boolean {
        if (!this.enableAbandonCurrHandCard) {
            return false;
        }
        this._handCardList.pop();
        this._rubbishCount++;
        this.sendMsg(create(BattleMsg.feedBack.AbandonedCurrHandCard));
        this.unshiftNewHandCard();
        return true;
    }

    removeOneRubbish(): number {
        if (this._rubbishCount > 0) {
            --this._rubbishCount;
            --this._clearRubbishCellChance;
            this.sendMsg(create(BattleMsg.feedBack.RubbishCountChanged).init({remainRubbishCount: this._rubbishCount}));
        }
        return this._rubbishCount;
    }
    removeAllRubbish(){
        this._rubbishCount = 0;
        this.sendMsg(create(BattleMsg.feedBack.RubbishCountChanged).init({remainRubbishCount: this._rubbishCount}));
    }

    /**
     * 重置清理垃圾桶次数
     */
    resetClearRubbishBinChance(){
        this._clearRubbishCellChance = PublicConfigHelper.MAX_RUBBISH_COUNT;
        this.sendMsg(create(BattleMsg.feedBack.ClearRubbishCellChanceChanged).init({chanceCount:this._clearRubbishCellChance}));
    }


    get clearRubbishCellChance(): number {
        return this._clearRubbishCellChance;
    }



    public get rubbishCount(): number {
        return this._rubbishCount;
    }
    //------------------------垃圾桶------------------------End

    //------------------------刷新所有手牌------------------------Begin

    /**
     * 重置刷新手牌机会
     */
    resetRefreshHandCardChance(){
        this._refreshHandCardChance = PublicConfigHelper.INITIAL_REFRESH_HAND_CARD_CHANCE;
        this.sendMsg(create(BattleMsg.feedBack.RefreshedHandCardsChanceChanged).init({chanceCount:this._refreshHandCardChance}));
    }

    /**
     * 消耗一次 重置 刷新手牌机会 次数
     */
    costResetRefreshHandCardChanceChance(){
        this._resetRefreshHandCardChanceChance--;
        this.sendMsg(create(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged).init({chanceCount:this._resetRefreshHandCardChanceChance}));
    }
    /**
     * 重置 刷新手牌机会 次数
     */
    resetResetRefreshHandCardChanceChance(){
        this._resetRefreshHandCardChanceChance = 1;
        this.sendMsg(create(BattleMsg.feedBack.ResetRefreshedHandCardsChanceChanceChanged).init({chanceCount:this._resetRefreshHandCardChanceChance}));
    }

    /**
     * 刷新所有手牌
     */
    refreshAllHandCards(): boolean {
        this._refreshHandCardChance--;
        for (let i = 0; i < PublicConfigHelper.MAX_HAND_CARD_COUNT; i++) {
            this._handCardList[i] = this.getRandomCard();
        }
        this.sendMsg(create(BattleMsg.feedBack.RefreshedHandCards).init({cards: this._handCardList}));
        return true;
    }

    /**剩余的刷新手牌机会*/
    public get refreshHandCardChance(): number {
        return this._refreshHandCardChance;
    }
    public get enableRefreshAllHandCards(): boolean {
        return this._refreshHandCardChance > 0;
    }

    //------------------------刷新所有手牌------------------------End

    private onCardMerged(data:{groupIdx:number, distCards:CardConfig[]}){
        let cards = data.distCards;
        let arrScore = this.calculateAddScore(cards);

        this.addScore(arrScore);

        //合成2048
        if (cards[cards.length - 1].value == CardConfigHelper.maxValueCard.value) {
            this.scoreMultiple++;
            this.getCardGroupByIdx(data.groupIdx).reset(Enum_ResetCardGroupReason.MAX_CARD_VALUE);
            this.resetClearRubbishBinChance();
            this.resetRefreshHandCardChance();
            this.resetResetRefreshHandCardChanceChance();
        }

        this.sendMsg(create(BattleMsg.feedBack.CardMerged).init({groupIdx:data.groupIdx, distCards:cards, scoreList:arrScore}));
    }
    private calculateAddScore(distCards: CardConfig[]): number[] {
        // 每次合成得分=总面值*（连击数+1）*（合成最大面值次数+1）
        // 设，合成过2次2048，即合成最大面值次数为2；
        // 第一步，32+32，连击数为0，该次合成得分=（32+32）*（0+1）*（2+1）=192
        // 第二步，64+64，连击数为1，该次合成得分=（64+64）*（1+1）*（2+1）=768
        // 第三步，128+128，连击数为2，该次合成得分=（128+128）*（2+1）*（2+1）=2304
        // 总得分=192+768+2304=3264
        let scoreList: number[] = [];
        for (let i = 0, l = distCards.length; i < l; i++) {
            scoreList.push(distCards[i].value * (i + 1) * this.scoreMultiple);
        }
        return scoreList;
    }
    private addScore(scoreList:number[]){
        let tempLv = this.currLv;
        for(let i = 0; i < scoreList.length; i++){
            this._score += scoreList[i];
        }
        let currLv = this.currLv;
        if(currLv > tempLv){
            this.sendMsg(create(BattleMsg.feedBack.LvUp).init({currLv:currLv}));
        }
        app.log(`currScore:`, this._score);
        // this.sendMsg(create(BattleMsg.feedBack.ScoreChanged).init({ currScore: this._score, scoreList:scoreList }));
    }

    //------------------------游戏结束--------------------------Begin
    checkGameOver(): boolean {

        let group: CardGroupModel;
        let isOver = true;
        for (let i = 0, l = this._cardGroupList.length; i < l; i++) {
            group = this._cardGroupList[i];
            if (group.cardsCount < PublicConfigHelper.MAX_GROUP_CARDS_COUNT) {
                isOver = false;
            }
        }
        return isOver;
    }

    rebirth(){
        this._rebirthChance--;
        let group:CardGroupModel;
        let cardsRemain = PublicConfigHelper.MAX_GROUP_CARDS_COUNT >> 1;
        for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
            group = this.getCardGroupByIdx(i);
            if(group.cardList.length > cardsRemain){
                group.cardList.length = cardsRemain;
            }
        }
        this.sendMsg(create(BattleMsg.feedBack.Rebirth));
    }

    get rebirthEnable():boolean{
        return this._rebirthChance > 0;
    }

    //------------------------游戏结束--------------------------End

    /**
     * 获取牌组
     * @param idx
     * @returns {CardGroupModel}
     */
    getCardGroupByIdx(idx: number): CardGroupModel {
        return this._cardGroupList[idx];
    }


    public get currScore(): number {
        return this._score;
    }

    public get currLv(): number {
        let lv = LvConfigHelper.getLvByExp(this.exp);
        if (lv == LvConfigHelper.maxLv) {
            lv -= 1;
        }
        return lv;
    }

    get baseExp(){
        return this._baseExp;
    }

    get exp(): number {
        return Math.min(Math.max(this._baseExp + this._score, 0), LvConfigHelper.getExpByLv(LvConfigHelper.maxLv)-1);
    }


    // set score(value: number) {
    //     this._score = value;
    //     this.sendMsg(create(BattleMsg.feedBack.ScoreChanged).init({ currScore:value }));
    // }

    get scoreMultiple(): number {
        return this._scoreMultiple;
    }

    set scoreMultiple(value: number) {
        this._scoreMultiple = value;
    }

    public get currHandCard():CardConfig{
        return this._handCardList[this._handCardList.length - 1];
    }

    public get handCardList(): CardConfig[] {
        return this._handCardList;
    }

    /**重置 刷新手牌机会 的次数*/
    public get resetRefreshHandCardChanceChance(): number {
        return this._resetRefreshHandCardChanceChance;
    }
}
