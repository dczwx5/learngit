/**
 * Created by Administrator on 2016/8/23.
 */
package QFLib.Audio.audio {
import QFLib.Interface.IDisposable;

import flash.events.Event;
import flash.media.SoundChannel;
import flash.media.SoundTransform;
import flash.utils.getTimer;

/**
 *
 * @author Maniac(maniac@qifun.com)
 */
public class CAudio implements IDisposable{

    public function CAudio(audioSource:CAudioSource)
    {
        _soundTransform = new SoundTransform();
        _soundTransform.volume = 1;

        _audioResource = audioSource;
    }

    public function dispose():void
    {

        _playTimes = 0;
        _times = 0;
        _pausePoint = 0.0;

        this.isPlaying = false;
        this.isPaused = false;

        if (_soundChannel){
            _soundChannel.stop();
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
            _soundChannel = null;
        }
    }

    public function play(startTime:Number = 0.0, times:int = 1):void
    {
        _lastStartTime = getTimer();

        this.times = times;

        if(_soundChannel && _soundChannel.hasEventListener(Event.SOUND_COMPLETE)){
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
        }

        _soundChannel = _audioResource.play(_soundTransform);
        if(_soundChannel){
            _soundChannel.addEventListener(Event.SOUND_COMPLETE,_onSoundComplete,false,0,true);
        }

    }

    public function pause():void
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
            _soundChannel = _audioResource.play(_soundTransform,_pausePoint);
            this.isPlaying = true;
        }
    }

    public function stop():void
    {
        if(_soundChannel != null)
        {
            _soundChannel.stop();
            _soundChannel.removeEventListener(Event.SOUND_COMPLETE,_onSoundComplete);
        }

        _pausePoint = 0.0;
        _playTimes = 0;
        this.isPlaying = false;
        this.isPaused = true;
    }

    private function _onSoundComplete(e:Event):void
    {
        _playTimes ++;
        if(this.times != -1 && _playTimes >= this.times)
        {
            _audioResource.audioManager.onPlayCompleted(this);
            dispose();
        }
        else
        {
            //循环播放
            if(_soundChannel){
                _soundChannel.stop();
                _soundChannel.removeEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
                _soundChannel = null;
            }
            _soundChannel = _audioResource.play(_soundTransform);
            if(_soundChannel){
                _soundChannel.addEventListener(Event.SOUND_COMPLETE, _onSoundComplete);
            }
        }
    }

    public function get times():int
    {
        return _times;
    }

    public function set times(value:int):void
    {
        _times = value;
    }

    public function get isPaused():Boolean
    {
        return _isPaused;
    }

    public function set isPaused(value:Boolean):void
    {
        _isPaused = value;
    }

    public function get isPlaying():Boolean {
        return _isPlaying;
    }

    public function set isPlaying(value:Boolean):void
    {
        _isPlaying = value;
    }

    public function get volume():Number
    {
        return _soundTransform.volume;
    }

    public function set volume(value:Number):void
    {
        _volume = value;
        _soundTransform.volume = value;
        if(_soundChannel != null)
        {
            _soundChannel.soundTransform = _soundTransform;
        }
    }

    public function get name():String
    {
        if(_audioResource)
        {
            return _audioResource.name;
        }
        return null;
    }

    public function get audioPath():String
    {
        if(_audioResource)
        {
            return _audioResource.audioPath;
        }
        return null;
    }

    public function getDelayPlayTime():Number
    {
        return _lastStartTime;
    }

    private var _isPlaying:Boolean = false;
    private var _isPaused:Boolean = true;
    private var _pausePoint:Number;

    private var _playTimes:int;
    private var _times:int;

    private var _volume:Number;
    private var _soundChannel:SoundChannel;
    private var _soundTransform:SoundTransform;

    private var _audioResource:CAudioSource;

    /**最近一次请求播放的时间*/
    private var _lastStartTime:Number;

}
}
