//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/6/23.
 */
package kof.game.resourceInstance.view {

import flash.events.MouseEvent;

import kof.ui.master.ResourceInstance.ResourceInstanceDifficultyItemUI;

import morn.core.components.Button;

public class CResourceInstanceDifficultyItemHandler {
    private var _view:ResourceInstanceDifficultyItemUI
    private var _index:int;
    private var _clickFun:Function;
    private var _instanceID:int;
    public function CResourceInstanceDifficultyItemHandler( _ui:ResourceInstanceDifficultyItemUI, index:int, indstanceID:int, clickFun:Function) {
        _view = _ui;
        _index = index;
//        _view.clip_bg.index = index;
        _instanceID = indstanceID;
        _view.addEventListener(MouseEvent.MOUSE_OVER,_onOverFun );
        _view.addEventListener(MouseEvent.MOUSE_OUT,_onOutFun );
//        _view.btn_challenge.addEventListener(MouseEvent.CLICK, _onChallengeClickFun);
//        _view.btn_sweep.addEventListener(MouseEvent.CLICK, _onSweepClickFun);
//        _view.btn_sweep.visible = false;
        _clickFun = clickFun;
    }

    private function _onChallengeClickFun(e:MouseEvent):void{
        var btn:Button = e.currentTarget as Button;
//        if (btn == _view.btn_challenge){
//            _clickFun(1,_instanceID);
//        }
    }

    private function _onSweepClickFun(e:MouseEvent):void{
        var btn:Button = e.currentTarget as Button;
//        if (btn == _view.btn_sweep){
////            _clickFun(2,10001);
//        }
    }

    private function _onOverFun(e:MouseEvent):void{
//        _view.box_btn.visible = true;
    }

    private function _onOutFun(e:MouseEvent):void{
//        _view.box_btn.visible = false;
    }

    public function update():void{

    }
}
}
