namespace VL {
    export namespace Net {
        export class Http {

            protected readonly reqHeader: any = null;

            /**
             * 这个是HTTP实现层的错误，网络异常之类的
             */
            public readonly dg_HttpError: VL.Delegate<{ key: string, data: any, otherData: any }>;

            constructor(){
                this.dg_HttpError = new VL.Delegate<{ key: string, data: any, otherData: any }>();
            }
            /**
             *
             * @param key
             * @param data
             * @param onResp
             * @param thisObj
             * @param otherData
             */
            // public send(key: string, data: any, onResp: (respData: any, otherData?: any) => void, thisObj: any, otherData: any = null) {
            //     let reqPack = this.createReqPack(key, data, otherData);
            //     create(HttpTransaction).init(reqPack, (respPack: HttpRespPack, otherData: any) => {
            //         this.onResult(respPack, onResp.bind(thisObj), reqPack);
            //     }).send();
            // }

            public async send(httpReqPack: HttpReqPack, onResp: (respData: any, otherData?: any) => void, thisObj: any) {
                return await create(HttpTransaction).init(httpReqPack, (respPack: HttpRespPack, otherData: any) => {
                    this.onResult(respPack, onResp.bind(thisObj), httpReqPack);
                }).send();
            }

            // protected abstract onResult(respPack: HttpRespPack, respHandler: (respData: any, otherData?: any) => void, reqPack: HttpReqPack): void;
            protected onResult(respPack: HttpRespPack, respHandler: (respData: any, otherData?: any) => void, reqPack: HttpReqPack): void{
                if (respPack.isSuccess) {
                    this.onSuccess(respPack, respHandler, reqPack);
                } else {
                    this.onFail(respPack, respHandler, reqPack);
                }
                respPack.restore();
            }

            private onSuccess(respPack: VL.Net.HttpRespPack, respHandler: (respData: any, otherData?: any) => void, reqPack: VL.Net.HttpReqPack) {
                respHandler(respPack.data, reqPack.otherData);
                reqPack.restore();
            }

            private onFail(respPack: VL.Net.HttpRespPack, respHandler: (respData: any, otherData?: any) => void, reqPack: VL.Net.HttpReqPack) {
                this.dg_HttpError.boardcast({key: reqPack.key, data: respPack.data, otherData: reqPack.otherData});
            }
        }
    }
}