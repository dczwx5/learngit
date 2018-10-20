var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var SDK;
(function (SDK) {
    /**
     * 渠道标识
     */
    var Enum_PF = (function () {
        function Enum_PF() {
        }
        Object.defineProperty(Enum_PF, "LOCAL", {
            /**
             * 本地
             * @returns {string}
             * @constructor
             */
            get: function () {
                return "";
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Enum_PF, "WANBA", {
            /**
             * 玩吧
             * @returns {string}
             * @constructor
             */
            get: function () {
                return "wanba_ts";
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Enum_PF, "YYB", {
            /**
             * 应用宝
             * @returns {string}
             * @constructor
             */
            get: function () {
                return "yingyongbao";
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Enum_PF, "WX", {
            /**
             * 微信
             * @returns {string}
             * @constructor
             */
            get: function () {
                return "weixin";
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(Enum_PF, "H5SDK", {
            /**
             * 官方微信
             */
            get: function () {
                return "h5sdk";
            },
            enumerable: true,
            configurable: true
        });
        return Enum_PF;
    }());
    SDK.Enum_PF = Enum_PF;
    __reflect(Enum_PF.prototype, "SDK.Enum_PF");
})(SDK || (SDK = {}));
//# sourceMappingURL=Enum_PF.js.map