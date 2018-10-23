namespace Utils {
    export class RandomUtils {
        /**
         * 获取一个区间的随机数
         * @param $from 最小值
         * @param $end 最大值
         * @returns {number}
         */
        public static limit($from: number, $end: number): number {
            $from = Math.min($from, $end);
            $end = Math.max($from, $end);
            let range = $end - $from;
            return $from + Math.random() * range;
        }

        /**
         * 获取一个区间的随机数(帧数)
         * @param $from 最小值
         * @param $end 最大值
         * @returns {number}
         */
        public static limitInteger($from: number, $end: number): number {
            return Math.round(this.limit($from, $end));
        }
    }
}