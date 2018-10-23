namespace Utils {
    export class ArrayUtils {
        /**
         * 快速排序
         * @param arr
         * @param cb 一个函数，返回值小于0则a排到b前面，大于0则b在a前面
         */
        public static quickSort<T>(arr: T[], cb: (a: T, b: T) => number): T[] {
            //如果数组<=1,则直接返回
            if (arr.length <= 1) {
                return arr;
            }
            let pivotIndex = Math.floor(arr.length >> 1);
            //找基准，并把基准从原数组删除
            // let pivot = arr.splice(pivotIndex, 1)[0];
            let pivot = arr[pivotIndex];
            //定义左右数组
            let left: T[] = [];
            let same: T[] = [];
            let right: T[] = [];

            let dir: number;
            let item: T;
            for (let i = 0; i < arr.length; i++) {
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
        }

        /**
         * 在一个数组中随机获取一个元素
         * @param arr 数组
         * @returns {T} 随机出来的结果
         */
        public static randomElement<T>(arr: T[]): T {
            let index: number = Math.floor(Math.random() * arr.length);
            return arr[index];
        }

        /**
         * 打乱数组
         * @param upsetArr
         * @param fixedIndexArr 那些下标位置不变
         * @returns {number}
         */
        public static upsetArr<T>(upsetArr: T[], fixedIndexArr?: number[]): T[] {
            let arr = upsetArr.concat();
            let content: T[];
            if (fixedIndexArr) {
                content = [];
                let spliceArr:T[];
                for (let i = 0, len = fixedIndexArr.length; i < len; i++) {
                    spliceArr = arr.splice(fixedIndexArr[i], 1);
                    content.push(spliceArr[0]);
                }
            }
            let len: number = arr.length;
            let newArr: T[] = [];
            while (len > 0) {
                let randomIndex: number = RandomUtils.limitInteger(0, --len);
                newArr.push(arr.splice(randomIndex, 1)[0]);
            }
            if (content) {
                for (let i = 0, len = fixedIndexArr.length; i < len; i++) {
                    let index: number = fixedIndexArr[i];
                    newArr.splice(index, 0, content[i]);
                }
            }
            return newArr;
        }
    }
}