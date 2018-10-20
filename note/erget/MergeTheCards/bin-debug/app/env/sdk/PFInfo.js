/**
 * Created by MuZi on 2018/4/16.
 * SDK渠道参数信息
 */
var PFInfo = (function () {
    function PFInfo() {
    }
    Object.defineProperty(PFInfo.prototype, "appId", {
        get: function () {
            return this._appid;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "appKey", {
        get: function () {
            return this._appkey;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "openId", {
        get: function () {
            return this._openid;
        },
        set: function (openid) {
            this._openid = openid;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "openKey", {
        get: function () {
            return this._openkey;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "openkey", {
        set: function (key) {
            this._openkey = key;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "token", {
        get: function () {
            return this._token;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "serverUrl", {
        get: function () {
            return "";
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "pf", {
        get: function () {
            return this._pf;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "platform", {
        get: function () {
            return this._platform;
        },
        set: function (os) {
            this._platform = os;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PFInfo.prototype, "shareUID", {
        get: function () {
            return this._shareUID;
        },
        enumerable: true,
        configurable: true
    });
    return PFInfo;
}());
