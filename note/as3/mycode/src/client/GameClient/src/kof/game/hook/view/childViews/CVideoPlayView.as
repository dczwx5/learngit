//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/9/22.
 * Time: 14:46
 */
package kof.game.hook.view.childViews {

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

import kof.data.CDataTable;
import kof.game.config.CKOFConfigSystem;
import kof.game.hook.CHookClientFacade;
import kof.game.hook.view.CHookView;
import kof.table.HangUpSkillVideo;
import kof.ui.master.hangup.HangUpUI;

import morn.core.handlers.Handler;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/9/22
     */
    public class CVideoPlayView {
        private var _hookView : CHookView = null;
        private var _hookUI : HangUpUI = null;
        private var _video : Video = null;
        private var _connection : NetConnection = null;
        private var _stream : NetStream = null;
        private var _videoURL : String = "assets/video/mp4test/bashen.mp4";
        private var _parent : HangUpUI = null;
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

        public function CVideoPlayView( hookView : CHookView ) {
            try{
                Security.allowDomain( "*" );
                Security.allowInsecureDomain( "*" );
            }catch (e:Error){
                Foundation.Log.logWarningMsg(e.message);
            }
            this._hookView = hookView;
            this._hookUI = hookView.hookUI;
            var skillVideoTabel : CDataTable = CHookClientFacade.instance.hangUpSkillVideo;
            var hangUpSkillVideo : HangUpSkillVideo = skillVideoTabel.findByPrimaryKey( 2 );
            var videoPath : String = "";
            var videoURL : String = "";
            //公司cdn地址
            var pConfigSystem : CKOFConfigSystem = CHookClientFacade.instance.hookSystem.stage.getSystem( CKOFConfigSystem ) as CKOFConfigSystem;
            videoURL = pConfigSystem.configuration.getString( "videoURL" );

            videoPath=videoURL+hangUpSkillVideo.videoSource;
            if (/^http:\/\//g.test(videoPath)) {
                videoPath = videoPath+hangUpSkillVideo.videoName + ".mp4";
            } else {
                videoPath = hangUpSkillVideo.videoSource + hangUpSkillVideo.videoName + ".mp4";
                videoPath = (CResourceLoaders.instance().absoluteURI ? CPath.addRightSlash(CResourceLoaders.instance().absoluteURI) : "") + videoPath;
            }
            videoPath = CResourceLoaders.instance().assetVersion.mappingFilenameWithVersion(videoPath);
            _videoURL = videoPath;
            _videoName = hangUpSkillVideo.videoDis;
            _video = new Video( 640, 480 );
            _connection = new NetConnection();
            _connection.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
            _connection.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
            _connection.connect( null );
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

            _hookUI.closeVideoBtn.clickHandler = new Handler( _closeVideo );
            _soundTransform = new SoundTransform();

            _loopState = LOOP;
            _isLoop = true;
            _hookUI.loop.visible = true;
            _hookUI.notLoop.visible = false;
        }

        private function _closeVideo() : void {
            hide();
            _stream.pause();
            _state = PAUSE;
            _hookView.showRecommendVideoView();
//            _stream.dispose();
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
            if ( state == CVideoPlayView.PAUSE ) {
                play();
                _hookUI.play.visible = false;
                _hookUI.pause.visible = true;
            } else if ( state == CVideoPlayView.PLAY ) {
                pause();
                _hookUI.play.visible = true;
                _hookUI.pause.visible = false;
            } else if ( state == CVideoPlayView.COMPLETE ) {
                seek( 0 );
                _hookUI.play.visible = false;
                _hookUI.pause.visible = true;
            }
        }

        public function show() : void {
            _hookUI.videoTitle.text = _videoName;
            _hookUI.videoTitle.visible = true;
            _hookUI.closeVideoBtn.visible = true;
            _hookUI.videoImg.visible = true;
            _hookUI.videoControlBox.visible = true;
            _video.visible = true;

            if ( state == CVideoPlayView.PAUSE ) {
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
            _hookUI.closeVideoBtn.visible = false;
            _hookUI.videoImg.visible = false;
            _hookUI.videoControlBox.visible = false;
        }

        public function set parent( value : HangUpUI ) : void {
            _parent = value;
            _parent.addChild( _video );
            var fit : Number = 0;
            var fitW : Number = VIDEOW / _parent.videoImg.width;
            var fitH : Number = VIDEOH / _parent.videoImg.height;
            fit = fitW > fitH ? fitW : fitH;
            if ( fit > 1 ) {
                _video.width = VIDEOW / fit;
                _video.height = VIDEOH / fit;
            } else {
                _video.width = VIDEOW;
                _video.height = VIDEOH;
            }
            _video.x = _parent.videoImg.x + ((_parent.videoImg.width - _video.width) >> 1);
            _video.y = _parent.videoImg.y + ((_parent.videoImg.height - _video.height) >> 1);

            _hookUI.addChild( _hookUI.videoTitle );
            _hookUI.addChild( _hookUI.closeVideoBtn );

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
            _state = CVideoPlayView.COMPLETE;
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

        public function dispose() : void {
            _stream.dispose();
        }
    }
}
