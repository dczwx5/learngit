var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var SkinConfigHelper = (function () {
    function SkinConfigHelper() {
    }
    SkinConfigHelper.getCfg = function (skinId) {
        return app.config.getConfig(SkinConfig)[skinId];
    };
    SkinConfigHelper.getArrCardSkin = function (skinId) {
        if (!this.cardSkinMap[skinId]) {
            var arr = this.cardSkinMap[skinId] = [];
            var skinCfg = this.getCfg(skinId);
            var strArrColor = skinCfg.cardColor.split(',');
            var strArrImg = skinCfg.cardImg.split(',');
            for (var i = 0, l = strArrColor.length; i < l; i++) {
                arr.push({ color: parseInt('0x' + strArrColor[i], 16), img: strArrImg[i] });
            }
        }
        return this.cardSkinMap[skinId];
    };
    SkinConfigHelper.getCardColor = function (skinId, cardCfg) {
        return this.getArrCardSkin(skinId)[cardCfg.id - 1].color;
    };
    SkinConfigHelper.getCardImg = function (skinId, cardCfg) {
        return this.getArrCardSkin(skinId)[cardCfg.id - 1].img;
    };
    SkinConfigHelper.getLvColor = function (skinId, lv) {
        if (!this.arrLvColor) {
            this.arrLvColor = [];
            var arrStrLvColor = this.getCfg(skinId).lvColor.split(',');
            for (var i = 0, l = arrStrLvColor.length; i < l; i++) {
                this.arrLvColor.push(parseInt("0x" + arrStrLvColor[i], 16));
            }
        }
        return this.arrLvColor[lv - 1];
    };
    SkinConfigHelper.getScoreMultipleBgColor = function (skinId) {
        return parseInt('0x' + this.getCfg(skinId).scoreMultipleBgColor, 16);
    };
    SkinConfigHelper.getGameBgColor = function (skinId) {
        return parseInt('0x' + this.getCfg(skinId).gameBgColor, 16);
    };
    SkinConfigHelper.getRubbishCellForeColor = function (skinId) {
        return parseInt('0x' + this.getCfg(skinId).rubbishBinForeColor, 16);
    };
    SkinConfigHelper.getRubbishCellBgColor = function (skinId) {
        return parseInt('0x' + this.getCfg(skinId).rubbishBinBgColor, 16);
    };
    SkinConfigHelper.cardSkinMap = {};
    return SkinConfigHelper;
}());
__reflect(SkinConfigHelper.prototype, "SkinConfigHelper");
//# sourceMappingURL=SkinConfigHelper.js.map