var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    var RandomUtils = (function () {
        function RandomUtils() {
        }
        /**
         * 获取一个区间的随机数
         * @param $from 最小值
         * @param $end 最大值
         * @returns {number}
         */
        RandomUtils.limit = function ($from, $end) {
            $from = Math.min($from, $end);
            $end = Math.max($from, $end);
            var range = $end - $from;
            return $from + Math.random() * range;
        };
        /**
         * 获取一个区间的随机数(帧数)
         * @param $from 最小值
         * @param $end 最大值
         * @returns {number}
         */
        RandomUtils.limitInteger = function ($from, $end) {
            return Math.round(this.limit($from, $end));
        };
        return RandomUtils;
    }());
    Utils.RandomUtils = RandomUtils;
    __reflect(RandomUtils.prototype, "Utils.RandomUtils");
})(Utils || (Utils = {}));
//# sourceMappingURL=RandomUtils.js.map