var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var SkinConfig = (function () {
    function SkinConfig() {
    }
    SkinConfig.prototype.attrs = function () {
        return ["Id", "unlockLv", "lvColor", "cardImg", "cardColor", "gameBgColor", "rubbishBinBgColor", "rubbishBinForeColor", "scoreMultipleBgColor", "cardForeColor"];
    };
    return SkinConfig;
}());
__reflect(SkinConfig.prototype, "SkinConfig");
window["SkinConfig"] = SkinConfig;
//# sourceMappingURL=SkinConfig.js.map