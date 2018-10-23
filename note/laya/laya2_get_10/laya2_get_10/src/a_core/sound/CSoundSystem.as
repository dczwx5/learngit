package a_core.sound
{
	import a_core.framework.CAppSystem;
	import laya.media.SoundManager;
	import laya.utils.Handler;
	import laya.media.SoundChannel;

	/**
	 * ...
	 * @author
	 */
	public class CSoundSystem extends CAppSystem {
		public function CSoundSystem(){
			
		}

		protected override function onAwake() : void {
			super.onAwake();
		}
		protected override function onStart() : Boolean {
			var ret:Boolean = super.onStart();

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
		public static function playMusic(url:String, loops:int = 0, complete:Handler = null, startTime:Number = 0) : SoundChannel {
			return SoundManager.playMusic(url, loops, complete, startTime)
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
		public function playSound(url:String, loops:int = 1, complete:Handler = null, soundClass:Class = null, startTime:Number = 0):SoundChannel {
			return SoundManager.playSound(url, loops, complete, soundClass, startTime);
		}

		// 是否静音
		public function get isMuted() : Boolean {
			return SoundManager.muted;
		}
		public function set isMuted(v:Boolean) : void {
			SoundManager.muted = v;
		}
		// 是否音效静音
		public function get isSoundMuted() : Boolean {
			return SoundManager.soundMuted;
		}
		public function set isSoundMuted(v:Boolean) : void {
			SoundManager.soundMuted = v;
		}
		// 是否背景音乐静音
		public function get isMusicMuted() : Boolean {
			return SoundManager.musicMuted;SoundManager.musicVolume
		}
		public function set isMusicMuted(v:Boolean) : void {
			SoundManager.musicMuted = v;
		}
		// 音效音量
		public function get soundVolume() : Number {
			return SoundManager.soundVolume;
		}
		public function set soundVolume(v:Number) : void {
			SoundManager.setSoundVolume(v);
		}
		// 背景音乐音量
		public function get musicVolume() : Number {
			return SoundManager.musicVolume;
		}
		public function set musicVolume(v:Number) : void {
			SoundManager.setMusicVolume(v);
		}

		// 停止音乐音效
		public function stopSound(url:String) : void {
			SoundManager.stopSound(url);
		}
		public function stopAllSound() : void {
			SoundManager.stopAllSound();
		}
		public function stopMusic() : void {
			SoundManager.stopMusic();
		}

		// 释放声音资源(音效和音乐)
		public function destroySound(url:String) : void {
			SoundManager.destroySound(url);
		}

		protected override function onDestroy() : void {
			super.onDestroy();

			SoundManager.stopAll();
		}
	}

}