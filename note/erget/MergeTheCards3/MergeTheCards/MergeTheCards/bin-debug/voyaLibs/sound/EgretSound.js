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
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __generator = (this && this.__generator) || function (thisArg, body) {
    var _ = { label: 0, sent: function() { if (t[0] & 1) throw t[1]; return t[1]; }, trys: [], ops: [] }, f, y, t, g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function() { return this; }), g;
    function verb(n) { return function (v) { return step([n, v]); }; }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = y[op[0] & 2 ? "return" : op[0] ? "throw" : "next"]) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [0, t.value];
            switch (op[0]) {
                case 0: case 1: t = op; break;
                case 4: _.label++; return { value: op[1], done: false };
                case 5: _.label++; y = op[1]; op = [0]; continue;
                case 7: op = _.ops.pop(); _.trys.pop(); continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) { _ = 0; continue; }
                    if (op[0] === 3 && (!t || (op[1] > t[0] && op[1] < t[3]))) { _.label = op[1]; break; }
                    if (op[0] === 6 && _.label < t[1]) { _.label = t[1]; t = op; break; }
                    if (t && _.label < t[2]) { _.label = t[2]; _.ops.push(op); break; }
                    if (t[2]) _.ops.pop();
                    _.trys.pop(); continue;
            }
            op = body.call(thisArg, _);
        } catch (e) { op = [6, e]; y = 0; } finally { f = t = 0; }
        if (op[0] & 5) throw op[1]; return { value: op[0] ? op[1] : void 0, done: true };
    }
};
var VL;
(function (VL) {
    var Sound;
    (function (Sound) {
        var EgretSound = (function (_super) {
            __extends(EgretSound, _super);
            function EgretSound(source, soundType) {
                if (source === void 0) { source = null; }
                if (soundType === void 0) { soundType = Sound.SoundType.EFFECT; }
                var _this = _super.call(this) || this;
                _this._soundType = egret.Sound.EFFECT;
                _this._volume = 1;
                _this._pausedPos = 0;
                _this.init(source, soundType);
                return _this;
            }
            EgretSound.prototype.init = function (source, soundType) {
                if (source === void 0) { source = null; }
                if (soundType === void 0) { soundType = Sound.SoundType.EFFECT; }
                if (this.isPlaying) {
                    this.stop();
                }
                this.source = source;
                this.soundType = soundType;
                this._sound = null;
                this._isLoading = false;
                this.volume = 1;
                this._pausedPos = 0;
                // this.dg_onSoundLoaded.clear();
                return this;
            };
            EgretSound.prototype.play = function (loops, fromPause) {
                if (loops === void 0) { loops = 1; }
                if (fromPause === void 0) { fromPause = true; }
                if (this.isPlaying) {
                    this.stop();
                }
                var sound = this._sound;
                if (sound) {
                    this._channel = sound.play(fromPause ? this._pausedPos : 0, loops);
                    this._channel.addEventListener(egret.Event.SOUND_COMPLETE, this.onPlayComplete, this);
                    this._channel.volume = this._volume;
                }
                this._pausedPos = 0;
            };
            EgretSound.prototype.onPlayComplete = function (e) {
                this.stop();
            };
            EgretSound.prototype.pause = function () {
                if (this.isPlaying) {
                    this._pausedPos = this._channel.position;
                    this.stop();
                }
            };
            EgretSound.prototype.stop = function () {
                if (this.isPlaying) {
                    this._channel.stop();
                }
                this._channel.removeEventListener(egret.Event.SOUND_COMPLETE, this.onPlayComplete, this);
                this._channel = null;
            };
            // public async load(source: string): Promise<EgretSound> {
            EgretSound.prototype.load = function (source, loadedCallBack, thisObj) {
                if (loadedCallBack === void 0) { loadedCallBack = null; }
                return __awaiter(this, void 0, void 0, function () {
                    var _this = this;
                    return __generator(this, function (_a) {
                        return [2 /*return*/, new Promise(function (resolve, reject) {
                                if (_this.source == source && _this._sound) {
                                    // this.dg_onSoundLoaded.boardcast(this);
                                    loadedCallBack.call(thisObj, _this);
                                    resolve(_this);
                                }
                                else {
                                    _this._isLoading = true;
                                    RES.getResAsync(source, function (data, key) {
                                        if (getClassByEntity(data) != egret.Sound) {
                                            reject(key + " \u7684\u8D44\u6E90\u7C7B\u578B\u4E0D\u662F egret.Sound");
                                            // throw new Error(`${key} 的资源类型不是 egret.Sound`);
                                        }
                                        _this._sound = data;
                                        _this.source = source;
                                        _this._isLoading = false;
                                        // RES.destroyRes(source);
                                        // this.dg_onSoundLoaded.boardcast(this);
                                        loadedCallBack.call(thisObj, _this);
                                        resolve(_this);
                                    }, _this);
                                }
                            })];
                    });
                });
            };
            EgretSound.prototype.clear = function () {
                RES.destroyRes(this.source);
                this.init();
            };
            EgretSound.prototype.dispose = function () {
                this.restore();
            };
            Object.defineProperty(EgretSound.prototype, "volume", {
                get: function () {
                    return this._volume;
                },
                set: function (value) {
                    this._volume = value;
                    if (this._channel) {
                        this._channel.volume = value;
                    }
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "source", {
                get: function () {
                    return this._source;
                },
                set: function (value) {
                    this._source = value;
                    var newSound = RES.getRes(this.source);
                    if (this._sound != newSound) {
                        this._sound = newSound;
                        if (this._sound) {
                            this._sound.type = this._soundType;
                        }
                    }
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "isLoading", {
                get: function () {
                    return this._isLoading;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "soundType", {
                get: function () {
                    var result = Sound.SoundType.EFFECT;
                    switch (this._soundType) {
                        case egret.Sound.MUSIC:
                            result = Sound.SoundType.MUSIC;
                            break;
                        case egret.Sound.EFFECT:
                            result = Sound.SoundType.EFFECT;
                            break;
                    }
                    return result;
                },
                set: function (type) {
                    switch (type) {
                        case Sound.SoundType.MUSIC:
                            this._soundType = egret.Sound.MUSIC;
                            break;
                        case Sound.SoundType.EFFECT:
                            this._soundType = egret.Sound.EFFECT;
                            break;
                    }
                    if (this._sound) {
                        this._sound.type = this._soundType;
                    }
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "isPlaying", {
                get: function () {
                    return this._channel != null;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "pausedPos", {
                get: function () {
                    return this._pausedPos;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "isPaused", {
                get: function () {
                    return this._pausedPos > 0;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "length", {
                get: function () {
                    return this._sound ? this._sound.length : 0;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(EgretSound.prototype, "isLoaded", {
                get: function () {
                    if (!this.isLoading && this.source && this.source.length > 0) {
                        // return RES.getRes(this.source);
                        return this._sound != null;
                    }
                    else {
                        return false;
                    }
                },
                enumerable: true,
                configurable: true
            });
            return EgretSound;
        }(Sound.SoundBase));
        Sound.EgretSound = EgretSound;
        __reflect(EgretSound.prototype, "VL.Sound.EgretSound", ["VL.Sound.ISound", "VL.ObjectCache.ICacheable"]);
    })(Sound = VL.Sound || (VL.Sound = {}));
})(VL || (VL = {}));
//# sourceMappingURL=EgretSound.js.map