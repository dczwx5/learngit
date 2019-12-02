import { CJSB, CAssetsManager, IEventAssetsManager, EManifestDownloadStatus } from "./CJSB";
const {ccclass, property} = cc._decorator;

/**
 * 注意
 *   如果发了新包。需要删除缓存。不然会导致热更模块出问题，暂时发现的是。底层在处理时，数据混乱了。
 *   测试过程。操作流程很重要，如果热更失败，先从操作流程入手
 *      版本完成->打原生包->跑version_gerxxxx脚本->生成manifest文件->重打再打原生包->覆盖main.js
 * 
 */
@ccclass
export default class CHotUpdate extends cc.Component {
    @property(cc.Asset)  
    manifest:cc.Asset = null;
     
    @property(cc.String)
    folderName:string = "";

    static HotUpdateSearchPaths = 'HotUpdateSearchPaths';
    static lastWritablePath = 'lastWritablePath';

    onDestroy() {
        this.stop();
    }    
    
    onLoad () {
        if (!cc.sys.isNative) {
            return ;  
        } 
        this._traceStartInfo();

        this._check_process = new CCheckUpdateEventProcess();  
        this._update_process = new CHotUpdateEventProcess();  

        let saveFolderName = this.folderName;
        if (!saveFolderName) {
            saveFolderName = 'temp';
        }
        this._storagePath = CJSB.getWritablePath() + saveFolderName;
        let lastWritablePath = cc.sys.localStorage.getItem(CHotUpdate.lastWritablePath);
        if (lastWritablePath && lastWritablePath.length > 0) {
            if (lastWritablePath != this._storagePath) {
                console.log('app目录不一致，可能是重新安装了新包，需要清除之前的数据');
                this.clearVersionStorage();
            }
        }

        // Init with empty manifest url for testing custom manifest
        let url = this.manifest.nativeUrl;
        if (!url) {
            url = this.manifest.toString();
        }
        this._am = new CAssetsManager(url, this._storagePath, this._versionCompareHandle);
        this._am.setVerifyCallback(this._onVerifyHandle.bind(this));

        if (cc.sys.os === cc.sys.OS_ANDROID) {
            // Some Android device may slow down the download process when concurrent tasks is too much.
            // The value may not be accurate, please do more test and find what's most suitable for your game.
            this._am.setMaxConcurrentTask(2);
        }
        this._am.setEventCallback(this._onUpdateEvent.bind(this));
        this._traceLocalManifestInfo();
    }
    
