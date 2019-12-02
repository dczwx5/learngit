namespace gameframework {
export namespace sound {

/**
 * ...
 * @author
 */
export class CSoundSystem extends framework.CAppSystem {
	constructor(){
		super();
	}

	protected onAwake() : void {
		super.onAwake();
	}
	protected onStart() : boolean {
		let ret:boolean = super.onStart();

		return ret;
	}

	/**
	 * 播放背景音乐。背景音乐同时只能播放一个，如果在播放背景音乐时再次调用本方法，会先停止之前的背景音乐，再播发当前的背景音乐。
	 * @param url		声音文件地址。
	 * @param loops		循环次数,0表示无限循环。
	 * @param complete	声音播放完成回调。
	 * @param startTime	声音播放起始时间。
	 * @return SoundChannel对象，通过此对象可以对声音进行控制，以及获取声音信息。
	 */
	public static playMusic(url:string, loops:number = 0, complete:Laya.Handler = null, startTime:number = 0) : Laya.SoundChannel {
		return Laya.SoundManager.playMusic(url, loops, complete, startTime)
	}

	/**
	 * 播放音效。音效可以同时播放多个。
	 * @param url			声音文件地址。
	 * @param loops			循环次数,0表示无限循环。
	 * @param complete		声音播放完成回调  Handler对象。
	 * @param soundClass	使用哪个声音类进行播放，null表示自动选择。
	 * @param startTime		声音播放起始时间。
	 * @return SoundChannel对象，通过此对象可以对声音进行控制，以及获取声音信息。
	 */
	public playSound(url:string, loops:number = 1, complete:Laya.Handler = null, soundClass:new()=>any = null, startTime:number = 0):Laya.SoundChannel {
		return Laya.SoundManager.playSound(url, loops, complete, soundClass, startTime);
	}

	// 是否静音
	public get isMuted() : boolean {
		return Laya.SoundManager.muted;
	}
	public set isMuted(v:boolean) {
		Laya.SoundManager.muted = v;
	}
	// 是否音效静音
	public get isSoundMuted() : boolean {
		return Laya.SoundManager.soundMuted;
	}
	public set isSoundMuted(v:boolean) {
		Laya.SoundManager.soundMuted = v;
	}
	// 是否背景音乐静音
	public get isMusicMuted() : boolean {
		return Laya.SoundManager.musicMuted;
	}
	public set isMusicMuted(v:boolean) {
		Laya.SoundManager.musicMuted = v;
	}
	// 音效音量
	public get soundVolume() : number {
		return Laya.SoundManager.soundVolume;
	}
	public set soundVolume(v:number) {
		Laya.SoundManager.setSoundVolume(v);
	}
	// 背景音乐音量
	public get musicVolume() : number {
		return Laya.SoundManager.musicVolume;
	}
	public set musicVolume(v:number) {
		Laya.SoundManager.setMusicVolume(v);
	}

	// 停止音乐音效
	public stopSound(url:string) : void {
		Laya.SoundManager.stopSound(url);
	}
	public stopAllSound() : void {
		Laya.SoundManager.stopAllSound();
	}
	public stopMusic() : void {
		Laya.SoundManager.stopMusic();
	}

	// 释放声音资源(音效和音乐)
	public destroySound(url:string) : void {
		Laya.SoundManager.destroySound(url);
	}

	protected onDestroy() : void {
		super.onDestroy();

		Laya.SoundManager.stopAll();
	}
}
}
}