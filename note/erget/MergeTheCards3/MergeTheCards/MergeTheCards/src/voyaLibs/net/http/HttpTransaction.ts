namespace VL {
    export namespace Net {
        export class HttpTransaction extends VL.ObjectCache.CacheableClass {

            private _httpReq: egret.HttpRequest;

            private _reqPack: HttpReqPack;

            private _isRequesting: boolean = false;

            private _onResult: (respPack: HttpRespPack, otherData: any) => void;

            constructor() {
                super();
                this._httpReq = new egret.HttpRequest();
            }

            public init(httpReqPack: HttpReqPack, onResult: (respPack: HttpRespPack, otherData: any) => void): HttpTransaction {
                this._reqPack = httpReqPack;
                this._onResult = onResult;

                return this;
            }

            public async send(): Promise<HttpRespPack> {
                return new Promise<HttpRespPack>((resolve, reject) => {
                    if (this._isRequesting) {
                        app.log("============= 请求未返回，勿重复发送请求 ======================");
                        resolve(null);
                    }

                    let httpReq = this._httpReq;
                    let reqPack = this._reqPack;
                    let serverUrl = reqPack.baseUrl;
                    let sendData: any;

                    if (reqPack.method == egret.HttpMethod.POST && reqPack.data) {
                        httpReq.open(serverUrl + reqPack.key, reqPack.method);
                        sendData = reqPack.data;
                    } else {
                        httpReq.open(serverUrl + reqPack.key + "?" + reqPack.data, reqPack.method);
                    }
                    let header = reqPack.reqHead;
                    for (let key in header) {
                        httpReq.setRequestHeader(key, header[key]);
                        header[key] = header[key];
                    }
                    httpReq.responseType = reqPack.respFormat;


                    this._isRequesting = true;

                    const onLoaderComplete = function(event: egret.Event): void {
                        httpReq.removeEventListener(egret.Event.COMPLETE, onLoaderComplete, this);
                        httpReq.removeEventListener(egret.IOErrorEvent.IO_ERROR, onError, this);

                        this._isRequesting = false;
                        let respPack = create(HttpRespPack).init(true, httpReq.getAllResponseHeaders(), httpReq.response);
                        this._onResult(respPack, reqPack.otherData);
                        resolve(respPack);//因为这句，所以把方法放在函数里面
                        this.restore();
                    };

                    const onError = function(e: egret.IOErrorEvent): void {
                        httpReq.removeEventListener(egret.Event.COMPLETE, onLoaderComplete, this);
                        httpReq.removeEventListener(egret.IOErrorEvent.IO_ERROR, onError, this);
                        this._isRequesting = false;
                        let respPack = create(HttpRespPack).init(false, httpReq.getAllResponseHeaders(), httpReq.response);
                        this._onResult(respPack, reqPack.otherData);
                        resolve(respPack);//因为这句，所以把方法放在函数里面
                        this.restore();
                    };

                    httpReq.addEventListener(egret.Event.COMPLETE, onLoaderComplete, this);
                    httpReq.addEventListener(egret.IOErrorEvent.IO_ERROR, onError, this);
                    httpReq.send(sendData);
                });
            }

            public clear() {
                this._reqPack =
                    this._onResult = null;
            }
        }
    }
}