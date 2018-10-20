namespace VL {
    export namespace Net {
        export class HttpRespPack extends VL.ObjectCache.CacheableClass {
            /**
             * http返回的状态码，如200,400,500
             */
            // protected _status:number;

            /** 是否成功 */
            protected _isSuccess: boolean;

            protected _header: string;

            protected _data: any;

            public init(isSuccess: boolean, header: string, data: any): HttpRespPack {
                this._isSuccess = isSuccess;
                this._header = header;
                this._data = data;
                return this;
            }

            public clear() {
                this._isSuccess = null;
                this._header = null;
                this._data = null;
            }

            /**
             * 是否成功
             * @returns {boolean}
             */
            get isSuccess(): boolean {
                return this._isSuccess;
            }

            public get data(): any {
                return this._data;
            }

            // public get code():number {
            //     return this._code;
            // }

            public get header(): string {
                return this._header;
            }
        }
    }
}