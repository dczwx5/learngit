namespace VL {
    export namespace Net {
        /**
         * HTTP请求的信息
         */
        export class HttpReqPack extends VL.ObjectCache.CacheableClass {

            /**
             * 地址
             */
            private _baseUrl: string;
            /**
             * 接口
             */
            private _key: string;
            /**
             * 请求方式
             */
            private _method: string;

            private _reqHead: Object;
            /**
             * 返回的数据格式：egret.HttpResponseType中的值，一般数据交互都是用egret.HttpResponseType.TEXT
             */
            private _respFormat: string;
            /**
             * 键值对形式:{key:value, key:value}
             */
            private _data: any;

            private _otherData: any;

            private _reqFormat: string;

            /**
             * 直接获取并为一个HttpReqMsg赋值
             * @param baseUrl
             * @param key
             * @param data 如果reqFormat参数不为二进制数据，则将reqFormat的键值对形式:{key:value, key:value}转换为 key=value&key=value 的HTTP参数形式
             * @param otherData 一些其他数据，用于回传给回调函数
             * @param reqHead:
             * @param method
             * @param respFormat
             * @param reqFormat
             */
            public init(baseUrl: string, key: string, method: string, data: any = null, otherData: any = null, reqHead: any = null, respFormat: string = egret.HttpResponseType.TEXT, reqFormat: string = egret.URLLoaderDataFormat.TEXT): HttpReqPack {
                this._baseUrl = baseUrl;
                this._key = key;
                this._method = method;
                this._reqHead = reqHead;
                this._respFormat = respFormat;
                this._reqFormat = reqFormat;
                if (reqFormat == egret.URLLoaderDataFormat.TEXT) {
                    // this._data = this.parseURLVariablesStr(data);
                    this._data = Utils.StringUtils.ObjectToQueryFormatString(data);
                } else {
                    this._data = data;
                }
                this._otherData = otherData;
                return this;
            }


            public clear() {
                this._baseUrl
                    = this._key
                    = this._reqHead
                    = this._method
                    = this._respFormat
                    = this._data
                    = this._otherData
                    = this._reqFormat
                    = null;
            }


            get key(): string {
                return this._key;
            }

            get method(): string {
                return this._method;
            }

            get reqHead(): Object {
                return this._reqHead;
            }

            get respFormat(): string {
                return this._respFormat;
            }

            get data(): any {
                return this._data;
            }

            set data(data: any) {
                this._data = data;
            }

            get otherData(): any {
                return this._otherData;
            }

            get reqFormat(): string {
                return this._reqFormat;
            }

            get baseUrl(): string {
                return this._baseUrl;
            }
        }
        class JsonpReq {
            private static _regID: number = 0;
            public static completeCall: any = {};

            public static process(url: string, callback: Function, callobj: any): void {
                JsonpReq.completeCall["call_" + JsonpReq._regID] = callback.bind(callobj);
                JsonpReq.startLoader(url, JsonpReq._regID++);
            }

            private static startLoader(url, id: number): void {
                let script = document.createElement('script');
                script.src = url + "JsonpReq.completeCall.call_" + id + "";
                document.body.appendChild(script);
            }

        }
    }
}