    private _onUpdateEvent(event:IEventAssetsManager) {
        if (this._isProcessCheck) {
            this._processCheckEvent(event);
        } else if (this._isProcessUpdate) {
            this._processUpdateEvent(event);
        }
    }
    private _processCheckEvent(event:IEventAssetsManager) {
        let processData:CUpdateData = this._check_process.proccess(event);
        console.log("检查更新事件响应 : processData 数据 : " + JSON.stringify(processData));

        if (processData.success) {
            if (processData.finish) {
                if (processData.hasNew) {
                    console.log('检测到新版本');
                } else {
                    console.log('已经是最新版本');
                }
                this._callCheckUpdatHandler(processData.success, processData.hasNew, processData.msg);
                this._endCheckUpdate();
            }
        } else {
            console.log('新版本检测失败');
            this._callCheckUpdatHandler(processData.success, processData.hasNew, processData.msg);
            this._endCheckUpdate();
        }
    }
    private _processUpdateEvent(event:IEventAssetsManager) {
        let processData:CUpdateData = this._update_process.proccess(event);
        // 更新中
        console.log("更新事件响应 : processData 数据 : " + JSON.stringify(processData));
        if (processData.isProcess) {
            this._traceDownloadingProcess(event);
            this._callProccessHandler(event);
        } else {
            if (processData.success) {
                if (processData.finish) {
                    console.log("更新完成 : ");
                    this._callHotUpdatHandler(processData.success, processData.msg)
                    this._save();
                    this._endUpdate();
                } else {
                    console.log("更新ing : ");
                }
            } else {
                console.log("更新失败 : ");
                this._callHotUpdatHandler(processData.success, processData.msg)
                this._endUpdate();
            }
        }
    }
    private _endCheckUpdate() {
        this._isUpdating= false;
        this._isProcessCheck = false;
    }
    private _endUpdate() {
        this._isUpdating= false;
        this._isProcessUpdate = false;
    }
    private _save() {
        console.log('保存更新');
        this._traceLocalManifestInfo();


        // 更新完毕
        var searchPaths:Array<any> = CJSB.getSearchPaths();        
        
        // 生成新的搜索路径列表
        var newPaths = this._am.getLocalManifest().getSearchPaths();
        let tempFullList = newPaths.concat(searchPaths);
        let tempNewList = [];
        for (let i:number = 0; i < tempFullList.length; i++) {
            let item = tempFullList[i];
            if (-1 == tempNewList.indexOf(item)) {
                tempNewList.push(item);
            }
        }

        // 设置搜索路径
        let newSearchpathStr = JSON.stringify(tempNewList);
        cc.sys.localStorage.setItem(CHotUpdate.HotUpdateSearchPaths, newSearchpathStr);
        cc.sys.localStorage.setItem(CHotUpdate.lastWritablePath, this._storagePath);
        CJSB.setSearchPaths(tempNewList);
        console.log('设置搜索路径 : ' + newSearchpathStr);
    }
     
    private _callCheckUpdatHandler(sucess:boolean, hasNew:boolean, msg:string) {
        if (this.checkUpdateHandler) {
            this.checkUpdateHandler(sucess, hasNew, msg);
        }
    }
    private _callHotUpdatHandler(sucess:boolean, msg:string) {
        if (this.hotUpdateHandler) {
            this.hotUpdateHandler(sucess, msg);
        }
    }
    private _callProccessHandler(event:IEventAssetsManager) {
        if (this.processHandler) {
            this.processHandler(event.getPercent(), event.getDownloadedBytes(), event.getTotalBytes(), 
            event.getPercentByFile(), event.getDownloadedFiles(), event.getTotalFiles());
        }
    }

    // =========================检查更新
    update() {
        if (!this._isUpdating) {
            if (this._quireToCheckUpdate) {
                this.checkUpdate();
            } else if (this._quireToUpdate) {
                this.hotUpdate();
            }
        }
    }
    checkUpdate() {
        if (this._isUpdating) {
            if (this._isProcessUpdate) {
                this._quireToCheckUpdate = true;
            }
            return ;
        }
        if (this._am.isUnInited()) {
            this._quireToCheckUpdate = true;
            return ;
        }
        if (!this._am.isManifestReady()) {
            this._quireToCheckUpdate = true;
            return ;
        }

        this._quireToCheckUpdate = false;
        this._isUpdating = true;
        this._isProcessCheck = true;
        this._am.checkUpdate();
    }
    // =========================更新
    hotUpdate() {
        if (this._isUpdating) {
            if (this._isProcessCheck) {
                this._quireToUpdate = true;
            } else if (this._isProcessUpdate) {
                // 已经在更新，操作丢弃
            }
            return ;
        }

        if (this._am.isUnInited()) {
            this._quireToUpdate = true;
            return ;
        }
        if (!this._am.isManifestReady()) {
            this._quireToUpdate = true;
            return ;
        }
        this._quireToUpdate = false;
        this._isUpdating = true;
        this._isProcessUpdate = true;
        this._am.update();
    }   
    
    clearVersionStorage() {
        cc.sys.localStorage.removeItem(CHotUpdate.HotUpdateSearchPaths);
        cc.sys.localStorage.removeItem(CHotUpdate.lastWritablePath);
        CJSB.removeDirectory(this._storagePath);
        CJSB.setSearchPaths([]);
    }

