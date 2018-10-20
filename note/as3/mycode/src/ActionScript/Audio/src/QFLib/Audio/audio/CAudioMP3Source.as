/**
 * Created by Maniac on 2016/8/5.
 */
package QFLib.Audio.audio {

import QFLib.Audio.CAudioManager;
import QFLib.Audio.event.CAudioEvent;
import QFLib.Audio.event.CAudioEvent;
import QFLib.Foundation;
import QFLib.ResourceLoader.CMP3Loader;
import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.IOErrorEvent;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.net.URLRequest;

/**
 * as3.0 默认MP3格式播放器
 * @author Maniac(maniac@qifun.com)
 */
public class CAudioMP3Source extends CAudioSource{

    public function CAudioMP3Source(soundURL:String, soundName:String = "", audioMgr:CAudioManager = null, fnOnLoadFinished : Function = null)
    {
        super( fnOnLoadFinished );

        CResourceLoaders.instance().startLoadFile( soundURL, _onLoadMP3Finished, CMP3Loader.NAME, ELoadingPriority.NORMAL, true, false, null, _onStartLoad );

        this.audioPath = soundURL;
        this.name = soundName;
        this.audioManager = audioMgr;
        this._init();
    }

    private function _onStartLoad( sound : Sound ):void
    {
        _sound = sound;
        _isLoadStart = true;
        dispatchEvent(new CAudioEvent(CAudioEvent.SOUND_START));
    }

    private function _onLoadMP3Finished( loader : CMP3Loader, idErrorCode : int ):void
    {
        if( idErrorCode != 0){
            //加载失败
            this._onSoundIOErrorHandler(null);
        }
        else
        {
            if ( loader.urlFile.numTotalBytes > 0 )
                AssetsSize = loader.urlFile.numTotalBytes;
        }

        if ( _fnOnLoadFinished != null )
            _fnOnLoadFinished ( idErrorCode, this );
    }

    override public function dispose():void
    {
        if (_soundChannel){
            _soundChannel.stop();
            _soundChannel = null;
        }
        if(_sound){
            _sound.removeEventListener(IOErrorEvent.IO_ERROR, _onSoundIOErrorHandler);
            _sound = null;
        }
        _isLoadStart = false;
    }

    /**
     * 播放
     */
    override public function play(soundTranform:SoundTransform = null, startTime:Number = 0.0, loops:int = 1):SoundChannel
    {
        if(soundTranform == null)
        {
            _soundTransform = new SoundTransform();
            _soundTransform.volume = 1;
        }
        else
        {
            _soundTransform = soundTranform;
//            _soundTransform.volume = 1;
        }

        if( _sound == null ){
            return null;
        }

        _soundChannel = _sound.play(startTime, loops, _soundTransform);

        return _soundChannel;
    }

    /**
     * 暂停
     */
    override public function pause():void
    {
        this.isPaused = true;

        if(isPlaying && _soundChannel)
        {
            _pausePoint = _soundChannel.position;
            _soundChannel.stop();
            this.isPlaying = false;
        }
        else
        {
            _soundChannel = _sound.play(_pausePoint);
            this.isPlaying = true;
        }
    }

    /**
     * 停止
     */
    override public function stop():void
    {
        if(_soundChannel != null)
        {
            _soundChannel.stop();
        }

        _pausePoint = 0.0;
        _playTimes = 0;
        this.isPlaying = false;
        this.isPaused = true;
    }

    public function get soundChannel():SoundChannel
    {
        return _soundChannel;
    }

    override public function get volume():Number
    {
        if(_soundTransform == null)return 0;
        return _soundTransform.volume;
    }

    override public function set volume(value:Number):void
    {
        _volume = value;
        if(_soundTransform){
            _soundTransform.volume = value;
        }
        if(soundChannel != null)
        {
            soundChannel.soundTransform = _soundTransform;
        }
    }

    override public function get isLoadStart() : Boolean {
        return _isLoadStart;
    }

    private function _init():void
    {
        this.isPaused = true;
    }

    private function _onSoundIOErrorHandler(e:IOErrorEvent):void
    {
        this.stop();
        Foundation.Log.logErrorMsg( "[CAudioMP3Source] load audio failed: IO_ERROR " + this.audioPath);
    }

    private var _sound:Sound;

    private var _soundChannel:SoundChannel;
    private var _soundTransform:SoundTransform;




}
}
