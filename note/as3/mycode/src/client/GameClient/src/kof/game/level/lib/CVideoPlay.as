package kof.game.level.lib {

import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CSwfLoader;
import QFLib.ResourceLoader.ELoadingPriority;

import com.greensock.events.LoaderEvent;
import com.greensock.loading.VideoLoader;
import com.greensock.loading.data.VideoLoaderVars;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.Event;

public class CVideoPlay {
	private var _videoFile:String;
	private var _extension:String;

	private var _flvVideoLoader:VideoLoader;
	private var _swfMc:MovieClip;
    private var _mcResource : CResource;

	private var _parent:DisplayObjectContainer;

	private var _onStart:Function;
	private var _onFinish:Function;

	public function CVideoPlay(filmFile:String, parentLayer:DisplayObjectContainer, onStart:Function = null, onFinish:Function = null) {
		_parent = parentLayer;
		_videoFile = filmFile;
		_extension = _videoFile.substr(_videoFile.length-3, 3);
		_onStart = onStart;
		_onFinish = onFinish;
		_init();
	}
	private function _init() : void {
		_parent.stage.addEventListener(Event.RESIZE, _onStageResize);

		if (_extension == "flv" || _extension == "f4v") {
			_flvVideoLoader = new VideoLoader(_videoFile,
					new VideoLoaderVars().container(_parent).autoPlay(true).width(_parent.stage.stageWidth).height(_parent.stage.stageHeight));
			_flvVideoLoader.volume = 1;
			_flvAddEvents();
			_flvVideoLoader.load(true);
			_startPlay();
		} else if (_extension == "swf") {
			CResourceLoaders.instance().startLoadFile( _videoFile, swfOnLoadComplete, null, ELoadingPriority.HIGH );
		} else {
			if (_onFinish) {
				_onFinish();
			}
		}

	}

	public function dispose() : void {
		_removeVideo();
		_removeSwf();
		_parent.stage.removeEventListener(Event.RESIZE, _onStageResize);
		_parent = null;
	}

	public function stop() : void {
		pause();
	}

	private function _startPlay():void {
		_refreshSize();
		if (_onStart) _onStart();
	}

	private function _endPlay():void {
		if (_onFinish) _onFinish();
	}

	public function pause():void {
		if (_extension == "flv" || _extension == "f4v") {
			if (_flvVideoLoader) {
				_flvVideoLoader.pause();
			}
		} else if (_extension == "swf") {
			if (_swfMc) {
				_swfMc.stop();
			}
		}
	}

	public function resume():void {
		if (_extension == "flv" || _extension == "f4v") {
			if (_flvVideoLoader) {
				_flvVideoLoader.resume();
			}
		} else if (_extension == "swf") {
			if (_swfMc) {
				_swfMc.play();
			}
		}
	}

	private function _onStageResize(e:Event):void {
		_refreshSize();
	}
	private function _refreshSize() : void {
		if (_parent && _parent.stage) {
			if (_extension == "flv" || _extension == "f4v") {
				if (_flvVideoLoader) {
					_flvVideoLoader.rawContent.x = 0;
					_flvVideoLoader.rawContent.y = 0;
					_flvVideoLoader.rawContent.width = _parent.stage.stageWidth;
					_flvVideoLoader.rawContent.height = _parent.stage.stageHeight;
				}
			} else if (_extension == "swf") {
				if (_swfMc && isAutoScale) {
					_swfMc.x = _swfMc.y = 0;
					_swfMc.scaleX = _parent.stage.stageWidth / 1500;
					_swfMc.scaleY = _parent.stage.stageHeight / 900;
//						_swfMc.x = 300;
//						_swfMc.y = 300;
//						_swfMc.scaleX = _swfMc.scaleY = 0.6;
					// _swfMc.scaleX = _swfMc.scaleY = 0.7;
//						_swfMc.width = _parent.stage.stageWidth;
//						_swfMc.height = _parent.stage.stageHeight;
				}
			}
		}
	}
	// ==============================================flv/f4v==========================================
	private function _flvAddEvents():void{
		_flvVideoLoader.addEventListener(VideoLoader.VIDEO_COMPLETE, flvOnVideoPlayComplete);
		_flvVideoLoader.addEventListener(LoaderEvent.FAIL, flvOnVideoPlayError);
		_flvVideoLoader.addEventListener(LoaderEvent.ERROR, flvOnVideoPlayError);
		_flvVideoLoader.addEventListener(LoaderEvent.IO_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.addEventListener(LoaderEvent.SECURITY_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.addEventListener(LoaderEvent.UNCAUGHT_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.addEventListener(LoaderEvent.CHILD_FAIL, flvOnVideoPlayError);
	}

	private function flvRemoveEvents():void{
		_flvVideoLoader.removeEventListener(VideoLoader.VIDEO_COMPLETE, flvOnVideoPlayComplete);
		_flvVideoLoader.removeEventListener(LoaderEvent.FAIL, flvOnVideoPlayError);
		_flvVideoLoader.removeEventListener(LoaderEvent.ERROR, flvOnVideoPlayError);
		_flvVideoLoader.removeEventListener(LoaderEvent.IO_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.removeEventListener(LoaderEvent.SECURITY_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.removeEventListener(LoaderEvent.UNCAUGHT_ERROR, flvOnVideoPlayError);
		_flvVideoLoader.removeEventListener(LoaderEvent.CHILD_FAIL, flvOnVideoPlayError);
	}

	private function flvOnVideoPlayError(evt:LoaderEvent) : void {
		_endPlay();
		flvRemoveEvents();
		_flvVideoLoader.clearVideo();
		if (_flvVideoLoader.content.parent) _flvVideoLoader.content.parent.removeChild(_flvVideoLoader.content);
		if (_flvVideoLoader.rawContent.parent) _flvVideoLoader.rawContent.parent.removeChild(_flvVideoLoader.rawContent);

	}

	private function flvOnVideoPlayComplete(evt:Event) : void {
		_endPlay();
	}
	private function _removeVideo() : void {
		if (_flvVideoLoader) {
			flvRemoveEvents();
			_flvVideoLoader.resume();
			_flvVideoLoader.cancel();
			if (_flvVideoLoader.content.parent) _flvVideoLoader.content.parent.removeChild(_flvVideoLoader.content);
			if (_flvVideoLoader.rawContent.parent) _flvVideoLoader.rawContent.parent.removeChild(_flvVideoLoader.rawContent);
			_flvVideoLoader.clearVideo();
			_flvVideoLoader.dispose();
			_flvVideoLoader = null;
		}
	}

	// ==============================================swf==============================================
	private function swfOnLoadComplete( pLoader : CSwfLoader, idError : int ):void {
		if ( 0 == idError ) {
			_mcResource = pLoader.createResource();
			_swfMc = _mcResource.theObject as MovieClip;
			_swfMc.addFrameScript(_swfMc.totalFrames - 1, swfOnPlayComplete);
			_parent.addChild(_swfMc);
			_swfMc.gotoAndPlay(0);
			_startPlay();
		} else {
			swfOnLoadFailure();
		}

	}

	private function swfOnPlayComplete() : void {
		_endPlay();
		// _startPlay();
	}
	private function swfOnLoadFailure():void {
		_endPlay();
		if (_swfMc && _swfMc.parent) _swfMc.parent.removeChild(_swfMc);
	}
	private function _removeSwf() : void {
		if (_swfMc) {
			_swfMc.stop();
			_swfMc.addFrameScript(_swfMc.totalFrames - 1, null);
			if (_swfMc.parent) _swfMc.parent.removeChild(_swfMc);
			_swfMc = null;
		}

		if ( _mcResource ) {
			_mcResource.dispose();
		}
	}

	public function get mc() : DisplayObject {
		return _swfMc;
	}
	public var isAutoScale:Boolean = true;
}
}