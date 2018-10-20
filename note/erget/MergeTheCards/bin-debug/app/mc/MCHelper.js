var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var MCHelper = (function () {
        function MCHelper() {
            this._mcCacheLength = 10;
            this.MC_DATA_COMMON_GROUP_NAME = "common";
            this._mcCache = [];
            this._mcFactoryCache = {};
            this._mcDataGroups = {};
            this._mcDataGroups[this.MC_DATA_COMMON_GROUP_NAME] = {};
        }
        /**
         * 从缓存中拿一个MC出来，没有就创建一个
         * @returns {egret.MovieClip}
         */
        MCHelper.prototype.createMc = function () {
            if (this._mcCache.length > 0) {
                return this._mcCache.pop();
            }
            return new egret.MovieClip();
        };
        /**
         * 将一个MC回收到缓存池
         * @param mc
         */
        MCHelper.prototype.restoreMc = function (mc) {
            mc.movieClipData = null;
            if (this._mcCache.length < this._mcCacheLength) {
                this._mcCache.push(mc);
            }
        };
        Object.defineProperty(MCHelper.prototype, "mcCacheLength", {
            get: function () {
                return this._mcCacheLength;
            },
            set: function (value) {
                this._mcCacheLength = value;
                if (this._mcCacheLength > value) {
                    this._mcCacheLength = value;
                }
            },
            enumerable: true,
            configurable: true
        });
        MCHelper.prototype.clearMcCache = function () {
            this._mcCache.length = 0;
        };
        /**
         * 从指定分组中获取指定的McData
         * 为毛要分组呢~~比如我只要删除某场景中特有的MC资源，而其他通用的MC资源还留着
         * @param fileName MC的文件名，json文件和png文件的名字要一致（当然后缀除外）
         * @param mcName 一套配置文件里可能有多个MC，你要指定MC名
         * @param groupName 组名，没有什么特殊的就用默认的吧
         * @returns {egret.MovieClipData}
         */
        MCHelper.prototype.getMcData = function (fileName, mcName, groupName) {
            if (groupName === void 0) { groupName = this.MC_DATA_COMMON_GROUP_NAME; }
            if (!groupName) {
                groupName = this.MC_DATA_COMMON_GROUP_NAME;
            }
            var mcDataKey = fileName + "_" + mcName;
            var group = this._mcDataGroups[groupName];
            var mcData = group ? group[mcDataKey] : null;
            if (!mcData) {
                var factory = this._mcFactoryCache[fileName];
                if (!factory) {
                    var jsonData = RES.getRes(fileName + "_json");
                    var pngData = RES.getRes(fileName + "_png");
                    factory = new egret.MovieClipDataFactory(jsonData, pngData);
                    this._mcFactoryCache[fileName] = factory;
                }
                mcData = factory.generateMovieClipData(mcName);
                if (!group) {
                    this._mcDataGroups[groupName] = {};
                }
                this._mcDataGroups[groupName][mcDataKey] = mcData;
            }
            return mcData;
        };
        /**
         * 清理McFactory缓存
         * @param fileNames 当isExept为false时，清理指定fileName关联的McFactory ，否则是清理掉所有除了指定fileName数组之外的缓存， 为null 则清空所有
         * @param isExept
         */
        MCHelper.prototype.clearMcFactoryCache = function (fileNames, isExept) {
            if (fileNames === void 0) { fileNames = null; }
            if (isExept === void 0) { isExept = false; }
            if (!fileNames) {
                this._mcFactoryCache = {};
            }
            else {
                var fileName = void 0;
                for (var i = 0, l = fileNames.length; i < l; i++) {
                    fileName = fileNames[i];
                    if (this._mcFactoryCache[fileName]) {
                        delete this._mcFactoryCache[fileName];
                    }
                }
            }
        };
        /**
         * 清理McData的缓存
         * @param groupNames 当isExept为false时，只清理指定组的缓存，否则是清理掉所有除了指定组缓存之外的缓存，若该值给null则清空所有
         * @param isExept
         */
        MCHelper.prototype.clearMcDataCache = function (groupNames, isExept) {
            if (groupNames === void 0) { groupNames = null; }
            if (isExept === void 0) { isExept = false; }
            if (!groupNames) {
                this._mcDataGroups = {};
            }
            else {
                var dataGroups = this._mcDataGroups;
                if (isExept) {
                    for (var groupName in dataGroups) {
                        if (groupNames.indexOf(groupName) < 0) {
                            delete dataGroups[groupName];
                        }
                    }
                }
                else {
                    var groupName = void 0;
                    for (var i = 0, l = groupNames.length; i < l; i++) {
                        groupName = groupNames[i];
                        if (dataGroups[groupName]) {
                            delete dataGroups[groupName];
                        }
                    }
                }
            }
        };
        MCHelper.prototype.clearAllCache = function () {
            this.clearMcCache();
            this.clearMcFactoryCache();
            this.clearMcDataCache();
        };
        return MCHelper;
    }());
    App.MCHelper = MCHelper;
    __reflect(MCHelper.prototype, "App.MCHelper");
})(App || (App = {}));
//# sourceMappingURL=MCHelper.js.map