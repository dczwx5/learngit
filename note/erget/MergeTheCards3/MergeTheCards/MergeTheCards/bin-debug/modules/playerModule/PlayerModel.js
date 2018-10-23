var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var PlayerModel = (function (_super) {
    __extends(PlayerModel, _super);
    function PlayerModel() {
        var _this = _super !== null && _super.apply(this, arguments) || this;
        _this._lv = 1;
        _this._highScore = 0;
        _this._skinMng = new SkinManager();
        return _this;
    }
    PlayerModel.prototype.saveBattleRecord = function (lv, score) {
        // return new Promise((resolve, reject) => {
        //
        //     resolve();
        // });
        var storageData = this.storageData;
        if (score && score > this.highScore) {
            this.highScore = score;
            storageData.highScore = score;
            // app.sdkProxy.setStorageData("highScore", this.highScore.toString());
        }
        if (lv > this.lv) {
            this.lv = lv;
            storageData.lv = lv;
            // app.sdkProxy.setStorageData("lv", this.lv.toString());
        }
        this.storageData = storageData;
        app.appHttp.submitBattleRecord(this.lv, this.highScore);
        this.sendMsg(create(WxSdkMsg.SetUserCloudStorage).init({
            KVDataList: [
                { key: "score_max", value: this.highScore.toString() }
            ],
            success: function () {
                app.log("==== SetUserCloudStorage ====  success ");
            },
            fail: function () {
                app.log("==== SetUserCloudStorage ====  fail ");
            }
        }));
    };
    Object.defineProperty(PlayerModel.prototype, "storageData", {
        get: function () {
            // let res:any = egret.localStorage.getItem("playerData");
            var res = egret.localStorage.getItem("playerData_" + this._uid);
            if (typeof res == 'string') {
                if (res.length == 0) {
                    res = { lv: 1, highScore: 0 };
                }
                else {
                    res = JSON.parse(res);
                }
            }
            if (!res) {
                res = this.storageData = { lv: 1, highScore: 0 };
            }
            return res;
        },
        set: function (data) {
            // app.sdkProxy.setStorageData("playerData", data);
            // egret.localStorage.setItem("playerData", JSON.stringify(data));
            egret.localStorage.setItem("playerData_" + this._uid, JSON.stringify(data));
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "lv", {
        get: function () {
            return this._lv;
        },
        set: function (value) {
            this._lv = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "highScore", {
        get: function () {
            return this._highScore;
        },
        set: function (value) {
            this._highScore = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "exp", {
        get: function () {
            return LvConfigHelper.getExpByLv(this.lv);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "skinId", {
        get: function () {
            // return this._skinId;
            return this._skinMng.skinId;
        },
        set: function (value) {
            // this._skinId = value;
            this._skinMng.skinId = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "skinMng", {
        get: function () {
            return this._skinMng;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(PlayerModel.prototype, "uid", {
        get: function () {
            return this._uid;
        },
        set: function (value) {
            this._uid = value;
            this._skinMng.uid = value;
        },
        enumerable: true,
        configurable: true
    });
    return PlayerModel;
}(VoyaMVC.Model));
__reflect(PlayerModel.prototype, "PlayerModel");
//# sourceMappingURL=PlayerModel.js.map