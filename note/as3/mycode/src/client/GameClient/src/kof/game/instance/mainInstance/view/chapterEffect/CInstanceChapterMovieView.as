//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/27.
 */
package kof.game.instance.mainInstance.view.chapterEffect {


import QFLib.Foundation.CKeyboard;

import flash.display.MovieClip;

import flash.events.MouseEvent;

import flash.ui.Keyboard;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

import kof.game.common.CLang;

import kof.game.common.view.CRootView;
import kof.game.common.view.component.CCountDownCompoent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.enum.EInstanceWndResType;
import kof.game.level.lib.CVideoPlay;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;
import kof.ui.CUISystem;
import kof.ui.instance.InstanceChapterMovieUI;

import morn.core.components.Button;

// 通关视频
public class CInstanceChapterMovieView extends CRootView {

    private var _keyBoard:CKeyboard;
    public function CInstanceChapterMovieView() {
        super(InstanceChapterMovieUI, [], EInstanceWndResType.INSTANCE_CHAPTER_MOVIE, false);
        viewId = EPopWindow.POP_WINDOW_15;
    }

    protected override function _onCreate() : void {
        setNoneData();

        _keyBoard = new CKeyboard(system.stage.flashStage);
    }
    protected override function _onDispose() : void {
    }
    protected override function _onShow():void {
        _isFirst = true;
    }

    protected override function _onHide() : void {
        if (_video) {
//            _video.dispose();
            _video = null;
        }
        if(_countDownComponent){
            _countDownComponent.dispose();
            _countDownComponent = null;
        }

        removeTick(tickUpdate);
        var reciprocalSystem:CReciprocalSystem = system.stage.getSystem(CReciprocalSystem) as CReciprocalSystem;
        reciprocalSystem.removeEventPopWindow( this.viewId );
    }

    private var _isFirst:Boolean;
    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToDialog(null);
        _ui._img.visible = false;
        _ui._mask.visible = false;
        _ui.btn_resume.visible = false;
        _ui.box_time.visible = false;

        if (_isFirst || !_video) {
            _isFirst = false;
            if (instanceData && instanceData.firstPassMovieUrl && instanceData.firstPassMovieUrl.length > 0) {
                var url:String = "assets/" + instanceData.firstPassMovieUrl;
                _video = new CVideoPlay(url, _ui._box, _onStartPlay, _onPlayFinish);
                _video.isAutoScale = false;
            } else {
                close();
            }
        }

        return true;
    }

    private function _onStartPlay():void{
        if (!_video) {
            delayCall(0.01, _onStartPlayB);
        } else {
            _onStartPlayB();
        }

    }
    private function _onStartPlayB() : void {
        _video.mc.x = -500;
        _video.mc.y = -300;
        _keyBoard.registerKeyCode(true, Keyboard.ESCAPE, _onKeyDown);
        addTick(tickUpdate);
    }

    private function tickUpdate(delta:Number):void{
        var mc:MovieClip = (_video.mc as MovieClip);
        if(mc.isPlaying){
            var i:int = 24/(1/delta);
            mc.gotoAndPlay(mc.currentFrame + i);
        }
        else {
            _countDownComponent.tick();
        }
    }

    private function _onPlayFinish() : void {

        _video.stop();
        _keyBoard.registerKeyCode(true, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.addEventListener(MouseEvent.CLICK,_onClick);
        _ui._img.visible = true;
        _ui.btn_resume.visible = true;
        _ui.box_time.visible = true;
        _ui._mask.visible = true;
        _ui.image_esc.visible = false;
        _ui.btn_resume.addEventListener(MouseEvent.CLICK, onResumeFun);
        _countDownComponent = new CCountDownCompoent(this, _ui.txt_count, 60000, _onCountDownEnd, null, CLang.Get("resourceInstance_Result"));
    }

    private function _onCountDownEnd() : void {
        removeEventFun()
    }

    private function onResumeFun(e:MouseEvent):void{
        _ui._img.visible = false;
        _ui.btn_resume.visible = false;
        _ui.box_time.visible = false;
        _ui._mask.visible = false;
        _ui.image_esc.visible = true;
        addTick(tickUpdate);
        _video.resume();
        _countDownComponent.dispose();
        _countDownComponent = null;
        _keyBoard.unregisterKeyCode(true, Keyboard.SPACE, _onKeyDown);
        system.stage.flashStage.removeEventListener(MouseEvent.CLICK,_onClick);
        _ui.btn_resume.removeEventListener(MouseEvent.CLICK, onResumeFun);
    }

    private function _onClick(e:MouseEvent):void{
        if( e.target is Button)
                return;
        removeEventFun();
    }

    private function _onKeyDown(keyCode:uint):void {
        switch (keyCode) {
            case Keyboard.SPACE:
                removeEventFun();
                break;
            case Keyboard.ESCAPE:
                removeEventFun();
                break;
        }
    }

    private function removeEventFun():void{
        _keyBoard.unregisterKeyCode(true, Keyboard.SPACE, _onKeyDown);
        _keyBoard.unregisterKeyCode(true, Keyboard.ESCAPE, _onKeyDown);
//        removeTick(tickUpdate);
        system.stage.flashStage.removeEventListener(MouseEvent.CLICK,_onClick);
        _ui.btn_resume.removeEventListener(MouseEvent.CLICK, onResumeFun);
        _video.dispose();
        this.close();
    }


    public override function setData(v:Object, forceInvalid:Boolean = true) : void {
        super.setData(v, forceInvalid);
    }

    private function get _ui() : InstanceChapterMovieUI {
        return rootUI as InstanceChapterMovieUI;
    }

    private function get instanceData() : CChapterInstanceData {
        return _data[0] as CChapterInstanceData;
    }

    private var _video:CVideoPlay;
    private var _countDownComponent:CCountDownCompoent;
}
}
