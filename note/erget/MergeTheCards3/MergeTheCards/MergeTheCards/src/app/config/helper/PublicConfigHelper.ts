class PublicConfigHelper{
    /** 有多少个牌组 */
    public static readonly CARD_GROUP_COUNT:number = 4;

    /**丢弃卡牌最大数量*/
    public static readonly MAX_RUBBISH_COUNT:number = 2;

    /** 最大手牌数量 */
    public static readonly MAX_HAND_CARD_COUNT:number = 2;

    /**
     * 每个牌组最多放多少张牌
     * @type {number}
     */
    public static readonly MAX_GROUP_CARDS_COUNT:number = 8;

    /**
     * 初始刷新手牌机会数
     * @type {number}
     */
    public static readonly INITIAL_REFRESH_HAND_CARD_CHANCE:number = 1;

}
