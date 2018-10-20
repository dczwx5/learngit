var MathUtils = (function () {
    function MathUtils() {
    }
    /**
     * 随机数（包含max）
     * @param min
     * @param max
     * @returns {number}
     */
    MathUtils.random = function (min, max) {
        if (max === void 0) { max = null; }
        if (max === null) {
            max = min;
            min = 0;
        }
        return Math.floor(min + Math.random() * (max - min + 1));
    };
    /**
     * 打乱数组
     * @param arr
     * @param fixedIndex 那些下标位置不变
     * @returns {number}
     */
    MathUtils.upsetArr = function (upsetArr, fixedIndexArr) {
        var arr = upsetArr.concat();
        var content;
        if (fixedIndexArr) {
            content = [];
            for (var i = 0, len = fixedIndexArr.length; i < len; i++) {
                var spliceArr = arr.splice(fixedIndexArr[i], 1);
                content.push(spliceArr[0]);
            }
        }
        var len = arr.length;
        var newArr = [];
        while (len > 0) {
            var randomIndex = MathUtils.random(0, --len);
            newArr.push(arr.splice(randomIndex, 1)[0]);
        }
        if (content) {
            for (var i = 0, len = fixedIndexArr.length; i < len; i++) {
                var index = fixedIndexArr[i];
                newArr.splice(index, 0, content[i]);
            }
        }
        return newArr;
    };
    MathUtils.twoPonitDistance = function (px1, py1, px2, py2) {
        return Math.sqrt(Math.pow((px1 - px2), 2) + Math.pow((py1 - py2), 2));
    };
    return MathUtils;
}());
