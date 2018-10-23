namespace VL {
    export namespace Sound {
        export abstract class SoundBase extends VL.ObjectCache.CacheableClass {

            // abstract readonly dg_onSoundLoaded: VoyaMVC.Delegate<SoundBase>;
            abstract readonly isLoaded: boolean;
            abstract readonly isLoading: boolean;
            abstract readonly isPaused: boolean;
            abstract readonly isPlaying: boolean;
            abstract readonly length: number;
            abstract readonly pausedPos: number;
            abstract soundType: SoundType;
            abstract source: string;
            abstract volume: number;

            abstract dispose();

            abstract load(source: string, loadedCallBack: (sound: ISound) => void, thisObj: any);

            abstract pause();

            abstract play(loops: number, fromPause: boolean);

            abstract stop();

        }
    }
}