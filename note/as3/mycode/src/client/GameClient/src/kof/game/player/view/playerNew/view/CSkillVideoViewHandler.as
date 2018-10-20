//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/5/28.
 */
package kof.game.player.view.playerNew.view {

import QFLib.Foundation;
import QFLib.Foundation.CPath;
import QFLib.ResourceLoader.CResourceLoaders;

import flash.events.MouseEvent;

import flash.events.NetStatusEvent;
import flash.events.SecurityErrorEvent;
import flash.geom.Rectangle;

import flash.media.SoundTransform;

import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

import flash.system.Security;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.config.CKOFConfigSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.table.PlayerDisplay;
import kof.table.SkillVideo;
import kof.ui.master.jueseNew.PlayerSkillVideoIIUI;

import morn.core.components.Dialog;
import morn.core.handlers.Handler;

public class CSkillVideoViewHandler extends CViewHandler {

    private var _skillVideoUI : PlayerSkillVideoIIUI;
    private var _heroData : CPlayerHeroData;
    private var m_pCloseHandler : Handler;

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

    public function CSkillVideoViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }

    override public function get viewClass() : Array {
        return [ PlayerSkillVideoIIUI ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if( !_skillVideoUI ){
            _skillVideoUI = new PlayerSkillVideoIIUI();


            try{
                Security.allowDomain( "*" );
                Security.allowInsecureDomain( "*" );
            }catch (e:Error){
                Foundation.Log.logWarningMsg(e.message);
            }
            _video = new Video( 610, 360 );
            _connection = new NetConnection();
            _connection.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
            _connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
//        _connection.connect( null );
            _skillVideoUI.play.clickHandler = new Handler( _controlPlay );
            _skillVideoUI.pause.clickHandler = new Handler( _controlPlay );

            _skillVideoUI.loop.clickHandler = new Handler( _controlLoop );
            _skillVideoUI.notLoop.clickHandler = new Handler( _controlLoop );

            _skillVideoUI.volume.clickHandler = new Handler( _controlVolume );
            _skillVideoUI.notVolume.clickHandler = new Handler( _controlVolume );

            _skillVideoUI.closeHandler = new Handler( _onClose );
            //            _skillVideoUI.progressBar.changeHandler = new Handler( _progressChange );
//            _skillVideoUI.volume.changeHandler = new Handler( _volumeChange );
//            _skillVideoUI.volume.min = 0;
//            _skillVideoUI.volume.max = 1;
//            _skillVideoUI.volume.value = _video.volume;
//            _skillVideoUI.progress.bar.addEventListener( MouseEvent.MOUSE_DOWN, _barDown );
            App.stage.addEventListener( MouseEvent.MOUSE_UP, _endDrag );
            _skillVideoUI.dragPt.addEventListener( MouseEvent.MOUSE_DOWN, _startDrag );

            _progressW = _skillVideoUI.progressBar.width;

//        _skillVideoUI.closeVideoBtn.clickHandler = new Handler( _closeVideo );
            _soundTransform = new SoundTransform();

            _loopState = LOOP;
            _isLoop = true;
            _skillVideoUI.loop.visible = true;
            _skillVideoUI.notLoop.visible = false;

            _initView();
        }
        return Boolean( _skillVideoUI );
    }

    public function addDisplay( heroData:CPlayerHeroData ) : void {
        _heroData = heroData;
        this.loadAssetsByView( viewClass, _showDisplay );
    }
    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    public function _addToDisplay( ):void {

        var playerDisplay:PlayerDisplay = _playerDisplay.findByPrimaryKey(_heroData.prototypeID) as PlayerDisplay;

        var videoPath : String = "";

        var pConfigSystem : CKOFConfigSystem = system.stage.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
        _videoURL = pConfigSystem.configuration.getString( "videoURL" );
        videoPath = _videoURL + playerDisplay.VideoSource;
        if (/^http:\/\//g.test(videoPath)) {
            videoPath = videoPath + playerDisplay.VideoName + ".mp4";
        } else {
            videoPath = playerDisplay.VideoSource + playerDisplay.VideoName + ".mp4";
            videoPath = (CResourceLoaders.instance().absoluteURI ? CPath.addRightSlash(CResourceLoaders.instance().absoluteURI) : "") + videoPath;
        }
        videoPath = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion(videoPath);

        connection();
        m__loopState = LOOP;
        playSteam( videoPath, playerDisplay.VideoTitle );
        show();

        unschedule( update );
        schedule( 300/1000,update );

        if( !_skillVideoUI.parent )
            uiCanvas.addPopupDialog( _skillVideoUI );
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        unschedule( update );
        closeVideo();
    }

    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }
    public function removeDisplay() : void {
        if ( _skillVideoUI ) {
            _skillVideoUI.close( Dialog.CLOSE );
        }
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
            _skillVideoUI.loop.visible = false;
            _skillVideoUI.notLoop.visible = true;
        } else {
            _loopState = LOOP;
            _isLoop = true;
            _skillVideoUI.loop.visible = true;
            _skillVideoUI.notLoop.visible = false;
        }
    }

    private function _controlVolume() : void {
        if ( _volumeState == NORMAL ) {
            _volumeState = CLOSE;
            _skillVideoUI.volume.visible = false;
            _skillVideoUI.notVolume.visible = true;
            if ( _stream ) {
                _soundTransform.volume = 0;
                _stream.soundTransform = _soundTransform;
            }
        } else {
            _volumeState = NORMAL;
            _skillVideoUI.volume.visible = true;
            _skillVideoUI.notVolume.visible = false;
            if ( _stream ) {
                _soundTransform.volume = 1;
                _stream.soundTransform = _soundTransform;
            }
        }
    }

    private function _startDrag( e : MouseEvent ) : void {
        _state = DRAG;
        _skillVideoUI.dragPt.startDrag( false, new Rectangle( 0, 0, _skillVideoUI.progressBar.bar.width, 0 ) );
    }

    private function _endDrag( e : MouseEvent ) : void {
        if ( _state == DRAG ) {
            _skillVideoUI.stopDrag();
            var time : Number = _skillVideoUI.dragPt.x / _skillVideoUI.progressBar.width * _duration;
            seek( time );
        }
    }

    private function _controlPlay() : void {
        if ( state == PAUSE ) {
            play();
            _skillVideoUI.play.visible = false;
            _skillVideoUI.pause.visible = true;
        } else if ( state == PLAY ) {
            pause();
            _skillVideoUI.play.visible = true;
            _skillVideoUI.pause.visible = false;
        } else if ( state == COMPLETE ) {
            seek( 0 );
            _skillVideoUI.play.visible = false;
            _skillVideoUI.pause.visible = true;
        }
    }

    public function show() : void {
        _skillVideoUI.videoTitle.text = _videoName;
        _skillVideoUI.videoTitle.visible = true;
        _skillVideoUI.videoImg.visible = true;
        _skillVideoUI.videoControlBox.visible = true;
        _video.visible = true;

        if ( state == PAUSE ) {
            _skillVideoUI.play.visible = true;
            _skillVideoUI.pause.visible = false;
        } else {
            _skillVideoUI.play.visible = false;
            _skillVideoUI.pause.visible = true;
        }

        if ( _volumeState == NORMAL ) {
            _skillVideoUI.volume.visible = true;
            _skillVideoUI.notVolume.visible = false;
        } else {
            _skillVideoUI.volume.visible = false;
            _skillVideoUI.notVolume.visible = true;
        }

        if ( _loopState == NORMAL ) {
            _skillVideoUI.notLoop.visible = true;
            _skillVideoUI.loop.visible = false;
        } else {
            _skillVideoUI.notLoop.visible = false;
            _skillVideoUI.loop.visible = true;
        }
    }

    public function hide() : void {
        _video.visible = false;
        _skillVideoUI.videoTitle.visible = false;
        _skillVideoUI.videoImg.visible = false;
        _skillVideoUI.videoControlBox.visible = false;
    }

    private function _initView( ) : void {
        _skillVideoUI.box_video.addChild( _video );
//        _skillVideoUI.addChildAt( _skillVideoUI.videoTitle ,_skillVideoUI.numChildren - 1);
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
        _skillVideoUI.play.visible = true;
        _skillVideoUI.pause.visible = false;
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
        _skillVideoUI.totalTime.text = "/" + _getTimeStringForTime( _duration );
    }

    private function onCuePoint( info : Object ) : void {
        trace( "cuepoint:time=" + info.time + "name=" + info.name + "type=" + info.type );
    }

    public function playSteam( url : String, videoName : String ) : void {
//            if ( _stream && _canPlay ) {
//                _stream.resume();
//                _state = PLAY;
//            }
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

    public function update( delta : Number ) : void {
        _skillVideoUI.alreadyTime.text = _getTimeStringForTime( time );
        _skillVideoUI.progressBar.value = _stream.bytesLoaded / _stream.bytesTotal;
        if ( _state != DRAG ) {
            _skillVideoUI.dragPt.x = time / _duration * _progressW - 8;
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

    override public function dispose() : void {
        super.dispose();
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

    private function get _playerDisplay():IDataTable
    {
        return _dataBase.getTable(KOFTableConstants.PLAYER_DISPLAY);
    }
    private function get _dataBase():IDatabase
    {
        return system.stage.getSystem(IDatabase) as IDatabase;
    }
}
}
