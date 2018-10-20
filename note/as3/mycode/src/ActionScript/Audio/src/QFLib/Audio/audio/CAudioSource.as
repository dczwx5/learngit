/**
 * Created by Maniac on 2016/8/16.
 */
package QFLib.Audio.audio {

import QFLib.Audio.CAudioManager;
import QFLib.Interface.IDisposable;

import flash.events.EventDispatcher;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

/**
 * 播放器基类
 * @author Maniac(maniac@qifun.com)
 */
public class CAudioSource extends EventDispatcher implements IDisposable {

    public var audioManager:CAudioManager;
    public var AssetsSize : int = 0;
    protected var _fnOnLoadFinished : Function = null;

    public function CAudioSource( fnOnLoadFinished : Function = null )
    {
        super();
        _fnOnLoadFinished = fnOnLoadFinished;
    }

    public function dispose():void
    {

    }

    /**
     * 播放
     */
    public function play(soundTranform:SoundTransform = null, startTime:Number = 0.0, loops:int = 1):SoundChannel
    {
        return null;
    }

    /**
     * 暂停
     */
    public function pause():void
    {

    }

    /**
     * 停止
     */
    public function stop():void
    {

    }

    public function get audioPath():String
    {
        return _audioPath;
    }

    public function set audioPath(value:String):void
    {
        _audioPath = value;
    }

    public function get loops():int
    {
        return _loops;
    }

    public function set loops(value:int):void
    {
        _loops = value;
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

    public function get type():int
    {
        return _type;
    }

    public function set type(value:int):void
    {
        _type = value;
    }

    public function get name():String
    {
        return _name;
    }

    public function set name(value:String):void
    {
        _name = value;
    }

    public function get volume():Number
    {
        return _volume;
    }

    public function set volume(value:Number):void
    {
        _volume = value;
    }

    private function _init():void
    {

        this.isPaused = true;
    }

    protected var _audioPath:String;

    protected var _loops:int;

    protected var _isPlaying:Boolean = false;
    protected var _isPaused:Boolean = true;
    protected var _pausePoint:Number;

    protected var _playTimes:int;

    protected var _type:int;
    protected var _name:String;

    protected var _volume:Number;

    protected var _isLoaderComplete:Boolean;
    protected var _isLoadStart:Boolean;

    public function get isLoaderComplete():Boolean {
        return _isLoaderComplete;
    }

    public function set isLoaderComplete(value:Boolean):void {
        _isLoaderComplete = value;
    }

    public function get isLoadStart() : Boolean {
        return _isLoadStart;
    }

    public function set isLoadStart( value : Boolean ) : void {
        _isLoadStart = value;
    }
}
}
