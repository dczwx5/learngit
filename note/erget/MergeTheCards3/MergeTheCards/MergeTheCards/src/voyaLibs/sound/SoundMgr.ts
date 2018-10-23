namespace VL {
    export namespace Sound {
        export class SoundMgr<T_SOUND extends ISound = EgretSound> {

            private _soundClass: new () => T_SOUND;
            private _musicList: { [source: string]: T_SOUND };
            private _effList: { [source: string]: T_SOUND };

            constructor(soundClass: new () => T_SOUND) {
                this._soundClass = soundClass;
                this._musicList = {};
                this._effList = {};
            }

            private createSound(): T_SOUND {
                return create(this._soundClass) as T_SOUND;
            }

            public playEffect(source: string, loops: number) {
                let sound = this.getSoundEffect(source);
                if (sound) {
                    sound.play(loops, false);
                } else {
                    throw new Error(`sound effect entity is not exist !  source:${source}`);
                }
            }

            public playMusic(source: string, loops: number, fromPause: boolean) {
                let sound = this.getMusic(source);
                if (sound) {
                    sound.play(loops, fromPause);
                } else {
                    throw new Error(`music entity is not exist !  source:${source}`);
                }
            }

            public loadSounds(params: LoadSoundsParams<T_SOUND>[]) {
                let loadVo: LoadSoundsParams<T_SOUND>;
                for (let i = 0, l = params.length; i < l; i++) {
                    loadVo = params[i];
                    let soundGroup: { [source: string]: T_SOUND };
                    switch (loadVo.soundType) {
                        case SoundType.EFFECT:
                            soundGroup = this._effList;
                            break;
                        case SoundType.MUSIC:
                            soundGroup = this._musicList;
                            break;
                    }
                    let sound = soundGroup[loadVo.source];

                    if (sound) {
                        loadVo.onLoaded.call(loadVo.thisObj, sound);
                    } else {
                        sound = this.createSound();
                        let cb = function (sound: T_SOUND) {
                            soundGroup[sound.source] = sound;
                            // sound.dg_onSoundLoaded.unregister(this);
                            loadVo.onLoaded.call(loadVo.thisObj, sound);
                        };
                        // sound.dg_onSoundLoaded.register(cb, cb);
                        sound.load(loadVo.source, cb, this);
                    }
                }
            }

            public releaseSound(source: string) {
                let sound = this.getSoundEffect(source);
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
            }

            private getSoundEffect(source: string): T_SOUND {
                return this._effList[source];
            }

            private getMusic(source: string): T_SOUND {
                return this._musicList[source];
            }
        }

        type LoadSoundsParams<T_SOUND extends ISound> = {
            source: string,
            soundType: SoundType,
            onLoaded: (sound: T_SOUND) => void,
            thisObj: any
        }
    }
}