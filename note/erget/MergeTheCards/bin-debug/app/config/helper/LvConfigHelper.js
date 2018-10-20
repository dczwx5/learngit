var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var LvConfigHelper = (function () {
    function LvConfigHelper() {
    }
    Object.defineProperty(LvConfigHelper, "arrLvExp", {
        get: function () {
            if (!this._arrLvExp) {
                var arr = [];
                var cfg = app.config.getConfig(LvConfig);
                for (var key in cfg) {
                    arr.push(cfg[key].needExp);
                }
                Utils.ArrayUtils.quickSort(arr, function (a, b) { return a - b; });
                this._arrLvExp = arr;
            }
            return this._arrLvExp;
        },
        enumerable: true,
        configurable: true
    });
    /**
     * 根据经验值获取等级
     * @param exp
     * @returns {number}
     */
    LvConfigHelper.getLvByExp = function (exp) {
        var lv;
        var currLvExp;
        var nextLvExp;
        for (var i = 0, l = this.arrLvExp.length; i < l; i++) {
            currLvExp = this.arrLvExp[i];
            nextLvExp = this.arrLvExp[i + 1];
            if (!nextLvExp && nextLvExp != 0) {
                lv = i + 1;
                break;
            }
            if (exp >= currLvExp && exp < nextLvExp) {
                lv = i + 1;
                break;
            }
        }
        return lv;
    };
    /**
     * 根据等级获取所需经验值
     * @param lv
     * @returns {number}
     */
    LvConfigHelper.getExpByLv = function (lv) {
        return this.arrLvExp[lv - 1];
    };
    Object.defineProperty(LvConfigHelper, "maxLv", {
        /**
         * 最大等级
         * @returns {number}
         */
        get: function () {
            return this.arrLvExp.length;
        },
        enumerable: true,
        configurable: true
    });
    return LvConfigHelper;
}());
__reflect(LvConfigHelper.prototype, "LvConfigHelper");
//# sourceMappingURL=LvConfigHelper.js.map