import { framework } from "./FrameWork";
import { log } from "./log";

export module sound {
/**
 * ...
 * @author
 */
export class CSoundSystem extends framework.CAppSystem {
	/**播放音效 */
    bSound: boolean = true;
    /**播放音乐 */
    bMusic: boolean = true;
	curMusic: string = "";
	
	constructor(){
		super();

		this.m_playingMap = {};
    	this.m_playTimeMap = {};
	}

	protected onAwake() : void {
		log.log('CSoundSystem.onAwake');
		
		super.onAwake();
	}
	protected onStart() : boolean {
		log.log('CSoundSystem.onStart');
		let ret:boolean = super.onStart();

		return ret;
	}

	playMusic(url: string, loops?:number, complete?:Laya.Handler, startTime?:number) {
		// if (this.bMusic) {
            
		// }
		
		if (this.curMusic != url) {
			this.curMusic = url;
		}
		return Laya.SoundManager.playMusic(url, loops, complete, startTime);
    }

	// isDontPlayWhenPlaying : 当音效已在播放, 就不播
    // isOverrideSame : 覆盖之前播放的音效(同一个)
    // multPlaySameInterval : 连续播放同一个音效的间隔时间, 如果在间隔时间内播放, 就不播, 单位ms
    private m_playingMap:Object;
    private m_playTimeMap:Object;
    playSound(path:string, isDontPlayWhenPlaying:boolean = false, 
        isOverrideSame:boolean = false, multPlaySameInterval:number = 0, finisiHandler:Laya.Handler = null) {
        if (this.bSound) {
            if (isDontPlayWhenPlaying) {
                if (this.m_playingMap.hasOwnProperty(path)) {
                    return ;
                }
                this.m_playingMap[path] = true;
                Laya.SoundManager.playSound(path, 1, Laya.Handler.create(this, this._onPlaySoundFinish, [path, finisiHandler]));
                
            } else if (isOverrideSame) {
                Laya.SoundManager.stopSound(path);
                Laya.SoundManager.playSound(path, 1, finisiHandler);
                
            } else if (multPlaySameInterval > 0) {
                if (this.m_playTimeMap.hasOwnProperty(path)) {
                    let lastPlayTime:number = this.m_playTimeMap[path];
                    if (Laya.timer.currTimer - lastPlayTime < multPlaySameInterval) {
                        return ;
                    }
                }
                this.m_playTimeMap[path] = Laya.timer.currTimer;
                Laya.SoundManager.playSound(path, 1, finisiHandler);    
            } else {
                Laya.SoundManager.playSound(path, 1, finisiHandler);                
            }
        }
    }
    private _onPlaySoundFinish(path:string, finisiHandler:Laya.Handler) {
        if (this.m_playingMap.hasOwnProperty(path)) {
            delete this.m_playingMap[path];
		}
		if (finisiHandler) {
			finisiHandler.run();
		}
    }

	// 是否静音
	get isMuted() : boolean {
		return Laya.SoundManager.muted;
	}
	set isMuted(v:boolean) {
		Laya.SoundManager.muted = v;
	}
	// 是否音效静音
	get isSoundMuted() : boolean {
		return Laya.SoundManager.soundMuted;
	}
	set isSoundMuted(v:boolean) {
		Laya.SoundManager.soundMuted = v;
	}
	// 是否背景音乐静音
	get isMusicMuted() : boolean {
		return Laya.SoundManager.musicMuted;
	}
	set isMusicMuted(v:boolean) {
		Laya.SoundManager.musicMuted = v;
	}
	// 音效音量
	get soundVolume() : number {
		return Laya.SoundManager.soundVolume;
	}
	set soundVolume(v:number) {
		Laya.SoundManager.setSoundVolume(v);
	}
	// 背景音乐音量
	get musicVolume() : number {
		return Laya.SoundManager.musicVolume;
	}
	set musicVolume(v:number) {
		Laya.SoundManager.setMusicVolume(v);
	}

	// 停止音乐音效
	stopSound(url:string) : void {
		Laya.SoundManager.stopSound(url);
	}
	stopAllSound() : void {
		Laya.SoundManager.stopAllSound();
	}
	stopMusic() : void {
		Laya.SoundManager.stopMusic();
	}

	// 释放声音资源(音效和音乐)
	destroySound(url:string) : void {
		Laya.SoundManager.destroySound(url);
	}

	protected onDestroy() : void {
		super.onDestroy();

		Laya.SoundManager.stopAll();
	}
}
}