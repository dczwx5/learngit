var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var Sound;
    (function (Sound) {
        var SoundMgr = (function () {
            function SoundMgr(soundClass) {
                this._soundClass = soundClass;
                this._musicList = {};
                this._effList = {};
            }
            SoundMgr.prototype.createSound = function () {
                return create(this._soundClass);
            };
            SoundMgr.prototype.playEffect = function (source, loops) {
                var sound = this.getSoundEffect(source);
                if (sound) {
                    sound.play(loops, false);
                }
                else {
                    throw new Error("sound effect entity is not exist !  source:" + source);
                }
            };
            SoundMgr.prototype.playMusic = function (source, loops, fromPause) {
                var sound = this.getMusic(source);
                if (sound) {
                    sound.play(loops, fromPause);
                }
                else {
                    throw new Error("music entity is not exist !  source:" + source);
                }
            };
            SoundMgr.prototype.loadSounds = function (params) {
                var loadVo;
                var _loop_1 = function (i, l) {
                    loadVo = params[i];
                    var soundGroup;
                    switch (loadVo.soundType) {
                        case Sound.SoundType.EFFECT:
                            soundGroup = this_1._effList;
                            break;
                        case Sound.SoundType.MUSIC:
                            soundGroup = this_1._musicList;
                            break;
                    }
                    var sound = soundGroup[loadVo.source];
                    if (sound) {
                        loadVo.onLoaded.call(loadVo.thisObj, sound);
                    }
                    else {
                        sound = this_1.createSound();
                        var cb = function (sound) {
                            soundGroup[sound.source] = sound;
                            // sound.dg_onSoundLoaded.unregister(this);
                            loadVo.onLoaded.call(loadVo.thisObj, sound);
                        };
                        // sound.dg_onSoundLoaded.register(cb, cb);
                        sound.load(loadVo.source, cb, this_1);
                    }
                };
                var this_1 = this;
                for (var i = 0, l = params.length; i < l; i++) {
                    _loop_1(i, l);
                }
            };
            SoundMgr.prototype.releaseSound = function (source) {
                var sound = this.getSoundEffect(source);
                if (sound) {
                    delete this._effList[source];
                    sound.restore();
                    return;
                }
                sound = this.getMusic(source);
                if (sound) {
                    delete this._musicList[source];
                    sound.restore();
                }
            };
            SoundMgr.prototype.getSoundEffect = function (source) {
                return this._effList[source];
            };
            SoundMgr.prototype.getMusic = function (source) {
                return this._musicList[source];
            };
            return SoundMgr;
        }());
        Sound.SoundMgr = SoundMgr;
        __reflect(SoundMgr.prototype, "VL.Sound.SoundMgr");
    })(Sound = VL.Sound || (VL.Sound = {}));
})(VL || (VL = {}));
//# sourceMappingURL=SoundMgr.js.map