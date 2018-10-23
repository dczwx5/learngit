namespace VL {
    export namespace Sound {
        export class EgretSound extends SoundBase implements ISound {

            // public readonly dg_onSoundLoaded = new VoyaMVC.Delegate<EgretSound>();

            protected _source: string;
            protected _isLoading: boolean;
            protected _sound: egret.Sound;
            protected _soundType: string = egret.Sound.EFFECT;
            protected _volume: number = 1;
            protected _channel: egret.SoundChannel;
            protected _pausedPos: number = 0;

            constructor(source: string = null, soundType: SoundType = SoundType.EFFECT) {
                super();
                this.init(source, soundType);
            }

            public init(source: string = null, soundType: SoundType = SoundType.EFFECT): EgretSound {
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
            }

            public play(loops: number = 1, fromPause: boolean = true) {
                if (this.isPlaying) {
                    this.stop();
                }
                let sound = this._sound;
                if (sound) {
                    this._channel = sound.play(fromPause ? this._pausedPos : 0, loops);
                    this._channel.addEventListener(egret.Event.SOUND_COMPLETE, this.onPlayComplete, this);
                    this._channel.volume = this._volume;
                }
                this._pausedPos = 0;
            }

            protected onPlayComplete(e: egret.Event) {
                this.stop();
            }

            public pause() {
                if (this.isPlaying) {
                    this._pausedPos = this._channel.position;
                    this.stop();
                }
            }

            public stop() {
                if (this.isPlaying) {
                    this._channel.stop();
                }
                this._channel.removeEventListener(egret.Event.SOUND_COMPLETE, this.onPlayComplete, this);
                this._channel = null;
            }

            // public async load(source: string): Promise<EgretSound> {
            public async load(source: string, loadedCallBack: (sound: ISound) => void = null, thisObj: any): Promise<EgretSound> {
                return new Promise<EgretSound>((resolve, reject) => {
                    if (this.source == source && this._sound) {
                        // this.dg_onSoundLoaded.boardcast(this);
                        loadedCallBack.call(thisObj, this);
                        resolve(this);
                    } else {
                        this._isLoading = true;
                        RES.getResAsync(source, (data: egret.Sound, key: string) => {
                            if (getClassByEntity(data) != egret.Sound) {
                                reject(`${key} 的资源类型不是 egret.Sound`);
                                // throw new Error(`${key} 的资源类型不是 egret.Sound`);
                            }
                            this._sound = data;
                            this.source = source;
                            this._isLoading = false;
                            // RES.destroyRes(source);
                            // this.dg_onSoundLoaded.boardcast(this);
                            loadedCallBack.call(thisObj, this);
                            resolve(this);
                        }, this);
                    }
                });
            }

            public clear() {
                RES.destroyRes(this.source);
                this.init();
            }

            public dispose() {
                this.restore();
            }

            public get volume(): number {
                return this._volume;
            }

            public set volume(value: number) {
                this._volume = value;
                if (this._channel) {
                    this._channel.volume = value;
                }
            }

            public set source(value: string) {
                this._source = value;
                let newSound = RES.getRes(this.source);
                if (this._sound != newSound) {
                    this._sound = newSound;
                    if (this._sound) {
                        this._sound.type = this._soundType;
                    }
                }
            }

            public get source(): string {
                return this._source;
            }

            public get isLoading(): boolean {
                return this._isLoading;
            }

            public set soundType(type: SoundType) {
                switch (type) {
                    case SoundType.MUSIC:
                        this._soundType = egret.Sound.MUSIC;
                        break;
                    case SoundType.EFFECT:
                        this._soundType = egret.Sound.EFFECT;
                        break;
                }
                if (this._sound) {
                    this._sound.type = this._soundType;
                }
            }

            public get soundType(): SoundType {
                let result: SoundType = SoundType.EFFECT;
                switch (this._soundType) {
                    case egret.Sound.MUSIC:
                        result = SoundType.MUSIC;
                        break;
                    case egret.Sound.EFFECT:
                        result = SoundType.EFFECT;
                        break;
                }
                return result;
            }

            public get isPlaying(): boolean {
                return this._channel != null;
            }

            public get pausedPos(): number {
                return this._pausedPos;
            }

            public get isPaused(): boolean {
                return this._pausedPos > 0;
            }

            public get length(): number {
                return this._sound ? this._sound.length : 0;
            }

            public get isLoaded(): boolean {
                if (!this.isLoading && this.source && this.source.length > 0) {
                    // return RES.getRes(this.source);
                    return this._sound != null;
                } else {
                    return false;
                }
            }

        }
    }
}