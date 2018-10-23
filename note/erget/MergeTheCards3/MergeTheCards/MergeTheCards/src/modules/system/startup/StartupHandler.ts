class StartupController extends VoyaMVC.Controller{

    activate() {
        this.regMsg(StartupMsg.Startup, this.onStartup, this);
    }

    deactivate() {
        this.unregMsg(StartupMsg.Startup, this.onStartup, this);
    }

    public async onStartup(msg:StartupMsg.Startup) {
        // app.init(await this.loadGlobalJson());
        this.sendMsg(create(SystemMsg.EnterScene).init({scene:MainScene}));
        await this.loadCfg();
        this.regMsg(LoadMsg.OnTaskComplete, this.onLoadResComplete, this);
        this.sendMsg(create(LoadMsg.OpenLoadingView).init({taskName:"preload", closeAfterComplete:false}));
        this.sendMsg(create(LoadMsg.LoadRes).init({sources:['preload'], taskName:"preload"}));
    }

    // public async loadGlobalJson(): Promise<App.IGlobalJson> {
    //     return new Promise<App.IGlobalJson>((resolve, reject) => {
    //         let urlReq = new egret.URLRequest("resource/config/global.json");
    //         let loader = new egret.URLLoader(urlReq);
    //         loader.dataFormat = egret.URLLoaderDataFormat.TEXT;
    //         loader.once(egret.Event.COMPLETE, function (e: egret.Event) {
    //             let json = JSON.parse(loader.data);
    //             resolve(json);
    //         }, this);
    //         loader.once(egret.IOErrorEvent.IO_ERROR, function(e: egret.IOErrorEvent){
    //             reject(e.data);
    //         }, this);
    //     });
    // }

    private async loadCfg() {
        try {
            let resRoot = app.globalConfig.resRoot;
            await RES.loadConfig(resRoot + "default.res.json", resRoot);
            await this.loadTheme();
            await app.config.init();
        }
        catch (e) {
            console.error(e);
        }
    }

    private async loadTheme() {
        return new Promise((resolve, reject) => {
            // load skin theme configuration file, you can manually modify the file. And replace the default skin.
            //加载皮肤主题配置文件,可以手动修改这个文件。替换默认皮肤。
            let theme = new eui.Theme("resource/default.thm.json", StageUtils.getStage());
            theme.addEventListener(eui.UIEvent.COMPLETE, () => {
                resolve();
            }, this);

        })
    }

    private onLoadResComplete(msg:LoadMsg.OnTaskComplete){
        if(msg.body.taskName == 'preload'){
            this.unregMsg(LoadMsg.OnTaskComplete, this.onLoadResComplete, this);
            this.sendMsg(create(LoadMsg.CloseLoadingView));

            // this.sendMsg(create(TestModuleMsg.OpenTestView));
            // this.sendMsg(create(TestModuleMsg.SetTfContent).init({num:1, str:'hello world~!'}));
            // this.sendMsg(create(TestModuleMsg.SetTfVisible).init({visible:true}));

            this.sendMsg(create(SDKMsg.InitSdk).init({pf:app.globalConfig.pf}));
            this.sendMsg(create(SDKMsg.Login));
            this.sendMsg(create(MainModuleMsg.OpenMainView));
        }
    }

}