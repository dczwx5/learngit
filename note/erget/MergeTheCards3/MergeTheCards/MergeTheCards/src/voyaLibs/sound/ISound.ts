namespace VL {
    export namespace Sound {
        export interface ISound extends VL.ObjectCache.ICacheable {

            /** 声音素材源 */
            source: string;

            /** 音乐还是音效 */
            soundType: SoundType;

            /** 音量 0-1 */
            volume: number;

            /** 声音资源加载完毕事件*/
            // readonly dg_onSoundLoaded: VoyaMVC.Delegate<any>;

            /** 声音时间长度 */
            readonly length: number;

            /** 暂停的位置 */
            readonly pausedPos: number;

            /** 是否正在播放 */
            readonly isPlaying: boolean;

            /** 是否暂停了 */
            readonly isPaused: boolean;

            /** 声音是否加载完毕 */
            readonly isLoaded: boolean;

            /** 是否正在加载声音资源 */
            readonly isLoading: boolean;

            // /** 初始化 */
            // init();

            /** 加载声音资源 */
            load(source: string, loadedCallBack: (sound: ISound) => void, thisObj: any);

            // /** 释放声音资源 */
            dispose();

            /**
             *  播放声音
             * @param loops  循环次数
             * @param fromPause 是否从上次暂停的地方开始
             */
            play(loops: number, fromPause: boolean);

            /**
             *  暂停播放，用play方法并设置fromPause参数为true继续从暂停处播放
             */
            pause();

            /**
             * 停止声音播放
             */
            stop();

        }
    }
}