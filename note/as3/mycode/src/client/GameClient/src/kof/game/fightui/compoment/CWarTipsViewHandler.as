//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/9/7.
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import flash.utils.Dictionary;

import kof.framework.CViewHandler;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.core.CGameObject;
import kof.ui.demo.FightUI;

import morn.core.components.Clip;
import morn.core.components.FrameClip;
import morn.core.events.UIEvent;

public class CWarTipsViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;
    private var _totalDic:Dictionary;
    private var _showAry:Array;
    private var _pCharacterMediator : CCharacterFightTriggle;

    public function CWarTipsViewHandler($fightUI:FightUI) {
        super();
        m_fightUI = $fightUI;
        _resetHitEff();
        _totalDic = new Dictionary();
        _totalDic[CFightTriggleEvent.EVT_PLAYER_CRITICALHIT] = [m_fightUI.box_criticakhit,m_fightUI.eff_criticakhit];
        _totalDic[CFightTriggleEvent.EVT_PLAYER_COUNTER] = [m_fightUI.box_counter,m_fightUI.eff_counter];
        _totalDic[CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL] = [m_fightUI.box_drivecancel,m_fightUI.eff_drivecancel];
        _totalDic[CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL] = [m_fightUI.box_supercancel,m_fightUI.eff_supercancel];
        _totalDic[CFightTriggleEvent.EVT_PLAYER_QUICKSTANDING] = [m_fightUI.box_quickstanding,m_fightUI.eff_quickstanding];
        _showAry = [];
        _addEventListener();
    }
    public function setData(hero:CGameObject):void {
        hide();
        if(!m_fightUI || !hero)
            return;
        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning ){
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_COUNTER ,_onEffHandler);
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_CRITICALHIT ,_onEffHandler);
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL,_onEffHandler );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL,_onEffHandler );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_QUICKSTANDING,_onEffHandler );
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT,_onRushEff );
        }
        _pCharacterMediator = hero.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_COUNTER,_onEffHandler, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_CRITICALHIT,_onEffHandler, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_DRIVECANCEL,_onEffHandler, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_SUPERCANCEL,_onEffHandler, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_QUICKSTANDING,_onEffHandler, false, 0, true );
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_PLAYER_CONTINUSHITCNT,_onRushEff, false, 0, true );

    }
    private function _onEffHandler(evt:CFightTriggleEvent):void{
        showTips(_totalDic[evt.type]);
    }
    private function showTips(ary:Array):void{
        if(_showAry.indexOf(ary) != -1){
            (ary[1] as FrameClip).gotoAndPlay(0);
        }else{
            if(_showAry.length >= 3){
                _showAry[0][1].gotoAndStop(0);
                _showAry[0][0].visible = false;
                _showAry.shift();
            }
            _showAry.push(ary);
            resetY();
            ary[0].visible = true;
            ary[1].gotoAndPlay(0);
        }
    }
    private function _onFrameChanged(evt:UIEvent):void{
        if( evt.currentTarget.frame >=  evt.currentTarget.totalFrame - 1) {
            var arr:Array;
            for each(  arr in _showAry){
               if(arr[1] == evt.currentTarget){
                   arr[1].gotoAndStop(0);
                   arr[0].visible = false;
                   _showAry.splice(_showAry.indexOf(arr),1);
                   break;
               }
            }
//            resetY();
        }
    }
    private function resetY():void{
        var h:int;
        var arr:Array;
        for each ( arr in _showAry ){
            arr[0].y = h + 400;
            h += arr[0].height ;
        }
    }
    private var _oldValue1:int = 0;
    private var _oldValue2:int = 0;
    private var _oldValue3:int = 0;
    private var _num:int;
    private function _onRushEff(evt:CFightTriggleEvent ):void {
        var num:int = int(evt.parmList[0]);
        if(num <= 0)
                return;
        TweenLite.killTweensOf(m_fightUI.box_numrush);
        rushNumEff(_oldValue1 , num /100 % 10 , m_fightUI.numrush_1 ,m_fightUI.rushNum_big1);
        rushNumEff(_oldValue2 , num /10 % 10 , m_fightUI.numrush_2 ,m_fightUI.rushNum_big2);
        rushNumEff(_oldValue3 , num % 10 , m_fightUI.numrush_3 ,m_fightUI.rushNum_big3);
        _oldValue1 =  num /100 % 10;
        _oldValue2 =  num /10 % 10;
        _oldValue3 =  num % 10;


        hideHitLevel();
        m_fightUI.box_rush.visible = true;
        TweenLite.to(m_fightUI.box_numrush, .2, {y:-10,onComplete:onCompleteHandler});
        function onCompleteHandler():void {
            TweenLite.to(m_fightUI.box_numrush, .2, {y:0,onComplete:onCompleteHandlerI});
        }
        function onCompleteHandlerI():void {
            TweenLite.to(m_fightUI.box_numrush, 2, {onComplete:onCompleteHandlerII});
        }
        function onCompleteHandlerII():void {
            m_fightUI.box_rush.visible = false;
            TweenLite.killTweensOf(m_fightUI.box_numrush);
            showHitLevel( num );
            schedule( 2 , _onRefreshTime );
        }
        m_fightUI.frameclip_rush_eff1.gotoAndPlay(0);
        m_fightUI.frameclip_rush_eff2.gotoAndPlay(0);
    }
    private function showHitLevel( num : int ):void{
        m_fightUI.clip_hitLevel.visible = true;
        if( num > 25 ){
            m_fightUI.clip_hitLevel.index = 5;
        }else if( num >= 20 ){
            m_fightUI.clip_hitLevel.index = 4;
        }else if( num >= 16 ){
            m_fightUI.clip_hitLevel.index = 3;
        }else if( num >= 11 ){
            m_fightUI.clip_hitLevel.index = 2;
        }else if( num >= 6 ){
            m_fightUI.clip_hitLevel.index = 1;
        }else if( num >= 2 ){
            m_fightUI.clip_hitLevel.index = 0;
        }else {
            m_fightUI.clip_hitLevel.visible = false;
        }
    }
    private function hideHitLevel():void{
        unschedule( _onRefreshTime );
        m_fightUI.clip_hitLevel.visible = false;
    }
    private function _onRefreshTime( delta : Number ):void{
        hideHitLevel();
    }

    private function rushNumEff( oldValue: int , newValue : int, clip : Clip, frameClip : FrameClip):void{
        if( oldValue == newValue){
            clip.index = newValue ;
            clip.visible = true;
            frameClip.stop();
            frameClip.visible = false;

        }else{
            clip.visible = false;
            frameClip.skin = "frameclip_SZ" + newValue;
            rushEffHandler( frameClip );
            frameClip.gotoAndPlay(0);
            frameClip.visible = true;
        }
    }
    private function rushEffHandler( frameClip : FrameClip):void{
        frameClip.addEventListener(UIEvent.FRAME_CHANGED,onRushEff);
        function onRushEff(evt:UIEvent):void{
            if( frameClip.frame >=  frameClip.totalFrame - 1) {
                frameClip.removeEventListener( UIEvent.FRAME_CHANGED, onRushEff );
                frameClip.stop();
            }
        }
    }
    private function _addEventListener():void{
        _removeEventListener();
        if(m_fightUI){
            m_fightUI.eff_criticakhit.addEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged, false, 0, true);
            m_fightUI.eff_counter.addEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged, false, 0, true);
            m_fightUI.eff_drivecancel.addEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged, false, 0, true);
            m_fightUI.eff_supercancel.addEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged, false, 0, true);
            m_fightUI.eff_quickstanding.addEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged, false, 0, true);
        }
    }
    private function _removeEventListener():void{
        if(m_fightUI){
            m_fightUI.eff_criticakhit.removeEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged);
            m_fightUI.eff_counter.removeEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged);
            m_fightUI.eff_drivecancel.removeEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged);
            m_fightUI.eff_supercancel.removeEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged);
            m_fightUI.eff_quickstanding.removeEventListener(UIEvent.FRAME_CHANGED,_onFrameChanged);
        }
    }
    private function  _resetHitEff():void{
        m_fightUI.box_criticakhit.visible =
                m_fightUI.box_counter.visible =
                        m_fightUI.box_drivecancel.visible =
                                m_fightUI.box_supercancel.visible =
                                        m_fightUI.box_quickstanding.visible =
                                                m_fightUI.box_rush.visible =
                                                        m_fightUI.clip_hitLevel.visible = false;
        m_fightUI.eff_criticakhit.gotoAndStop(0);
        m_fightUI.eff_counter.gotoAndStop(0);
        m_fightUI.eff_drivecancel.gotoAndStop(0);
        m_fightUI.eff_supercancel.gotoAndStop(0);
        m_fightUI.eff_quickstanding.gotoAndStop(0);
    }
    public function hide(removed:Boolean = true):void {
        TweenLite.killTweensOf(m_fightUI.box_numrush);
        _resetHitEff();
        _oldValue1 = _oldValue2 = _oldValue3 = 0;
        hideHitLevel();
    }
}
}