    private _traceStartInfo() {
        var searchPaths:string = '';
        if (localStorage.getItem(CHotUpdate.HotUpdateSearchPaths)) {
            searchPaths = localStorage.getItem(CHotUpdate.HotUpdateSearchPaths); 
        }
        console.log("本地缓存 HotUpdateSearchPaths 数据 :", searchPaths);

        var fileutilsearchpath = '';
        let fileutilsearpathlist = CJSB.getSearchPaths();
        if (fileutilsearpathlist && fileutilsearpathlist.length > 0) {
            fileutilsearchpath = JSON.stringify(fileutilsearpathlist); 
        }
        console.log("当前查找目录 : ", fileutilsearchpath);

    }
    private _traceLocalManifestInfo() {
        let localManifest = this._am.getLocalManifest();
        if (localManifest) {
            console.log('localManifest数据 :');
            var localManifestpath = localManifest.getSearchPaths();
            console.log('\t搜索路径 : ', JSON.stringify(localManifestpath));
            console.log('\t包路径 ' + (localManifest.getPackageUrl()));
            console.log('\tmanifest路径 ' + (localManifest.getManifestFileUrl()));
            console.log('\tversion路径 ' + (localManifest.getVersionFileUrl()));
            console.log('\t版本号 : ' + localManifest.getVersion());
        }
    }
    private _traceDownloadingProcess(event:IEventAssetsManager) {
        console.log("字节百分比 ", event.getPercent(), " 下载字节 ", event.getDownloadedBytes(), " 总字节 : ", event.getTotalBytes(), 
        " 文件百分比", event.getPercentByFile(), " 文件下载 ", event.getDownloadedFiles(), " 总文件 ", event.getTotalFiles(), 
        " message", event.getMessage(), " code ", event.getEventCode());
    }

    stop() {
        if (this._am) {
            this._am.setEventCallback(null);
            this._am.setEventCallback(null);
            this._am = null;
        }
    }
     // 版本比例函数
     private _versionCompareHandle(versionA, versionB) {
        console.log("版本比较: 本地版本 " + versionA + ', 服务器版本 is ' + versionB);
        var vA = versionA.split('.');
        var vB = versionB.split('.');
        for (var i = 0; i < vA.length; ++i) {
            var a = parseInt(vA[i]);
            var b = parseInt(vB[i] || 0);
            if (a === b) {
                continue;
            }
            else {
                return a - b;
            }
        }
        if (vB.length > vA.length) {
            return -1;
        }
        else {
            return 0;
        }
    }
    // 验证成功回调
    private _onVerifyHandle(path, asset) {
        // When asset is compressed, we don't need to check its md5, because zip file have been deleted.
        var compressed = asset.compressed;
        // Retrieve the correct md5 value.
        var expectedMD5 = asset.md5;
        // asset.path is relative path and path is absolute.
        var relativePath = asset.path;
        // The size of asset file, but this value could be absent.
        var size = asset.size;
        console.log('======> verify sucess');
        return true;
    }

    private _storagePath:string;
    private _am:CAssetsManager;
    private _isUpdating:boolean;

    private _quireToUpdate:boolean;
    private _quireToCheckUpdate:boolean;
    
    private _isProcessCheck:boolean; // 检测更新
    private _isProcessUpdate:boolean; // 更新

    checkUpdateHandler:(sucess:boolean, hasNew, msg:string)=>void;
    hotUpdateHandler:(sucess:boolean, msg:string)=>void;
    processHandler:(byteProgress:number, loadedByte:number, totalByte:number, fileProgress:number, downloadedFiles:number, totalFiles:number)=>void;

    private _check_process:CCheckUpdateEventProcess;
    private _update_process:CHotUpdateEventProcess;
}

