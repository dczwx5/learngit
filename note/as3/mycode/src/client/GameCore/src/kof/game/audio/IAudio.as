//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/8/29.
 */
package kof.game.audio {

/**
 * @author Maniac (Maniac@qifun.com)
 */
public interface IAudio {

    function loadFile(sFilename:String):void;
    function loadAudio(data:Object):void;
    function playMusic(audioName:String, times:int = int.MAX_VALUE, startTime:Number = 0.0, fadeOutTime:Number = 3.0, fadeInTime:Number = 3.0, bReplay:Boolean = false):void;
    function playMusicByPath(fileName:String, times:int = int.MAX_VALUE, startTime:Number = 0.0, fadeOutTime:Number = 3.0, fadeInTime:Number = 3.0, bReplay:Boolean = false):void;
    function playAudioByName(audioName:String, times:int = 1, startTime:Number = 0.0, playMode:int = 0):void;
    function playAudioByPath(fileName:String, times:int = 1, startTime:Number = 0.0, playMode:int = 0):void;
    function stopMusic():void;
    function stopAudio():void;
    function stopAudioByName(audioName:String):void;
    function stopAudioByPath(fileName:String):void;
    function stopAll():void;
    function disposeAll():void;

    function set musicVolume(value:Number):void;
    function get musicVolume():Number;

    function set audioVolume(value:Number):void;
    function get audioVolume():Number;

    function set isMusicMute(value:Boolean):void;
    function get isMusicMute():Boolean;

    function set isAudioMute(value:Boolean):void;
    function get isAudioMute():Boolean;

    function get musicName():String;

    function get audioManager():Object;



}
}
