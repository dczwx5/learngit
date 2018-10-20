//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Maniac on 2016/9/1.
 */
package kof.game.character.audio {

import kof.game.audio.IAudio;
import kof.game.core.CGameComponent;

/**
 * 音效组件
 * @author Maniac (maniac@qifun.com)
 */
public class CAudioMediator extends CGameComponent {

    private var m_audioSystem:IAudio;

    public function CAudioMediator( audioSystem:IAudio ) {
        super( "AudioComponent" );

        this.m_audioSystem = audioSystem;
    }

    override public function dispose() : void {
        super.dispose();

        m_audioSystem = null;
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    public function loadAudio( data : Object ) : void {
        m_audioSystem.loadAudio( data );
    }

    public function playAudioByName( audioName : String, times : int = 1, startTime : Number = 0.0, playMode : int = 0 ) : void {
        m_audioSystem.playAudioByName( audioName, times, startTime, playMode );
    }

    public function playAudioByPath( fileName : String, times : int = 1, startTime : Number = 0.0, playMode : int = 0 ) : void {
        m_audioSystem.playAudioByPath( fileName, times, startTime, playMode );
    }

    public function stopAudio() : void {
        m_audioSystem.stopAudio();
    }

    public function stopAudioByName( audioName : String ) : void {
        m_audioSystem.stopAudioByName( audioName );
    }

    public function stopAudioByPath( fileName : String ) : void {
        m_audioSystem.stopAudioByPath( fileName );
    }

    public function set audioVolume( value : Number ) : void {
        m_audioSystem.audioVolume = value;
    }

    public function get audioVolume() : Number {
        if(m_audioSystem)return m_audioSystem.audioVolume;
        return 0;
    }

    public function set isAudioMute( value : Boolean ) : void {
        m_audioSystem.isAudioMute = value;
    }

    public function get isAudioMute() : Boolean {
        if(m_audioSystem)return m_audioSystem.isAudioMute;
        return false;
    }

    public function get audioSystem():IAudio {
        return m_audioSystem;
    }
}
}
