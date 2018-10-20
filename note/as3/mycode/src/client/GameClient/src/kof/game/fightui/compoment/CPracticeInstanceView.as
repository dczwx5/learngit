//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2017/11/29.
 */
package kof.game.fightui.compoment {

import flash.events.Event;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.level.CLevelSystem;
import kof.game.practice.CPracticeHandler;
import kof.game.practice.CPracticeSystem;
import kof.ui.demo.FightUI;

public class CPracticeInstanceView extends CViewHandler {

    private var _bViewInitialized : Boolean = false;
    private var _fightUI : FightUI = null;

    public function CPracticeInstanceView( fightUI : FightUI) {
        super();
        this._fightUI = fightUI;
    }
    override protected function onSetup() : Boolean {
        if ( !super.onInitializeView() )
            return false;
        if ( !_bViewInitialized ) {
            (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.ENTER_INSTANCE, _enterInstance );
            _bViewInitialized = true;
        }
        return _bViewInitialized;
    }

    private function _addEvent() : void {
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).addEventListener( CInstanceEvent.LEVEL_ENTER, _enterLevel );
        _fightUI.box_practice.addEventListener(MouseEvent.CLICK, onClickFun);
        _fightUI.practice_tab_scene.addEventListener(Event.CHANGE, _onChangeTab);
    }

    private function _removeEvent():void{
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.STOP_INSTANCE, _endInstance );
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.LEVEL_ENTER, _enterLevel );
        _fightUI.box_practice.removeEventListener(MouseEvent.CLICK, onClickFun);
        _fightUI.practice_tab_scene.removeEventListener(Event.CHANGE, _onChangeTab);
    }

    private function _endInstance( e : CInstanceEvent ) : void {
        _removeEvent();
    }

    private function _enterInstance( e : CInstanceEvent ) : void {
        var _instanceDate:CChapterInstanceData = (system.stage.getSystem(CInstanceSystem) as CInstanceSystem).getInstanceByID(int(e.data));
        if ( _instanceDate.instanceType == EInstanceType.TYPE_PRACTICE ) {
            _initView();
            _addEvent();
        } else {
            _fightUI.box_practice.visible = false;
            _fightUI.box_practice.visible = false;
        }
    }

    private function _enterLevel(e : CInstanceEvent):void{
        _fightUI.practice_btn_open_AI.visible = false;
        _fightUI.practice_btn_close_AI.visible = true;
    }

    private function _onChangeTab(e:Event):void{
        var index:int = _fightUI.practice_tab_scene.selectedIndex;
        ((system.stage.getSystem( CPracticeSystem ) as CPracticeSystem).getHandler(CPracticeHandler) as CPracticeHandler).practiceResetRequest(index+1);
        _fightUI.practice_box_sence.visible = false;
        _fightUI.practice_btn_changeScene.selected = false;
    }

    private function onClickFun(e:MouseEvent):void{
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.PRACTICE));
        switch (e.target) {
            case  _fightUI.practice_btn_change_own :
                bundleCtx.setUserData(systemBundle, "change_type",[0,_fightUI.practice_btn_close_AI.visible]);
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                break;
            case  _fightUI.practice_btn_change_opponent :
                bundleCtx.setUserData(systemBundle, "change_type",[1,_fightUI.practice_btn_close_AI.visible]);
                bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
                break;
            case  _fightUI.practice_btn_open_AI :
                (system.stage.getSystem( CLevelSystem ) as CLevelSystem).setAIEnable(true);
                _fightUI.practice_btn_close_AI.visible = true;
                _fightUI.practice_btn_open_AI.visible = false;
                break;
            case  _fightUI.practice_btn_close_AI :
                (system.stage.getSystem( CLevelSystem ) as CLevelSystem).setAIEnable(false);
                _fightUI.practice_btn_open_AI.visible = true;
                _fightUI.practice_btn_close_AI.visible = false;
                break;
            case  _fightUI.practice_btn_reset :
                ((system.stage.getSystem( CPracticeSystem ) as CPracticeSystem).getHandler(CPracticeHandler) as CPracticeHandler).practiceResetRequest(0);
                break;
            case  _fightUI.practice_btn_changeScene :
                _fightUI.practice_box_sence.visible = !_fightUI.practice_box_sence.visible;
                _fightUI.practice_btn_changeScene.selected = _fightUI.practice_box_sence.visible;
                break;
        }
    }

    private function _initView() : void {
        _fightUI.box_practice.visible = true;
        _fightUI.practice_box_sence.visible = false;
        _fightUI.practice_btn_changeScene.selected = false;
        _fightUI.practice_tab_scene.selectedIndex = 0;
    }

    override public function dispose() : void {
        super.dispose();
        (system.stage.getSystem( CInstanceSystem ) as CInstanceSystem).removeEventListener( CInstanceEvent.LEVEL_ENTER, _enterLevel );
    }
}
}
