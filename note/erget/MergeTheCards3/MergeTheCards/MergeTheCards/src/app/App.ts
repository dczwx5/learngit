namespace App {

    export class App{
        private logger: Logger;

        public reflector:VL.Reflector.IReflector;
        public globalConfig: GlobalCfg;
        public config: Config;
        public resManager : VL.Resource.EgretResManager;
        public mcHelper:MCHelper;
        public easyLoadingManager: EasyLoadingManager;
        public soundManager: VL.Sound.SoundMgr;
        private _http:VL.Net.Http;
        public appHttp:AppHttp;
        public dragDropManager:VL.DragDrop.DragDropManager;

        // private _localTimestamp:number;
        // private _serverTimestamp:number;
        //
        // public  set serverTimestamp(value:number){
        //     app._localTimestamp = egret.getTimer();
        //     app._serverTimestamp = value;
        // }
        //
        // public  get serverTimestamp():number{
        //     let timestamp:number = app._serverTimestamp+Math.floor((egret.getTimer() - app._localTimestamp) * 0.001);
        //     return timestamp;
        // }

        public async init(){
            this.reflector = new VL.Reflector.EgretReflector();
            let globalConfig = this.globalConfig = new GlobalCfg(await this.loadGlobalJson());
            this.logger = new Logger();
            if(globalConfig.isDebug){
                this.logger.init();
            }
            console.log(`====================== check info =======================`);
            console.log(`client_version:${globalConfig.client_version}`);
            console.log(`pf:${globalConfig.pf}`);
            console.log(`httpServer:${globalConfig.httpServer}`);
            console.log(`serverPort:${globalConfig.serverPort}`);
            console.log(`isDebug:${globalConfig.isDebug}`);
            console.log(`=========================================================`);

            this.resManager = new VL.Resource.EgretResManager();
            this.config = new Config();
            this.mcHelper = new MCHelper();
            this.easyLoadingManager = new EasyLoadingManager();
            this.soundManager = new VL.Sound.SoundMgr(VL.Sound.EgretSound) as VL.Sound.SoundMgr;
            this.dragDropManager = new VL.DragDrop.DragDropManager();
            this._http = new VL.Net.Http();
            this.appHttp = new AppHttp().init(this._http, globalConfig.client_version, globalConfig.httpServer, globalConfig.serverPort);
        }

        private async loadGlobalJson(): Promise<IGlobalJson> {
            return new Promise<IGlobalJson>((resolve, reject) => {
                let urlReq = new egret.URLRequest("resource/config/global.json");
                let loader = new egret.URLLoader(urlReq);
                loader.dataFormat = egret.URLLoaderDataFormat.TEXT;
                loader.once(egret.Event.COMPLETE, function (e: egret.Event) {
                    let json = JSON.parse(loader.data);
                    resolve(json);
                }, this);
                loader.once(egret.IOErrorEvent.IO_ERROR, function(e: egret.IOErrorEvent){
                    reject(e.data);
                }, this);
            });
        }

        public getConfig<T extends { attrs(): string[] }>(ref: new () => T): { [id: string]: T } {
            return this.config.getConfig(ref);
        }

        /**
         * 输出一个日志信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        public log(message?: any, ...optionalParams: any[]) {
            this.logger.log(message, ...optionalParams);
        }

        /**
         * 输出一个警告信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        public warn(message?: any, ...optionalParams: any[]) {
            this.logger.warn(message, ...optionalParams);
        }

        /**
         * 输出一个错误信息到控制台。
         * @param message 要输出到控制台的信息
         * @param optionalParams 要输出到控制台的额外信息
         * @language zh_CN
         */
        public error(message?: any, ...optionalParams: any[]) {
            this.logger.error(message, ...optionalParams);
        }

    }
}
const app = new App.App();

