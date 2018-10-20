namespace App{
    export class GlobalCfg {
        private _json:IGlobalJson;

        constructor(json:IGlobalJson){
            this.sourceJson = json;
        }

        public set sourceJson(json:IGlobalJson){
            this._json = json;
        }

        public get client_version(): string{
            return this._json.client_version;
        }
        public get isDebug(): boolean{
            return this._json.isDebug;
        }
        public get isCDN(): boolean{
            return this._json.isCDN;
        }
        public get resRoot():string{
            if (this.isCDN){
                 return this._json.CDN_RESOURCE;
            }else{
                return this._json.LOCAL_RESOURCE;
            }
        }
        public get pf():string{
            return this._json.pf;
        }

        public get httpServer():string{
            return this._json.HttpServer
        }

        public get serverPort():string{
            return this._json.serverPort
        }

        public get videoAdUnitId():string{
            return this._json.videoAdUnitId;
        }
        public get bannerAdUnitId():string{
            return this._json.bannerAdUnitId;
        }

    }
}