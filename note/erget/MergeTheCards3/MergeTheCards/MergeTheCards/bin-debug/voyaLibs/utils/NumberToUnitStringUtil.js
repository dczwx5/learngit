var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    var NumberToUnitStringUtil = (function () {
        function NumberToUnitStringUtil() {
        }
        /**
         * 把一个数转换成用单位表示的字符串形式
         * @param num 要处理的数
         * @param maxUnitPow 最大单位带多少个0
         * @param stepLen 步长(每几位取一次单位)
         * @param digs 保留几位小数
         * @returns {string}
         */
        NumberToUnitStringUtil.convert = function (num, maxUnitPow, stepLen, digs) {
            if (maxUnitPow === void 0) { maxUnitPow = 44; }
            if (stepLen === void 0) { stepLen = 4; }
            if (digs === void 0) { digs = 2; }
            var temp, unit;
            for (var i = maxUnitPow; i >= 4; i -= stepLen) {
                if (num / Math.pow(10, i) >= 1) {
                    temp = Math.pow(10, i - digs);
                    unit = this.unit[i] || "";
                    return Math.floor(num / (temp > 0 ? temp : 1)) / Math.pow(10, digs) + unit;
                }
            }
            return num.toString();
        };
        // 十、数字后1个0
        // 百、数字后2个0
        // 千、数字后3个0
        // 万、数字后4个0
        // 亿、数字后8个0
        // 兆、数字后12个0
        // 京、数字后16个0
        // 垓、数字后20个0
        // 秭、数字后24个0
        // 穰、数字后28个0
        // 沟、数字后32个0
        // 涧、数字后36个0
        // 正、数字后40个0
        // 载、数字后44个0
        NumberToUnitStringUtil.unit = {
            2: "百",
            3: "千",
            4: "万",
            5: "十万",
            6: "百万",
            7: "千万",
            8: "亿",
            9: "十亿",
            10: "百亿",
            11: "千亿",
            12: "兆",
            16: "京",
            20: "垓",
            24: "秭",
            28: "穰",
            32: "沟",
            36: "涧",
            40: "正",
            44: "载",
        };
        return NumberToUnitStringUtil;
    }());
    Utils.NumberToUnitStringUtil = NumberToUnitStringUtil;
    __reflect(NumberToUnitStringUtil.prototype, "Utils.NumberToUnitStringUtil");
})(Utils || (Utils = {}));
//# sourceMappingURL=NumberToUnitStringUtil.js.map