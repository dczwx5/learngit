/**
 * 重置牌组的原因
 */
var Enum_ResetCardGroupReason;
(function (Enum_ResetCardGroupReason) {
    /** 新牌局 */
    Enum_ResetCardGroupReason[Enum_ResetCardGroupReason["NEW_GAME"] = 1] = "NEW_GAME";
    /** 已合出最大牌值 */
    Enum_ResetCardGroupReason[Enum_ResetCardGroupReason["MAX_CARD_VALUE"] = 2] = "MAX_CARD_VALUE";
    /** 炸弹牌 */
    Enum_ResetCardGroupReason[Enum_ResetCardGroupReason["BOMB_CARD"] = 3] = "BOMB_CARD";
})(Enum_ResetCardGroupReason || (Enum_ResetCardGroupReason = {}));
//# sourceMappingURL=Enum_ResetCardGroupReason.js.map