/**
 * 重置牌组的原因
 */
enum Enum_ResetCardGroupReason{
    /** 新牌局 */
    NEW_GAME = 1,
        /** 已合出最大牌值 */
    MAX_CARD_VALUE = 2,
        /** 炸弹牌 */
    BOMB_CARD = 3
}
