var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var CardConfig = (function () {
    function CardConfig() {
    }
    CardConfig.prototype.attrs = function () {
        return ["id", "type", "value", "unlock", "weight"];
    };
    return CardConfig;
}());
__reflect(CardConfig.prototype, "CardConfig");
window["CardConfig"] = CardConfig;
//# sourceMappingURL=CardConfig.js.map