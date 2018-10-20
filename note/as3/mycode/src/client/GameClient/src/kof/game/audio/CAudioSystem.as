//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.audio {

import QFLib.Audio.CAudioManager;
import QFLib.Interface.IUpdatable;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;

import kof.framework.CAppStage;

import kof.framework.CAppSystem;
import kof.framework.IDataTable;

/**
 * @author Maniac (maniac@qifun.com)
 */
public class CAudioSystem extends CAppSystem implements IAudio, IUpdatable {

    private var _audioManager:CAudioManager;

    public function CAudioSystem() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret:Boolean = super.onSetup();
        if(ret)
        {
            ret = ret && this.addBean( _audioManager = new CAudioManager() );
            _audioManager.audioDatasIteration(this.audioTable.tableMap);
        }
        return ret;
    }

    override protected virtual function onShutdown() : Boolean {
        var ret : Boolean = super.onShutdown();
        if ( ret ) {
            this.disposeAll();
        }
        return ret;
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
    }

    override public function dispose() : void {
        this.disposeAll();
        super.dispose();
    }

    public function loadFile( sFilename : String ) : void {
        _audioManager.loadFile(sFilename);
    }

    public function loadAudio( data:Object) : void{
        _audioManager.loadAudio(data);
    }

    public function playMusic( audioName : String, times : int = int.MAX_VALUE, startTime : Number = 0.0, fadeOutTime : Number = 3.0, fadeInTime : Number = 3.0, bReplay:Boolean = false ) : void {
        _audioManager.playMusic(audioName, times, startTime, fadeOutTime, fadeInTime)
    }

    public function playMusicByPath( fileName : String, times : int = int.MAX_VALUE, startTime : Number = 0.0, fadeOutTime : Number = 3.0, fadeInTime : Number = 3.0, bReplay:Boolean = false ) : void {
        _audioManager.playMusicByPath( fileName, times, startTime, fadeOutTime, fadeInTime);
    }

    public function playAudioByName( audioName : String, times : int = 1, startTime : Number = 0.0, playMode:int = 0 ) : void {
        _audioManager.playAudioByName(audioName, times, startTime, playMode);
    }

    public function playAudioByPath( fileName : String, times : int = 1, startTime : Number = 0.0, playMode:int = 0 ) : void {
        _audioManager.playAudioByPath(fileName, times, startTime, playMode);
    }

    public function stopAudioByName( audioName : String ) : void {
        _audioManager.stopAudioByName(audioName);
    }

    public function stopAudioByPath( fileName : String ) : void {
        _audioManager.stopAudioByPath(fileName);
    }

    public function stopMusic() : void {
        _audioManager.stopMusic();
    }

    public function stopAudio() : void {
        _audioManager.stopAudio();
    }

    public function stopAll() : void {
        _audioManager.stopAll();
    }

    public function disposeAll() : void {
        _audioManager.disposeAll();
    }

    public function set musicVolume( value : Number ) : void {
        _audioManager.musicVolume = value;
    }

    public function get musicVolume() : Number {
        if(_audioManager)
        {
           return _audioManager.musicVolume;
        }
        return 0;
    }

    public function set audioVolume( value : Number ) : void {
        _audioManager.audioVolume = value;
    }

    public function get audioVolume() : Number {
        if(_audioManager)
        {
            return _audioManager.audioVolume;
        }
        return 0;
    }

    public function set isMusicMute( value : Boolean ) : void {
        _audioManager.isMusicMute = value;
    }

    public function get isMusicMute() : Boolean {
        return _audioManager.isMusicMute;
    }

    public function set isAudioMute( value : Boolean ) : void {
        _audioManager.isAudioMute = value;
    }

    public function get isAudioMute() : Boolean {
        return _audioManager.isAudioMute;
    }

    public function update( delta : Number ) : void {
        if ( _audioManager )
            _audioManager.update( delta );
    }

    public function get musicName() : String {
        return _audioManager.musicName;
    }

    public function get audioManager() : Object
    {
        return _audioManager;
    }

    private function get audioTable() : IDataTable {
        var audioTable : IDataTable = (stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.AUDIO );
        return audioTable;
    }

}
}
