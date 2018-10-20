

//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */
package kof.game.player.view.playerNew.view.skillvideo {

import QFLib.Foundation;

import flash.events.MouseEvent;
import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Rectangle;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;
import flash.system.Security;

import kof.framework.CAppSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.view.playerNew.CSkillTagViewHandler;

import kof.ui.master.jueseNew.panel.PlayerSkillVideoUI;

import morn.core.handlers.Handler;

public class CSkillVideoPlayView {
    private var _hookUI : PlayerSkillVideoUI = null;
    private var _video : Video = null;
    private var _connection : NetConnection = null;
    private var _stream : NetStream = null;
    private var _videoURL : String = "";
    private var _canPlay : Boolean = false;
    private var _state : int = PAUSE;
    private var _volumeState : int = NORMAL;
    private var _loopState : int = CLOSE;
    private var _duration : Number = 0;
    private static const VIDEOW : Number = 1280;
    private static const VIDEOH : Number = 720;

    public static const PLAY : int = 0;
    public static const PAUSE : int = 1;
    public static const COMPLETE : int = 2;
    public static const DRAG : int = 3;

    public static const NORMAL : int = 0;
    public static const CLOSE : int = 1;
    public static const LOOP : int = 3;

    private var _progressW : Number = 0;
    private var _isLoop : Boolean = false;
    private var _videoName : String = "";

    private var _soundTransform : SoundTransform = null;

    private var _system : CAppSystem;

    public function CSkillVideoPlayView( hookUI : PlayerSkillVideoUI ,system : CAppSystem ) {
        try{
            Security.allowDomain( "*" );
            Security.allowInsecureDomain( "*" );
        }catch (e:Error){
            Foundation.Log.logWarningMsg(e.message);
        }
        this._hookUI = hookUI;
        this._system = system;
        _video = new Video( 475/0.78, 280/0.78 );
        _connection = new NetConnection();
        _connection.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
        _connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
//        _connection.connect( null );

        _hookUI.view_skill.btn_skillTag.clickHandler = new Handler( onSkillTagHandler );
        _hookUI.play.clickHandler = new Handler( _controlPlay );
        _hookUI.pause.clickHandler = new Handler( _controlPlay );

        _hookUI.loop.clickHandler = new Handler( _controlLoop );
        _hookUI.notLoop.clickHandler = new Handler( _controlLoop );

        _hookUI.volume.clickHandler = new Handler( _controlVolume );
        _hookUI.notVolume.clickHandler = new Handler( _controlVolume );
        //            _hookUI.progressBar.changeHandler = new Handler( _progressChange );
//            _hookUI.volume.changeHandler = new Handler( _volumeChange );
//            _hookUI.volume.min = 0;
//            _hookUI.volume.max = 1;
//            _hookUI.volume.value = _video.volume;
//            _hookUI.progress.bar.addEventListener( MouseEvent.MOUSE_DOWN, _barDown );
        App.stage.addEventListener( MouseEvent.MOUSE_UP, _endDrag );
        _hookUI.dragPt.addEventListener( MouseEvent.MOUSE_DOWN, _startDrag );

        _progressW = _hookUI.progressBar.width;

//        _hookUI.closeVideoBtn.clickHandler = new Handler( _closeVideo );
        _soundTransform = new SoundTransform();

        _loopState = LOOP;
        _isLoop = true;
        _hookUI.loop.visible = true;
        _hookUI.notLoop.visible = false;

        _initView();
    }
    public function connection():void{
        _connection.connect( null );
    }

    public function closeVideo() : void {
        if( _stream ){
            _stream.pause();
            _state = PAUSE;
        }

    }

    private function _controlLoop() : void {
        if ( _loopState == LOOP ) {
            _loopState = CLOSE;
            _isLoop = false;
            _hookUI.loop.visible = false;
            _hookUI.notLoop.visible = true;
        } else {
            _loopState = LOOP;
            _isLoop = true;
            _hookUI.loop.visible = true;
            _hookUI.notLoop.visible = false;
        }
    }

    private function _controlVolume() : void {
        if ( _volumeState == NORMAL ) {
            _volumeState = CLOSE;
            _hookUI.volume.visible = false;
            _hookUI.notVolume.visible = true;
            if ( _stream ) {
                _soundTransform.volume = 0;
                _stream.soundTransform = _soundTransform;
            }
        } else {
            _volumeState = NORMAL;
            _hookUI.volume.visible = true;
            _hookUI.notVolume.visible = false;
            if ( _stream ) {
                _soundTransform.volume = 1;
                _stream.soundTransform = _soundTransform;
            }
        }
    }

    private function _startDrag( e : MouseEvent ) : void {
        _state = DRAG;
        _hookUI.dragPt.startDrag( false, new Rectangle( 0, 0, _hookUI.progressBar.bar.width, 0 ) );
    }

    private function _endDrag( e : MouseEvent ) : void {
        if ( _state == DRAG ) {
            _hookUI.stopDrag();
            var time : Number = _hookUI.dragPt.x / _hookUI.progressBar.width * _duration;
            seek( time );
        }
    }

    private function _controlPlay() : void {
        if ( state == PAUSE ) {
            play();
            _hookUI.play.visible = false;
            _hookUI.pause.visible = true;
        } else if ( state == PLAY ) {
            pause();
            _hookUI.play.visible = true;
            _hookUI.pause.visible = false;
        } else if ( state == COMPLETE ) {
//            seek( 0 );
            _stream.play( _videoURL );
            _hookUI.play.visible = false;
            _hookUI.pause.visible = true;
        }
    }

    public function show() : void {
        _hookUI.videoTitle.text = _videoName;
        _hookUI.videoTitle.visible = true;
        _hookUI.videoImg.visible = true;
        _hookUI.videoControlBox.visible = true;
        _video.visible = true;

        if ( state == PAUSE ) {
            _hookUI.play.visible = true;
            _hookUI.pause.visible = false;
        } else {
            _hookUI.play.visible = false;
            _hookUI.pause.visible = true;
        }

        if ( _volumeState == NORMAL ) {
            _hookUI.volume.visible = true;
            _hookUI.notVolume.visible = false;
        } else {
            _hookUI.volume.visible = false;
            _hookUI.notVolume.visible = true;
        }

        if ( _loopState == NORMAL ) {
            _hookUI.notLoop.visible = true;
            _hookUI.loop.visible = false;
        } else {
            _hookUI.notLoop.visible = false;
            _hookUI.loop.visible = true;
        }
    }

    public function hide() : void {
        _video.visible = false;
        _hookUI.videoTitle.visible = false;
        _hookUI.videoImg.visible = false;
        _hookUI.videoControlBox.visible = false;
    }

    private function _initView( ) : void {
        _hookUI.box_videoctn.addChild( _video );
        show();
    }


    public function get state() : int {
        return _state;
    }

    public function get volume() : Number {
        if ( !_stream )return 0;
        return _stream.soundTransform.volume;
    }

    public function get bytesTotal() : uint {
        return _stream.bytesTotal;
    }

    public function get bytestLoaded() : uint {
        return _stream.bytesLoaded;
    }

    public function get bufferLength() : Number {
        return _stream.bufferLength;
    }

    public function get bufferTime() : Number {
        return _stream.bufferTime;
    }

    public function get duration() : Number {
        return _duration;
    }

    private function get time() : Number {
        return _stream.time;
    }

    private function netStatusHandler( e : NetStatusEvent ) : void {
        switch ( e.info.code ) {
            case "NetConnection.Connect.Success":
                connectStream();
                break;
            case "NetStream.Play.StreamNotFound":
                Foundation.Log.logWarningMsg( "Stream not found:" + _videoURL );
                break;
            case "NetStream.Play.Stop":
                _playComplete();
                break;

        }
    }

    private function _playComplete() : void {
        _hookUI.play.visible = true;
        _hookUI.pause.visible = false;
        _state = COMPLETE;
        if ( _isLoop ) {
            _controlPlay();
        }
    }

    private function securityErrorHandler( e : SecurityErrorEvent ) : void {
        trace( "securityErrorHandler:" + e );
    }

    private function connectStream() : void {
        _stream = new NetStream( _connection );
        _stream.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
        var obj : Object = new Object();
        obj.onMetaData = onMetaData;
        obj.onCuePoint = onCuePoint;
        _stream.client = obj;
        _video.attachNetStream( _stream );
        _stream.play( _videoURL );
        _stream.pause();
        _canPlay = true;
        _state = PAUSE;
    }

    private function onMetaData( info : Object ) : void {
        trace( "metadata:duration=" + info.duration + "width=" + info.width + "height=" + info.height + "framerate" + info.framerate );
        _duration = info.duration;
        _hookUI.totalTime.text = "/" + _getTimeStringForTime( _duration );
    }

    private function onCuePoint( info : Object ) : void {
        trace( "cuepoint:time=" + info.time + "name=" + info.name + "type=" + info.type );
    }

    public function playSteam( url : String, videoName : String ) : void {
//            if ( _stream && _canPlay ) {
//                _stream.resume();
//                _state = PLAY;
//            }
        dispose();
        if ( _videoURL != url ) {
            _stream.play( url );
            _videoName = videoName;
            _videoURL = url;
            _state = PLAY;
        } else {
            if ( _state != PLAY ) {
                play();
            }
        }
    }

    public function play() : void {
        if ( _stream ) {
            if ( _canPlay ) {
                if ( time >= _duration ) {
                    seek( 0 );
                } else {
                    _stream.resume();
                    _state = PLAY;
                }
//                    _stream.play( _videoURL );
            } else {
                Foundation.Log.logErrorMsg( "NetConnection Connect Fail " );
            }
        } else {
            Foundation.Log.logErrorMsg( "video stream 与服务器 暂未链接" );
        }
    }

    public function pause() : void {
        if ( _stream ) {
            _stream.pause();
            _state = PAUSE;
        }
    }

    public function seek( nu : Number ) : void {
        if ( _stream ) {
            _stream.seek( nu );
            _state = PLAY;
            _stream.resume();
        }
    }

    public function setVolume( nu : Number ) : void {
        if ( _stream ) {
            _stream.soundTransform.volume = nu;
        }
    }

    public function update() : void {
        _video;
        _hookUI.alreadyTime.text = _getTimeStringForTime( time );
        _hookUI.progressBar.value = _stream.bytesLoaded / _stream.bytesTotal;
        if ( _state != DRAG ) {
            _hookUI.dragPt.x = time / _duration * _progressW - 8;
        }
    }

    private function _getTimeStringForTime( nu : Number ) : String {
//            var h : int = 0;
        var m : int = 0;
        var s : int = 0;
        var sh : String = "";
        var sm : String = "";
        var ss : String = "";
        s = nu % 3600 % 60;
        m = nu % 3600 / 60;
//            h = nu / 3600;

        if ( s < 10 ) {
            ss = "0" + s;
        } else {
            ss = s + "";
        }
        if ( m < 10 ) {
            sm = "0" + m;
        } else {
            sm = "" + m;
        }
//            if ( h < 10 ) {
//                sh = "0" + h;
//            } else {
//                sh = "" + h;
//            }
        return /*sh + ":" + */sm + ":" + ss;
    }

    private function onSkillTagHandler():void{
        (_playerSystem.getBean( CSkillTagViewHandler ) as CSkillTagViewHandler ).addDisplay();
    }

    public function dispose() : void {
        _stream.dispose();
    }

    public function get m__videoURL() : String {
        return _videoURL;
    }

    public function set m__videoURL( value : String ) : void {
        _videoURL = value;
    }

    public function get m__loopState() : int {
        return _loopState;
    }

    public function set m__loopState( value : int ) : void {
        _loopState = value;
    }
    private function get _playerSystem() : CPlayerSystem {
        return _system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
}
}

