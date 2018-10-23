namespace App{
    export class MCHelper{
        private _mcCache:egret.MovieClip[];
        private _mcCacheLength:number = 10;

        private _mcFactoryCache:{[key:string]:egret.MovieClipDataFactory};

        private _mcDataGroups:{[groupName:string]:{[mcDataKey:string]:egret.MovieClipData}};

        private readonly MC_DATA_COMMON_GROUP_NAME:string = "common";

        constructor(){
            this._mcCache = [];
            this._mcFactoryCache = {};
            this._mcDataGroups = {};
            this._mcDataGroups[this.MC_DATA_COMMON_GROUP_NAME] = {};
        }

        /**
         * 从缓存中拿一个MC出来，没有就创建一个
         * @returns {egret.MovieClip}
         */
        public createMc():egret.MovieClip{
            if(this._mcCache.length > 0){
                return this._mcCache.pop();
            }
            return new egret.MovieClip();
        }

        /**
         * 将一个MC回收到缓存池
         * @param mc
         */
        public restoreMc(mc:egret.MovieClip){
            mc.movieClipData = null;
            if(this._mcCache.length < this._mcCacheLength){
                this._mcCache.push(mc);
            }
        }

        public get mcCacheLength(): number {
            return this._mcCacheLength;
        }

        public set mcCacheLength(value: number) {
            this._mcCacheLength = value;
            if(this._mcCacheLength > value){
                this._mcCacheLength = value;
            }
        }

        public clearMcCache(){
            this._mcCache.length = 0;
        }

        /**
         * 从指定分组中获取指定的McData
         * 为毛要分组呢~~比如我只要删除某场景中特有的MC资源，而其他通用的MC资源还留着
         * @param fileName MC的文件名，json文件和png文件的名字要一致（当然后缀除外）
         * @param mcName 一套配置文件里可能有多个MC，你要指定MC名
         * @param groupName 组名，没有什么特殊的就用默认的吧
         * @returns {egret.MovieClipData}
         */
        public getMcData(fileName:string, mcName:string, groupName:string = this.MC_DATA_COMMON_GROUP_NAME):egret.MovieClipData{
            if(!groupName){
                groupName = this.MC_DATA_COMMON_GROUP_NAME;
            }
            let mcDataKey = `${fileName}_${mcName}`;
            let group = this._mcDataGroups[groupName];
            let mcData = group ? group[mcDataKey] : null;
            if(!mcData){
                let factory = this._mcFactoryCache[fileName];
                if(!factory){
                    let jsonData = RES.getRes(`${fileName}_json`);
                    let pngData = RES.getRes(`${fileName}_png`);
                    factory = new egret.MovieClipDataFactory(jsonData, pngData);
                    this._mcFactoryCache[fileName] = factory;
                }
                mcData = factory.generateMovieClipData(mcName);
                if(!group){
                    this._mcDataGroups[groupName] = {};
                }
                this._mcDataGroups[groupName][mcDataKey] = mcData;
            }
            return mcData;
        }

        /**
         * 清理McFactory缓存
         * @param fileNames 当isExept为false时，清理指定fileName关联的McFactory ，否则是清理掉所有除了指定fileName数组之外的缓存， 为null 则清空所有
         * @param isExept
         */
        public clearMcFactoryCache(fileNames:string[] = null, isExept:boolean = false){
            if(!fileNames){
                this._mcFactoryCache = {};
            }
            else{
                let fileName:string;
                for(let i = 0, l = fileNames.length; i < l; i++){
                    fileName = fileNames[i];
                    if(this._mcFactoryCache[fileName]){
                        delete this._mcFactoryCache[fileName];
                    }
                }
            }
        }

        /**
         * 清理McData的缓存
         * @param groupNames 当isExept为false时，只清理指定组的缓存，否则是清理掉所有除了指定组缓存之外的缓存，若该值给null则清空所有
         * @param isExept
         */
        public clearMcDataCache(groupNames:string[] = null, isExept:boolean = false){
            if(!groupNames){
                this._mcDataGroups = {};
            }else{
                let dataGroups = this._mcDataGroups;
                if(isExept){
                    for(let groupName in dataGroups){
                        if(groupNames.indexOf(groupName) < 0){
                            delete dataGroups[groupName];
                        }
                    }
                }else {
                    let groupName:string;
                    for(let i = 0, l = groupNames.length; i < l; i++){
                        groupName = groupNames[i];
                        if(dataGroups[groupName]){
                            delete dataGroups[groupName];
                        }
                    }
                }
            }
        }

        public clearAllCache(){
            this.clearMcCache();
            this.clearMcFactoryCache();
            this.clearMcDataCache();
        }
    }
}