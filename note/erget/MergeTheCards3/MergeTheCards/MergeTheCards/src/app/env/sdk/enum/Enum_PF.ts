namespace SDK {
    /**
     * 渠道标识
     */
    export class Enum_PF {
        /**
         * 本地
         * @returns {string}
         * @constructor
         */
        public static get LOCAL(): string {
            return "";
        }

        /**
         * 玩吧
         * @returns {string}
         * @constructor
         */
        public static get WANBA(): string {
            return "wanba_ts";
        }

        /**
         * 应用宝
         * @returns {string}
         * @constructor
         */
        public static get YYB(): string {
            return "yingyongbao";
        }

        /**
         * 微信
         * @returns {string}
         * @constructor
         */
        public static get WX(): string {
            return "weixin";
        }

        /**
         * 官方微信
         */
        public static get H5SDK(): string {
            return "h5sdk";
        }
    }
}