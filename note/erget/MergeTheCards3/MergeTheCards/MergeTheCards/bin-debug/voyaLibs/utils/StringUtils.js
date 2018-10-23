var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    var StringUtils = (function () {
        function StringUtils() {
        }
        /**
         * 将xx=xx&xx=xx&xx=xx……这种字符串转成对象
         * @param queryFormatString
         */
        StringUtils.queryFormatToObject = function (queryFormatString) {
            var arrArgs = queryFormatString.split('&');
            var res = {};
            var arrStrArg;
            for (var i = 0, l = arrArgs.length; i < l; i++) {
                arrStrArg = arrArgs[i].split('=');
                if (arrStrArg.length >= 2) {
                    res[arrStrArg[0]] = arrStrArg[1];
                }
            }
            return res;
        };
        /**
         * 把一个键值对对象转换成HTTP传输参数格式(key=value&key=value)
         * @param obj
         * @returns {string}
         * @constructor
         */
        StringUtils.ObjectToQueryFormatString = function (obj) {
            // let res = "";
            // let isFirst = true;
            // for (let key in obj) {
            //     if(!isFirst){
            //         res += '&';
            //     }else {
            //         isFirst = false;
            //     }
            //     res += key + '=' + obj[key];
            // }
            // return res;
            var list = [];
            for (var key in obj) {
                var text = key + "=" + obj[key];
                list.push(text);
            }
            return list.join("&");
        };
        return StringUtils;
    }());
    Utils.StringUtils = StringUtils;
    __reflect(StringUtils.prototype, "Utils.StringUtils");
})(Utils || (Utils = {}));
//# sourceMappingURL=StringUtils.js.map