namespace App{
    export abstract class AppHttpBase {

        protected _loginTs_ms: number = 0;

        protected _serverTs_ms: number = 0;

        protected token: string;

        /**小游戏接口*/
        protected httpServerPort:string;

        protected httpServer: string;

        protected clientVersion: string;

        protected gameId:number;

        protected http: VL.Net.Http;

        protected respChecker: AppHttpRespChecker;

        constructor() {
            this.respChecker = new AppHttpRespChecker();
        }

        public init(http: VL.Net.Http, clientVersion: string, httpServer: string, serverPort: string, gameId:number = 1): AppHttpBase {
            this.http = http;
            this.httpServer = httpServer;
            this.httpServerPort = serverPort;
            this.clientVersion = clientVersion;
            this.gameId = gameId;
            return this;
        }

        protected set serverTimestamp(value: number) {
            this._loginTs_ms = egret.getTimer();
            this._serverTs_ms = value;
        }

        public get serverTs_s(): number {
            return this._serverTs_ms + Math.floor((egret.getTimer() - this._loginTs_ms) * 0.001);
        }

        protected createReqPack(data: any, otherData: any): VL.Net.HttpReqPack {
            data = this.ensurePackData(data);
            let headObj = {
                "Content-Type": "application/x-www-form-urlencoded"//这是键值对形式
                // "Content-Type": "multipart/form-data";//这是把数据合成一条
            };
            // return create(VL.Net.HttpReqPack).init(this.httpServer, this.httpServerPort, egret.HttpMethod.GET, data, otherData, headObj);
            return create(VL.Net.HttpReqPack).init(this.httpServer, this.httpServerPort, egret.HttpMethod.POST, data, otherData, headObj);
        }

        protected ensurePackData(data: any) {
            if (!data) {
                return;
            }
            if(this.token){
                data['token'] = this.token;
            }
            data['version'] = this.clientVersion;
            data['game_id'] = this.gameId;
            data['timestamp'] = this.serverTs_s;
            data['sig'] = new Utils.md5().hex_md5(this.token + this.serverTs_s);
            return data;
        }

        protected async sendHttp(data: any, onResp?: (data: any, otherData: any) => void, thisArg?: any, otherData?: any) {
            let onHttpResp = (packData: any, otherData: any) => {
                let data = JSON.parse(packData);
                if (onResp) {
                    if (this.respChecker.check(data).pass) {
                        onResp(data.data, otherData);
                    }
                }
            };
            return await this.http.send(this.createReqPack(data, otherData), onHttpResp, thisArg);
        }
    }
}