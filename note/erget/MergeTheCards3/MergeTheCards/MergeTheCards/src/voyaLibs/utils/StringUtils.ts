namespace Utils {
    export class StringUtils {
        /**
         * 将xx=xx&xx=xx&xx=xx……这种字符串转成对象
         * @param queryFormatString
         */
        public static queryFormatToObject(queryFormatString: string): Object {
            let arrArgs = queryFormatString.split('&');
            let res = {};
            let arrStrArg: string[];
            for (let i = 0, l = arrArgs.length; i < l; i++) {
                arrStrArg = arrArgs[i].split('=');
                if (arrStrArg.length >= 2) {
                    res[arrStrArg[0]] = arrStrArg[1];
                }
            }
            return res;
        }

        /**
         * 把一个键值对对象转换成HTTP传输参数格式(key=value&key=value)
         * @param obj
         * @returns {string}
         * @constructor
         */
        public static ObjectToQueryFormatString(obj: Object): string {
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
            let list: Array<string> = [];
            for (let key in obj) {
                let text: string = key + "=" + obj[key];
                list.push(text);
            }
            return list.join("&");
        }
    }
}
