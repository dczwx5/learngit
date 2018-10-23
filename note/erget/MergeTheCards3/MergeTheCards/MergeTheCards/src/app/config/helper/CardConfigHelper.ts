class CardConfigHelper{

    public static getNormalCardByValue(value:number):CardConfig{
        let cfgTable = app.config.getConfig(CardConfig);
        let cfg:CardConfig;
        for(let key in cfgTable){
            cfg = cfgTable[key];
            if(cfg.type == Enum_CardType.NORMAL && cfg.value == value){
                return cfg;
            }
        }
        return null;
    }

    public static _maxValueCard:CardConfig;
    public static get maxValueCard():CardConfig{
        if(!this._maxValueCard){
            let normalCards = this.getCardsByType(Enum_CardType.NORMAL);
            let maxValue = 0, card:CardConfig;
            for(let i = 0, l = normalCards.length; i < l; i++){
                card = normalCards[i];
                if(card.value > maxValue){
                    maxValue = card.value;
                    this._maxValueCard = card;
                }
            }
        }
        return this._maxValueCard;
    }

    private static _cardsByType:{[type:number]:CardConfig[]} = {};
    public static getCardsByType(type:Enum_CardType):CardConfig[]{
        let result:CardConfig[] = this._cardsByType[type];
        if(result){
            return result;
        }
        let cfgTable = app.config.getConfig(CardConfig);
        let cfg:CardConfig;
        result = [];
        for(let key in cfgTable){
            cfg = cfgTable[key];
            if(cfg.type == type){
                result.push(cfg);
                if(type != Enum_CardType.NORMAL){
                    break;
                }
            }
        }
        Object.freeze(result);
        this._cardsByType[type] = result;
        return result;
    }
}
