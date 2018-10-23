var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var App;
(function (App) {
    var GlobalCfg = (function () {
        function GlobalCfg(json) {
            this.sourceJson = json;
        }
        Object.defineProperty(GlobalCfg.prototype, "sourceJson", {
            set: function (json) {
                this._json = json;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "client_version", {
            get: function () {
                return this._json.client_version;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "isDebug", {
            get: function () {
                return this._json.isDebug;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "isCDN", {
            get: function () {
                return this._json.isCDN;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "resRoot", {
            get: function () {
                if (this.isCDN) {
                    return this._json.CDN_RESOURCE;
                }
                else {
                    return this._json.LOCAL_RESOURCE;
                }
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "pf", {
            get: function () {
                return this._json.pf;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "httpServer", {
            get: function () {
                return this._json.HttpServer;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "serverPort", {
            get: function () {
                return this._json.serverPort;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "videoAdUnitId", {
            get: function () {
                return this._json.videoAdUnitId;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(GlobalCfg.prototype, "bannerAdUnitId", {
            get: function () {
                return this._json.bannerAdUnitId;
            },
            enumerable: true,
            configurable: true
        });
        return GlobalCfg;
    }());
    App.GlobalCfg = GlobalCfg;
    __reflect(GlobalCfg.prototype, "App.GlobalCfg");
})(App || (App = {}));
//# sourceMappingURL=GlobalCfg.js.map