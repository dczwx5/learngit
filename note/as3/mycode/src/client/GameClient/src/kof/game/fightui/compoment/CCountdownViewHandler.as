//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/5/24.
 * 倒计时
 */
package kof.game.fightui.compoment {

import kof.framework.CViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.IInstanceFacade;
import kof.game.instance.event.CInstanceEvent;
import kof.ui.demo.FightUI;
import kof.util.CBitmapNumber;

public class CCountdownViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;

    private var _bNum:CBitmapNumber;

    private var _num:int;

    public function CCountdownViewHandler($fightUI:FightUI) {
        super();
        m_fightUI = $fightUI;
        m_fightUI.kofnum_time.visible =
                m_fightUI.img_maxtime.visible = false;
    }
    public function setData():void {
        if(pInstanceSystem)
            pInstanceSystem.listenEvent(_onInstanceEvent);
    }

    private function _onInstanceEvent(e:CInstanceEvent) : void {
        if ( e.type == CInstanceEvent.LEVEL_STARTED ) {
//            _num = pInstanceSystem.levelLeftTime;
            m_fightUI.kofnum_time.visible = ( _num != -1 && _num <= 999 );
            m_fightUI.img_maxtime.visible = ( _num == -1 || _num > 999 );
            if(_num != -1 && _num > 0){
                _previousTime = new Date().valueOf();
                updateView(0);
                schedule(1,updateView);
            }
        }else if( e.type == CInstanceEvent.END_INSTANCE ){
            unschedule(updateView);
            pInstanceSystem.unListenEvent(_onInstanceEvent);
        }else if( e.type == CInstanceEvent.WINACTOR_STRAT){
            unschedule(updateView);
        }else if( e.type == CInstanceEvent.SCENARIO_START ){
            unschedule(updateView);
        }else if( e.type == CInstanceEvent.SCENARIO_END ){
            var pInstanceSys : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
            if ( pInstanceSys && pInstanceSys.isMainCity) {
                return;
            }
            _previousTime = new Date().valueOf();
            updateView(0);
            schedule(1,updateView);
            m_fightUI.kofnum_time.visible = ( _num != -1  && _num <= 999 );
            m_fightUI.img_maxtime.visible = ( _num == -1 || _num > 999 );
        }else if( e.type == CInstanceEvent.INSTANCE_UPDATE_TIME ){
            _num = int( e.data );
            _previousTime = new Date().valueOf();
            updateView(0);
            schedule(1,updateView);
            m_fightUI.kofnum_time.visible = ( _num != -1  && _num <= 999 );
            m_fightUI.img_maxtime.visible = ( _num == -1 || _num > 999 );
        }//else if(e.type == CInstanceEvent.BOSS_COMING_END){
//            _previousTime = new Date().valueOf();
//            updateView(0);
//            schedule(1,updateView);
//            m_fightUI.kofnum_time.visible = ( _num != -1  && _num <= 999 );
//            m_fightUI.img_maxtime.visible = ( _num == -1 || _num > 999 );
//        }
        else if(e.type == CInstanceEvent.LEVEL_ENTER){
            _num = int( e.data );
            _previousTime = new Date().valueOf();
            m_fightUI.kofnum_time.num = _num;
            m_fightUI.kofnum_time.visible = ( _num != -1  && _num <= 999 );
            m_fightUI.img_maxtime.visible = ( _num == -1 || _num > 999 );
        }
    }
    private var _previousTime: Number;
    private function updateView( delta : Number ):void {
        var currentTime : Number = new Date().valueOf();
        var duration : Number = currentTime - _previousTime;
        if( _num - int(duration / 1000.0) <= 0 ){
            _num = 0;
            m_fightUI.kofnum_time.num = 0;
            unschedule(updateView);
            m_fightUI.img_maxtime.visible = false;
            pInstanceSystem.levelTimeOut();
            return;
        }
        m_fightUI.img_maxtime.visible = _num > 999;
        m_fightUI.kofnum_time.visible = _num <= 999;
        if( m_fightUI.kofnum_time.visible )
            m_fightUI.kofnum_time.num = _num - int(duration / 1000.0);
        else
            m_fightUI.box_maxtime.centerX =0;

//        _num --;
    }
    private function get pInstanceSystem():CInstanceSystem {
        return system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
    public function hide(removed:Boolean = true):void {
//        unschedule(updateView);
        m_fightUI.kofnum_time.visible =
                m_fightUI.img_maxtime.visible = false;
    }
}
}
