export interface IEventAssetsManager {
    getEventCode: () => number;
    getCURLECode?: () => number;
    getCURLMCode?: () => number;
    getMessage: () => string;                // 通常情况为"" 部分错误会返回对应msg 参考C++文件
    getAssetId?: () => string;               // ID=>清单文件中的资产路径
    isResuming?: () => boolean;              // 断点续传
    getPercent?: () => number;               // 文件数百分比
    getPercentByFile?: () => number;
    getDownloadedBytes?: () => number;
    getTotalBytes?: () => number;
    getDownloadedFiles?: () => number;
    getTotalFiles?: () => number;
}

/** 定义部分Manifest接口 */
export interface IManifest {
    isVersionLoaded: () => boolean;
    isLoaded: () => boolean;
    getPackageUrl: () => string;
    getManifestFileUrl: () => string;
    getVersionFileUrl: () => string;
    getVersion: () => string;
    getSearchPaths: () => string[];
}
export enum EManifestDownloadStatus {
    ERROR_NO_LOCAL_MANIFEST = 0,        // 本地没有manifest文件
    ERROR_DOWNLOAD_MANIFEST = 1,        // 下载manifest出错
    ERROR_PARSE_MANIFEST = 2,           // 解析manifest文件失败
    NEW_VERSION_FOUND = 3,              // 发现新版本
    ALREADY_UP_TO_DATE = 4,             // 已经是最新版
    UPDATE_PROGRESSION = 5,             // 正在下载
    ASSET_UPDATED = 6,                  // 下载一个资源成功
    ERROR_UPDATING = 7,                 // 解压失败和文件校验失败下载失败 常见错误:文件404
    UPDATE_FINISHED = 8,                // 下载更新完成
    UPDATE_FAILED = 9,                  // 下载更新失败
    ERROR_DECOMPRESS = 10,              // 解压失败 同时触发 code >>> ERROR_UPDATING

    UNINITED = 200,               // 未初始化
    UNCHECK = 201,                // 未检查状态
    CHECKING = 202,               // 正在检查更新
    UNINSTALL = 203,              // 未安装
    ALL_READY = 204,              // 已就绪
}
export class CJSB {
    static getWritablePath() {
        return (jsb.fileUtils ? jsb.fileUtils.getWritablePath() : '/');
    }
    static getSearchPaths() {
        return jsb.fileUtils.getSearchPaths();
    }
    static setSearchPaths(searchPaths) {
        jsb.fileUtils.setSearchPaths(searchPaths);
    }
    static removeDirectory(path) {
        jsb.fileUtils.removeDirectory(path);
    }
}

export class CAssetsManager { //extends jsb.AssetsManager {
    private _assetsManager:any;

    static EventCode = {
        ERROR_NO_LOCAL_MANIFEST:0,        // 本地没有manifest文件
        ERROR_DOWNLOAD_MANIFEST:1,        // 下载manifest出错
        ERROR_PARSE_MANIFEST:2,           // 解析manifest文件失败
        NEW_VERSION_FOUND:3,              // 发现新版本
        ALREADY_UP_TO_DATE:4,             // 已经是最新版
        UPDATE_PROGRESSION:5,             // 正在下载
        ASSET_UPDATED:6,                  // 下载一个资源成功
        ERROR_UPDATING:7,                 // 解压失败和文件校验失败下载失败 常见错误:文件404
        UPDATE_FINISHED:8,                // 下载更新完成
        UPDATE_FAILED:9,                  // 下载更新失败
        ERROR_DECOMPRESS:10,              // 解压失败 同时触发 code >>> ERROR_UPDATING
    }

    constructor(manifestUrl: string, storagePath: string, versionCompareHandle?:(localVersion: string, remotVersion: string) => number) {
        this._assetsManager = new jsb.AssetsManager(manifestUrl, storagePath, versionCompareHandle);
    }

    setVerifyCallback(callback:(path, asset)=>boolean) {
        this._assetsManager.setVerifyCallback(callback);
    }
    setEventCallback(callback:(e:IEventAssetsManager)=>void) {
        this._assetsManager.setEventCallback(callback);
    }
    // 设置并行数量，有些安卓机并行太大会有问题
    setMaxConcurrentTask(maxNum:number): void {
        this._assetsManager.setMaxConcurrentTask(maxNum);
    }
    // 检查更新
    checkUpdate(): void {
        this._assetsManager.checkUpdate();
    }
    // 更新
    update(): void {
        this._assetsManager.update();
    }
    // 下载之前失败的资源
    downloadFailedAssets(): void {
        this._assetsManager.downloadFailedAssets();
    }

    getState(): number {
        return this._assetsManager.getState();
    }
    // 是否未启动
    isUnInited() {
        return this.getState() === jsb.AssetsManager.State.UNINITED;
    }

    /**
     * 加载本地manifest文件
     * 注:内部会自动获取缓存目录 「storePath目录」 下的manifest进行比较以确定使用哪个manifest
     * 如果nativeUrl为本地动态获取的话，需要改c++ AssetsManager对应底层逻辑代码
     * @param nativeUrl manifest本地路径
     */
    loadLocalManifest(nativeUrl:string | any): void {
        let url = nativeUrl
        console.log('url =>', url);
        if (cc.loader.md5Pipe) {
            url = cc.loader.md5Pipe.transformURL(url);
        }
        console.log('md5 url =>', url);
        this._assetsManager.loadLocalManifest(url);
    }
    getLocalManifest(): IManifest {
        return this._assetsManager.getLocalManifest();
    }
    getLocalVersion(): string {
        if (this._assetsManager) {
            return this._assetsManager.getLocalManifest().getVersion();
        } else {
            return "0";
        }
    }
    isManifestReady() {
        let manifest = this.getLocalManifest();
        return manifest && manifest.isLoaded();
    }


    // 将每个子游戏都设成了一个searchpath, 使用searchpath有很多，增加了查找代价
    //  /**
    //  *  分包策略
    //  *  1.路径:jsb.fileUtils.getWritablePath() + "drdz/hotupdate/"+gameCode
    //  *  2.packageName策略: Main(主包) Game1(子包:场景名)
    //  * 根据包名添加一个搜索路径到小标0
    //  * 如果已经存在则位置提前到下标0
    //  * @param gameCode 包名
    //  */
    // public addSearchPath(gameCode: string): void {
        
    //     let pakcageUrl = CJSB.getWritablePath() + "drdz/hotupdate/" + gameCode;
    //     var searchPaths: string[] = CJSB.getSearchPaths();
    //     //数组去重
    //     let index = searchPaths.indexOf(pakcageUrl);
    //     if (index === 0) {
    //         return; //如果已经是第一位则什么也不做
    //     }
    //     if (index >= 1) {
    //         searchPaths.splice(index, 1);
    //     }
    //     searchPaths = [pakcageUrl].concat(searchPaths)
    //     // searchPaths.unshift(pakcageUrl);     //unshift() 方法无法在 Internet Explorer 中正确地工作！
    //     CJSB.setSearchPaths(searchPaths);
    //     cc.sys.localStorage.setItem('HotUpdateSearchPaths', JSON.stringify(searchPaths));
    // }

    /**
     * 字节数转大小(B KB MB GB...)
     * @param bytes 字节数
     */
    public bytesToSize(bytes: number): any {
        if (bytes === 0) return '0B';
        var k = 1024,
            sizes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));

        return (bytes / Math.pow(k, i)).toPrecision(2) + '' + sizes[i];
    }
}
