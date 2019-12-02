window.__require = function e(t, s, a) {
function o(i, r) {
if (!s[i]) {
if (!t[i]) {
var c = i.split("/");
c = c[c.length - 1];
if (!t[c]) {
var l = "function" == typeof __require && __require;
if (!r && l) return l(c, !0);
if (n) return n(c, !0);
throw new Error("Cannot find module '" + i + "'");
}
}
var p = s[i] = {
exports: {}
};
t[i][0].call(p.exports, function(e) {
return o(t[i][1][e] || e);
}, p, p.exports, e, t, s, a);
}
return s[i].exports;
}
for (var n = "function" == typeof __require && __require, i = 0; i < a.length; i++) o(a[i]);
return o;
}({
CHotUpdate: [ function(e, t, s) {
"use strict";
cc._RF.push(t, "071e8RIRwVKVrwEgi3h53SX", "CHotUpdate");
Object.defineProperty(s, "__esModule", {
value: !0
});
var a = e("./CJSB"), o = cc._decorator, n = o.ccclass, i = o.property, r = function(e) {
__extends(t, e);
function t() {
var t = null !== e && e.apply(this, arguments) || this;
t.manifest = null;
t.lbl = null;
return t;
}
t.prototype.onDestroy = function() {
this._am && this._am.setEventCallback(null);
};
t.prototype.onLoad = function() {
if (cc.sys.isNative) {
this._check_process = new l();
this._update_process = new p();
var e = JSON.parse(localStorage.getItem("HotUpdateSearchPaths"));
console.log("=======> CHotUpdate.onLoad -> searchPaths : " + JSON.stringify(e));
var t = jsb.fileUtils.getSearchPaths();
if (t && t.length > 0) {
var s = JSON.stringify(t);
console.log("=======> CHotUpdate.onLoad -> fileutilsearchpath : " + s);
} else console.log("=======> CHotUpdate.onLoad -> fileutilsearchpath : []");
this._storagePath = a.CJSB.getWritablePath() + "test-remote-assset";
console.log('("=======> CHotUpdate.onLoad ->  _storagePath : ', this._storagePath);
this.lbl.string = this._storagePath;
var o = this.manifest.nativeUrl;
o || (o = this.manifest.toString());
console.log("=======> CHotUpdate.onLoad -> manifest.nativeUrl : " + o);
this._am = new a.CAssetsManager(o, this._storagePath, this._versionCompareHandle);
this._am.setVerifyCallback(this._onVerifyHandle.bind(this));
if (this._am.getLocalManifest()) {
console.log('("=======> CHotUpdate.onLoad ->  this._am.getLocalManifest() : ', JSON.stringify(this._am.getLocalManifest()));
var n = this._am.getLocalManifest().getSearchPaths();
console.log('("=======> CHotUpdate.onLoad ->  localManifestpath : ', JSON.stringify(n));
}
cc.sys.os === cc.sys.OS_ANDROID && this._am.setMaxConcurrentTask(2);
this._am.setEventCallback(this._onUpdateEvent.bind(this));
}
};
t.prototype._onUpdateEvent = function(e) {
var t;
if (this._isProcessCheck) {
t = this._check_process.proccess(e);
console.log("=======> CHotUpdate._onUpdateEvent -> ProcessCheck : " + JSON.stringify(t));
if (t.success && t.finish && t.hasNew) {
this._callCheckUpdatHandler(t.success, t.hasNew, t.msg);
this._isUpdating = !1;
this._isProcessCheck = !1;
}
} else if (this._isProcessUpdate) {
t = this._update_process.proccess(e);
console.log("=======> CHotUpdate._onUpdateEvent -> ProcessUpdate : " + JSON.stringify(t));
if (t.isProcess) this._callProccessHandler(e); else if (t.finish) {
this._callHotUpdatHandler(t.success, t.msg);
this._save();
this._isUpdating = !1;
this._isProcessUpdate = !1;
} else if (t.success) console.log("=======> wait : "); else {
console.log("=======> fail : ");
this._isUpdating = !1;
this._isProcessUpdate = !1;
}
}
};
t.prototype._save = function() {
console.log("=======> CHotUpdate._save -> manifest.nativeUrl : " + this.manifest);
var e = jsb.fileUtils.getSearchPaths();
console.log("========> CHotUpdate._save => jsb.fileUtils.getSearchPaths " + JSON.stringify(e));
var t = this._am.getLocalManifest();
if (t) {
console.log("========> CHotUpdate._save => localManifest " + JSON.stringify(t));
console.log("========> CHotUpdate._save => localManifest.getPackageUrl() " + t.getPackageUrl());
console.log("========> CHotUpdate._save => localManifest.getManifestFileUrl() " + t.getManifestFileUrl());
console.log("========> CHotUpdate._save => localManifest.getVersionFileUrl() " + t.getVersionFileUrl());
}
var s = this._am.getLocalManifest().getSearchPaths();
console.log("========> CHotUpdate._save => localManifest.getSearchPaths " + JSON.stringify(s));
for (var a = s.concat(e), o = [], n = 0; n < a.length; n++) {
var i = a[n];
-1 == o.indexOf(i) && o.push(i);
}
var r = JSON.stringify(o);
console.log("========> CHotUpdate._save => newSearchpathStr " + r);
cc.sys.localStorage.setItem("HotUpdateSearchPaths", r);
jsb.fileUtils.setSearchPaths(o);
cc.audioEngine.stopAll();
};
t.prototype._callCheckUpdatHandler = function(e, t, s) {
this.checkUpdateHandler && this.checkUpdateHandler(e, t, s);
};
t.prototype._callHotUpdatHandler = function(e, t) {
this.hotUpdateHandler && this.hotUpdateHandler(e, t);
};
t.prototype._callProccessHandler = function(e) {
this.processHandler && this.processHandler(e.getPercent(), e.getDownloadedBytes(), e.getTotalBytes(), e.getPercentByFile(), e.getDownloadedFiles(), e.getTotalFiles());
};
t.prototype._versionCompareHandle = function(e, t) {
console.log("JS Custom Version Compare: version A is " + e + ", version B is " + t);
for (var s = e.split("."), a = t.split("."), o = 0; o < s.length; ++o) {
var n = parseInt(s[o]), i = parseInt(a[o] || 0);
if (n !== i) return n - i;
}
return a.length > s.length ? -1 : 0;
};
t.prototype._onVerifyHandle = function(e, t) {
t.compressed, t.md5, t.path, t.size;
console.log("======> verify sucess");
return !0;
};
t.prototype.update = function() {
this._isUpdating || (this._quireToCheckUpdate ? this.checkUpdate() : this._quireToUpdate && this.hotUpdate());
};
t.prototype.checkUpdate = function() {
if (this._isUpdating) this._isProcessUpdate && (this._quireToCheckUpdate = !0); else if (this._am.isUnInited()) this._quireToCheckUpdate = !0; else if (this._am.isManifestReady()) {
this._quireToCheckUpdate = !1;
this._isUpdating = !0;
this._isProcessCheck = !0;
this._am.checkUpdate();
} else this._quireToCheckUpdate = !0;
};
t.prototype.hotUpdate = function() {
if (this._isUpdating) this._isProcessCheck ? this._quireToUpdate = !0 : this._isProcessUpdate; else if (this._am.isUnInited()) this._quireToUpdate = !0; else if (this._am.isManifestReady()) {
this._quireToUpdate = !1;
this._isUpdating = !0;
this._isProcessUpdate = !0;
this._am.update();
} else this._quireToUpdate = !0;
};
t.prototype.clearVersionStorage = function() {
jsb.fileUtils.removeDirectory(this._storagePath);
};
__decorate([ i(cc.Asset) ], t.prototype, "manifest", void 0);
__decorate([ i(cc.Label) ], t.prototype, "lbl", void 0);
return t = __decorate([ n ], t);
}(cc.Component);
s.default = r;
var c = function() {
return function() {};
}(), l = function() {
function e() {}
e.prototype.proccess = function(e) {
var t = new c(), s = e.getEventCode(), o = e.getMessage(), n = !1, i = !1, r = !1;
t.code = s;
switch (s) {
case a.EManifestDownloadStatus.ERROR_NO_LOCAL_MANIFEST:
cc.error("No local manifest file found, hot update skipped.", o);
n = i = !1;
break;

case a.EManifestDownloadStatus.ERROR_DOWNLOAD_MANIFEST:
case a.EManifestDownloadStatus.ERROR_PARSE_MANIFEST:
cc.error("Fail to download manifest file, hot update skipped.", o);
n = i = !1;
break;

case a.EManifestDownloadStatus.ALREADY_UP_TO_DATE:
cc.error("Already up to date with the latest remote version.", o);
n = !0;
i = !1;
break;

case a.EManifestDownloadStatus.NEW_VERSION_FOUND:
console.log("New version found, please try to update.", o);
n = !0;
i = !0;
r = !0;
break;

case a.EManifestDownloadStatus.UPDATE_FINISHED:
case a.EManifestDownloadStatus.UPDATE_PROGRESSION:
r = !1;
n = !0;
console.log("check updating.", s);
break;

default:
cc.error("CCheckUpdateEventProcess other error code =>>>", s);
n = i = !1;
}
t.finish = r;
t.hasNew = i;
t.success = n;
t.msg = o;
return t;
};
return e;
}(), p = function() {
function e() {}
e.prototype.proccess = function(e) {
var t = new c(), s = e.getEventCode(), o = e.getMessage(), n = !1, i = !1, r = !1;
if (s == a.EManifestDownloadStatus.UPDATE_PROGRESSION || a.EManifestDownloadStatus.ASSET_UPDATED == s) {
r = !0;
n = !0;
} else switch (s) {
case a.EManifestDownloadStatus.ERROR_NO_LOCAL_MANIFEST:
cc.error("No local manifest file found, hot update skipped.", o);
break;

case a.EManifestDownloadStatus.ERROR_DOWNLOAD_MANIFEST:
case a.EManifestDownloadStatus.ERROR_PARSE_MANIFEST:
cc.error("Fail to download manifest file, hot update skipped.");
break;

case a.EManifestDownloadStatus.ALREADY_UP_TO_DATE:
cc.error("Already up to date with the latest remote version.");
break;

case a.EManifestDownloadStatus.UPDATE_FINISHED:
console.log("Update finished. " + e.getMessage());
n = !0;
i = !0;
break;

case a.EManifestDownloadStatus.UPDATE_FAILED:
cc.error("Update failed. " + e.getMessage());
break;

case a.EManifestDownloadStatus.ERROR_UPDATING:
cc.error("Asset update error: " + e.getAssetId() + ", " + e.getMessage());
break;

case a.EManifestDownloadStatus.ERROR_DECOMPRESS:
console.log(e.getMessage());
break;

case a.EManifestDownloadStatus.NEW_VERSION_FOUND:
console.log("New version found, please try to update.", o);
n = !0;
}
t.code = s;
t.msg = o;
t.success = n;
t.finish = i;
t.isProcess = r;
return t;
};
return e;
}();
cc._RF.pop();
}, {
"./CJSB": "CJSB"
} ],
CJSB: [ function(e, t, s) {
"use strict";
cc._RF.push(t, "4dd32xHy8dKvKRTNKs/7ol3", "CJSB");
Object.defineProperty(s, "__esModule", {
value: !0
});
(function(e) {
e[e.ERROR_NO_LOCAL_MANIFEST = 0] = "ERROR_NO_LOCAL_MANIFEST";
e[e.ERROR_DOWNLOAD_MANIFEST = 1] = "ERROR_DOWNLOAD_MANIFEST";
e[e.ERROR_PARSE_MANIFEST = 2] = "ERROR_PARSE_MANIFEST";
e[e.NEW_VERSION_FOUND = 3] = "NEW_VERSION_FOUND";
e[e.ALREADY_UP_TO_DATE = 4] = "ALREADY_UP_TO_DATE";
e[e.UPDATE_PROGRESSION = 5] = "UPDATE_PROGRESSION";
e[e.ASSET_UPDATED = 6] = "ASSET_UPDATED";
e[e.ERROR_UPDATING = 7] = "ERROR_UPDATING";
e[e.UPDATE_FINISHED = 8] = "UPDATE_FINISHED";
e[e.UPDATE_FAILED = 9] = "UPDATE_FAILED";
e[e.ERROR_DECOMPRESS = 10] = "ERROR_DECOMPRESS";
e[e.UNINITED = 200] = "UNINITED";
e[e.UNCHECK = 201] = "UNCHECK";
e[e.CHECKING = 202] = "CHECKING";
e[e.UNINSTALL = 203] = "UNINSTALL";
e[e.ALL_READY = 204] = "ALL_READY";
})(s.EManifestDownloadStatus || (s.EManifestDownloadStatus = {}));
var a = function() {
function e() {}
e.getWritablePath = function() {
return jsb.fileUtils ? jsb.fileUtils.getWritablePath() : "/";
};
e.getSearchPaths = function() {
return jsb.fileUtils.getSearchPaths();
};
e.setSearchPaths = function(e) {
jsb.fileUtils.setSearchPaths(e);
};
return e;
}();
s.CJSB = a;
var o = function() {
function e(e, t, s) {
this._assetsManager = new jsb.AssetsManager(e, t, s);
}
e.prototype.setVerifyCallback = function(e) {
this._assetsManager.setVerifyCallback(e);
};
e.prototype.setEventCallback = function(e) {
this._assetsManager.setEventCallback(e);
};
e.prototype.setMaxConcurrentTask = function(e) {
this._assetsManager.setMaxConcurrentTask(e);
};
e.prototype.checkUpdate = function() {
this._assetsManager.checkUpdate();
};
e.prototype.update = function() {
this._assetsManager.update();
};
e.prototype.downloadFailedAssets = function() {
this._assetsManager.downloadFailedAssets();
};
e.prototype.getState = function() {
return this._assetsManager.getState();
};
e.prototype.isUnInited = function() {
return this.getState() === jsb.AssetsManager.State.UNINITED;
};
e.prototype.loadLocalManifest = function(e) {
var t = e;
console.log("url =>", t);
cc.loader.md5Pipe && (t = cc.loader.md5Pipe.transformURL(t));
console.log("md5 url =>", t);
this._assetsManager.loadLocalManifest(t);
};
e.prototype.getLocalManifest = function() {
return this._assetsManager.getLocalManifest();
};
e.prototype.getLocalVersion = function() {
return this._assetsManager ? this._assetsManager.getLocalManifest().getVersion() : "0";
};
e.prototype.isManifestReady = function() {
var e = this.getLocalManifest();
return e && e.isLoaded();
};
e.prototype.bytesToSize = function(e) {
if (0 === e) return "0B";
var t = Math.floor(Math.log(e) / Math.log(1024));
return (e / Math.pow(1024, t)).toPrecision(2) + "" + [ "B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" ][t];
};
e.EventCode = {
ERROR_NO_LOCAL_MANIFEST: 0,
ERROR_DOWNLOAD_MANIFEST: 1,
ERROR_PARSE_MANIFEST: 2,
NEW_VERSION_FOUND: 3,
ALREADY_UP_TO_DATE: 4,
UPDATE_PROGRESSION: 5,
ASSET_UPDATED: 6,
ERROR_UPDATING: 7,
UPDATE_FINISHED: 8,
UPDATE_FAILED: 9,
ERROR_DECOMPRESS: 10
};
return e;
}();
s.CAssetsManager = o;
cc._RF.pop();
}, {} ],
Helloworld: [ function(e, t, s) {
"use strict";
cc._RF.push(t, "e1b90/rohdEk4SdmmEZANaD", "Helloworld");
Object.defineProperty(s, "__esModule", {
value: !0
});
var a = e("./CHotUpdate"), o = cc._decorator, n = o.ccclass, i = o.property, r = function(e) {
__extends(t, e);
function t() {
var t = null !== e && e.apply(this, arguments) || this;
t.version = null;
return t;
}
t.prototype.start = function() {
var e = this.getComponent(a.default);
e.checkUpdateHandler = this.checkUpdateHandler;
e.hotUpdateHandler = this.hotUpdateHandler;
e.processHandler = this.processHandler;
e.checkUpdate();
};
t.prototype.checkUpdateHandler = function(e, t, s) {
console.log("=======> checkUpdateHandler : suess : " + e + " new ? " + t);
if (e && t) {
this.getComponent(a.default).hotUpdate();
}
};
t.prototype.hotUpdateHandler = function(e, t) {
console.log("热更新， ", e);
};
t.prototype.processHandler = function(e, t, s, a, o, n) {};
__decorate([ i(cc.Label) ], t.prototype, "version", void 0);
return t = __decorate([ n ], t);
}(cc.Component);
s.default = r;
cc._RF.pop();
}, {
"./CHotUpdate": "CHotUpdate"
} ]
}, {}, [ "CHotUpdate", "CJSB", "Helloworld" ]);