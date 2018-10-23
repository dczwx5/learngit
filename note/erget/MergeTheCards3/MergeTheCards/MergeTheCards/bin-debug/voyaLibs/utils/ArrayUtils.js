var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    var ArrayUtils = (function () {
        function ArrayUtils() {
        }
        /**
         * 快速排序
         * @param arr
         * @param cb 一个函数，返回值小于0则a排到b前面，大于0则b在a前面
         */
        ArrayUtils.quickSort = function (arr, cb) {
            //如果数组<=1,则直接返回
            if (arr.length <= 1) {
                return arr;
            }
            var pivotIndex = Math.floor(arr.length >> 1);
            //找基准，并把基准从原数组删除
            // let pivot = arr.splice(pivotIndex, 1)[0];
            var pivot = arr[pivotIndex];
            //定义左右数组
            var left = [];
            var same = [];
            var right = [];
            var dir;
            var item;
            for (var i = 0; i < arr.length; i++) {
                item = arr[i];
                dir = cb(arr[i], pivot);
                if (dir < 0) {
                    left.push(item);
                }
                else if (dir == 0) {
                    same.push(item);
                }
                else if (dir > 0) {
                    right.push(item);
                }
            }
            //递归
            return this.quickSort(left, cb).concat(same, this.quickSort(right, cb));
        };
        /**
         * 在一个数组中随机获取一个元素
         * @param arr 数组
         * @returns {T} 随机出来的结果
         */
        ArrayUtils.randomElement = function (arr) {
            var index = Math.floor(Math.random() * arr.length);
            return arr[index];
        };
        /**
         * 打乱数组
         * @param upsetArr
         * @param fixedIndexArr 那些下标位置不变
         * @returns {number}
         */
        ArrayUtils.upsetArr = function (upsetArr, fixedIndexArr) {
            var arr = upsetArr.concat();
            var content;
            if (fixedIndexArr) {
                content = [];
                var spliceArr = void 0;
                for (var i = 0, len_1 = fixedIndexArr.length; i < len_1; i++) {
                    spliceArr = arr.splice(fixedIndexArr[i], 1);
                    content.push(spliceArr[0]);
                }
            }
            var len = arr.length;
            var newArr = [];
            while (len > 0) {
                var randomIndex = Utils.RandomUtils.limitInteger(0, --len);
                newArr.push(arr.splice(randomIndex, 1)[0]);
            }
            if (content) {
                for (var i = 0, len_2 = fixedIndexArr.length; i < len_2; i++) {
                    var index = fixedIndexArr[i];
                    newArr.splice(index, 0, content[i]);
                }
            }
            return newArr;
        };
        return ArrayUtils;
    }());
    Utils.ArrayUtils = ArrayUtils;
    __reflect(ArrayUtils.prototype, "Utils.ArrayUtils");
})(Utils || (Utils = {}));
//# sourceMappingURL=ArrayUtils.js.map