class CUpdateData {
    success:boolean;
    msg:string;
    hasNew:boolean; // 有新更新
    finish:boolean; // 更新完成
    isProcess:boolean; // 是否proccess
    code:any;
}
class CCheckUpdateEventProcess {
    proccess(event:IEventAssetsManager) : CUpdateData {
        let ret = new CUpdateData();
        let code = event.getEventCode();
        let msg = event.getMessage();
        let success = false;
        let hasNew = false;
        let finish = false;
        ret.code = code;

        switch (code) {
            case EManifestDownloadStatus.ERROR_NO_LOCAL_MANIFEST:
                cc.error('找不到本地Manifest文件');                
                success = hasNew = false;
                break;
            case EManifestDownloadStatus.ERROR_DOWNLOAD_MANIFEST:
                cc.error('下载服务器Manifest失败，请检查服务器.');
                success = hasNew = false;
                break;   
            case EManifestDownloadStatus.ERROR_PARSE_MANIFEST:
                cc.error('服务器Manifest文件解析失败，请检查服务器.');
                success = hasNew = false;
                break;  
            case EManifestDownloadStatus.ALREADY_UP_TO_DATE:
                cc.error('已经是最新版本');
                success = true;
                hasNew = false;
                finish = true;
                break;
            case EManifestDownloadStatus.NEW_VERSION_FOUND:
                console.log('检测到新版本');
                success = true;
                hasNew = true;
                finish = true;
                break;
            case EManifestDownloadStatus.UPDATE_FINISHED:
            case EManifestDownloadStatus.UPDATE_PROGRESSION:
                // 不影响
                console.log('下载资源.', code);
                finish = false;
                success = true;

                break;
            default:
                console.log('未处理消息 code ' + code)
                success = hasNew = false;
                break;
        }

        ret.finish = finish;
        ret.hasNew = hasNew;
        ret.success = success;
        ret.msg = msg;

        return ret;
    }
}
class CHotUpdateEventProcess {
    proccess(event:IEventAssetsManager) : CUpdateData {
        let ret = new CUpdateData();
        let code = event.getEventCode();
        let msg = event.getMessage();
        let success = false;
        let finish = false;
        let isProcess = false;

        if (code == EManifestDownloadStatus.UPDATE_PROGRESSION || EManifestDownloadStatus.ASSET_UPDATED == code) {
            isProcess = true;
            success = true;
        } else {
            switch (code) {
                case EManifestDownloadStatus.ERROR_NO_LOCAL_MANIFEST:
                    cc.error('找不到本地Manifest文件');                
                    break;
                case EManifestDownloadStatus.ERROR_DOWNLOAD_MANIFEST:
                    cc.error('下载服务器Manifest失败，请检查服务器.');
                    break;   
                case EManifestDownloadStatus.ERROR_PARSE_MANIFEST:
                    cc.error('服务器Manifest文件解析失败，请检查服务器.');
                    break;            
                case EManifestDownloadStatus.ALREADY_UP_TO_DATE:
                    cc.error('已经是最新版本');
                    break;
                case EManifestDownloadStatus.UPDATE_FINISHED:
                    console.log('更新成功. ');
                    success = true;
                    finish = true;
                    break;
                case EManifestDownloadStatus.UPDATE_FAILED:
                    cc.error('更新失败');
                    break;
                case EManifestDownloadStatus.ERROR_UPDATING:
                    cc.error('资源更新失败: ' + event.getAssetId() + ', ' + event.getMessage());
                    break;
                case EManifestDownloadStatus.ERROR_DECOMPRESS:
                    console.log('解压失败');
                    break;
                case EManifestDownloadStatus.NEW_VERSION_FOUND:
                    console.log('检测到新版本');
                    success = true;
                    break;
                default:
                    console.log('未处理消息 code ' + code)
                    break;
            }
        }
        ret.code = code;
        ret.msg = msg;
        ret.success = success;
        ret.finish = finish;
        ret.isProcess = isProcess;
        return ret;
    }
}