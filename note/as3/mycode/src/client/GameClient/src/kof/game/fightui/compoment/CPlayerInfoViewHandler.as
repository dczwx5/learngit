//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/6/14.
 */
package kof.game.fightui.compoment {

import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.easing.Elastic;

import flash.events.Event;

import kof.framework.CViewHandler;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameObject;
import kof.game.fightui.CFightViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.peakGame.CPeakGameSystem;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.table.Monster;
import kof.ui.components.KOFProgressBarII;
import kof.ui.demo.FightLeftUI;
import kof.ui.demo.FightRightUI;
import kof.ui.demo.FightUI;
import kof.ui.imp_common.TypeCounterUI;

import morn.core.components.Box;
import morn.core.components.FrameClip;
import morn.core.components.ProgressBar;
import morn.core.components.View;
import morn.core.events.UIEvent;

public class CPlayerInfoViewHandler extends CViewHandler {

    private var _lastHP:int;
    private var _heroEventMediator : CEventMediator;
    private var _lastHpValue:Number;
    private var _reduceEffTimeline:TimelineLite;
    private var _x:int;
    private var _y:int;
    private var _pCharacterMediator : CCharacterFightTriggle;
    private var m_fightUI : FightUI;
    private var m_infoView : View;
    private var m_sideLeft : Boolean;
    private var m_pSelf:CGameObject;

    private var m_playerHeroData : CPlayerHeroData;

    public function CPlayerInfoViewHandler() {
        super();
    }
    public function setData( hero:CGameObject, fightUI : FightUI , view :View ,sideLeft :Boolean = true ) : void {
        hide();
        resetUI();

        if(!hero)
                return;
        m_pSelf = hero;
        m_fightUI = fightUI;
        m_infoView = view;
        m_sideLeft = sideLeft;

        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
        {
            _heroEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate);
            _heroEventMediator.removeEventListener(CCharacterEvent.STATE_VALUE_UPDATE, _onStateUpdate);
        }

        m_infoView['box_dan' ].visible = false;
//        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
//        if( pInstanceSystem && pInstanceSystem.instanceType == EInstanceType.TYPE_PEAK_GAME_FAIR ){
//            m_infoView['txt_dan' ].text = _peakGameSystem.manager.data.levelName;
//            m_infoView['box_dan' ].visible = true;
//        }else{
//            m_infoView['box_dan' ].visible = false;
//        }

        var property : ICharacterProperty = hero.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if( !property )
            return;
        updateBaseInfoHanlder( property );

        var hpValue:Number = int(( property.HP/property.MaxHP)*100)/100;
        m_infoView['hp'].value = hpValue;
        m_infoView['kofframeclippro_hp'].value = hpValue;
//        m_infoView['kofframeclippro_reduce'].value = hpValue;
        _redProgressBar.value = hpValue;
        m_nHpValue = hpValue;
        m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;

        var defenseValue:Number = int(( property.DefensePower/property.MaxDefensePower)*100)/100;
        _onUpdateDefView( defenseValue );

        var attValue:Number = int(( property.AttackPower/property.MaxAttackPower)*100)/100;
        TweenLite.killTweensOf(m_fightUI['atk'],true);
        TweenLite.to(m_fightUI['atk'],.5,{value:attValue});

        _pSkillViewHandler.setPlayerEnerey( property.AttackPower );


        _lastHpValue = hpValue;
        var pPlayerProperty : CPlayerProperty = hero.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        _heroEventMediator = pPlayerProperty.getComponent( CEventMediator ) as CEventMediator;
        if ( _heroEventMediator )
        {
            _heroEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );
            _heroEventMediator.addEventListener(CCharacterEvent.STATE_VALUE_UPDATE, _onStateUpdate, false, 0, true);
        }

        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning )
        {
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED ,_onCriticalHitEffHandler);
        }

        _pCharacterMediator = hero.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
        _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED,_onCriticalHitEffHandler, false, 0, true );

        m_infoView.visible = true;
//        m_infoView.visible = hpValue > 0;

        if( m_sideLeft ){

        }

    }
    private function updateBaseInfoHanlder( property : ICharacterProperty ):void{
        m_infoView['txt_name'].text = property.nickName ;
        m_infoView['img'].url = CPlayerPath.getUIHeroIconBigPath(property.prototypeID);

        m_playerHeroData = null;
        m_playerHeroData = _playerData.heroList.getHero( property.prototypeID );
        if( m_playerHeroData ){
            m_infoView['txt_roleName' ].text = m_playerHeroData.heroName;
            updateTypeEff();
            _pBossInfoViewHandler.updateTypeEff();
        }

    }
    private function _onPropertyUpdate(evt:CPropertyUpdateEvent):void {
        var owner:CGameObject = evt.owner;
        var property : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if( property )
            propertyChange(property);
    }

    private var m_bIsTargetInControl:Boolean;// 目标是否处于可控状态
    private function _onStateUpdate(e:Event):void
    {
        if(m_pSelf)
        {
            var stateBoard:CCharacterStateBoard = m_pSelf.getComponentByClass(CCharacterStateBoard, true) as CCharacterStateBoard;
            if(stateBoard)
            {
                if(stateBoard.isDirty(CCharacterStateBoard.IN_CONTROL))
                {
                    m_bIsTargetInControl = stateBoard.getValue(CCharacterStateBoard.IN_CONTROL);
                    _updateBlood();
                }
            }
        }
    }

    private function _updateBlood():void
    {
        if(m_bIsInBabody)// 霸体则跳过
        {
            return;
        }

        if(m_bIsTargetInControl)
        {
            if(TweenMax.isTweening(_redProgressBar))
            {
                TweenMax.killTweensOf(_redProgressBar);
            }

            TweenMax.fromTo(_redProgressBar, 0.8, {alpha:1}, {alpha:0, delay:0.3, onComplete:_onCompleteHandler});

            function _onCompleteHandler():void
            {
                _redProgressBar.value = m_nHpValue;
            }
        }
        else
        {
            if(TweenMax.isTweening(_redProgressBar))
            {
                TweenMax.killTweensOf(_redProgressBar);
                _redProgressBar.value = m_nHpValue;
            }

            _redProgressBar.alpha = 1;
        }
    }

    private var m_nHpValue:Number = 0;
    private var m_bIsInBabody:Boolean;// 是否霸体状态
    private function propertyChange(property:ICharacterProperty):void
    {
        if( m_infoView['txt_name'].text == ''){//todo
            updateBaseInfoHanlder( property );
        }

        var hpValue:Number = int(( property.HP/property.MaxHP)*100)/100;
        m_nHpValue = hpValue;

        TweenLite.killTweensOf(m_infoView['hp'],true);
        TweenLite.to(m_infoView['hp'], 0.5, {value:m_nHpValue});
        m_infoView['hp'].value = hpValue;
        m_infoView['kofframeclippro_hp'].value = hpValue;

        if(m_pSelf)
        {
            var stateBoard : CCharacterStateBoard = m_pSelf.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if ( stateBoard )
            {
                m_bIsInBabody = stateBoard.getValue( CCharacterStateBoard.PA_BODY);// 是否霸体
            }
        }

        // 可控状态时且非霸体时
        if(!_redProgressBar.alpha && !m_bIsInBabody)
        {
            if(!TweenMax.isTweening(_redProgressBar))
            {
                _redProgressBar.value = m_nHpValue;
            }
        }

        if(m_bIsInBabody)
        {
            if(TweenMax.isTweening(_redProgressBar))
            {
                TweenMax.killTweensOf(_redProgressBar);
            }

            _redProgressBar.alpha = 1;

            unschedule(_onSchedule);
            schedule(2, _onSchedule);
        }

        if( hpValue > 0 && m_infoView.visible == false )
        {
            m_infoView.visible = true;
        }

        if(_lastHpValue != property.HP)
        {
            if(_lastHpValue > property.HP)
            {
                reduceEff();
            }
            _lastHpValue = property.HP;
        }

        /*
        TweenLite.killTweensOf(m_infoView['kofframeclippro_reduce'],true);
        if ( m_infoView['kofframeclippro_reduce'].bar.stage )
            m_infoView['kofframeclippro_reduce'].bar.gotoAndPlay(0);
        TweenLite.to(m_infoView['kofframeclippro_reduce'],0.8,{value:hpValue});
        */

            m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;

        var defenseValue:Number = int(( property.DefensePower/property.MaxDefensePower)*100)/100;
        _onUpdateDefView( defenseValue );

        var attValue:Number = int(( property.AttackPower/property.MaxAttackPower)*100)/100;
        TweenLite.killTweensOf(m_fightUI['atk'],true);
        TweenLite.to(m_fightUI['atk'],.5,{value:attValue});

        _pSkillViewHandler.setPlayerEnerey( property.AttackPower );

    }

    private function _onSchedule(delta : Number):void
    {
        unschedule(_onSchedule);
        TweenMax.to(_redProgressBar, 0.8, {alpha:0, onComplete:_onCompleteHandler});

        function _onCompleteHandler():void
        {
            _redProgressBar.value = m_nHpValue;
        }
    }

    private function reduceEff():void
    {
        var width : int = Math.abs( m_infoView['hp'].scaleX ) * m_infoView['hp'].width;
        if( m_sideLeft )//要注意UI修改
        {
            m_infoView['box_reduceeff'].x = width - (1 - m_infoView['hp' ].value) * width - 10;
        }
        else
        {
            m_infoView['box_reduceeff'].x = (585 - width ) + (1 - m_infoView['hp' ].value) * width;
        }

        reduceEffHandler(  m_infoView['box_reduceeff'] ,m_infoView['reduceeff'] );
        reduceEffHandler(  m_infoView['box_reducerec'] ,m_infoView['reducerec']  );
        _stopTimeline();
        _x = m_infoView.x;
        _y = m_infoView.y;
        _reduceEffTimeline = new TimelineLite();
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x : _x + Math.random()*15,y:_y - Math.random()*15,ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x : _x - Math.random()*15,y:_y + Math.random()*15,ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x :_x,y:_y ,ease:Elastic.easeInOut,onComplete:onComplete}));

        function onComplete():void{
            _stopTimeline();
            if( m_infoView is FightRightUI )
                m_infoView.right = 0;
            else if( m_infoView is FightLeftUI )
                m_infoView.left = 0;
        }
    }

    private function _stopTimeline():void{
        if(_reduceEffTimeline){
            _reduceEffTimeline.stop();
            _reduceEffTimeline = null;
            m_infoView.x = _x;
            m_infoView.y = _y;
        }
    }
    private function _onCriticalHitEffHandler(evt:CFightTriggleEvent):void{
        reduceEffHandler(  m_infoView['box_redrec']  ,m_infoView['redrec']  );
    }
    private function reduceEffHandler( ctn: Box , frameClip : FrameClip):void{
        stopeff();
        frameClip.addEventListener( UIEvent.FRAME_CHANGED,onChanged );
        ctn.visible = true;
        frameClip.gotoAndPlay(0);
        function onChanged(evt:UIEvent):void{
            if( frameClip.frame >=  frameClip.totalFrame - 1) {
                stopeff();
            }
        }
        function stopeff():void{
            frameClip.removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
            frameClip.stop();
            ctn.visible = false;
        }
    }
    private function _onUpdateDefView( defenseValue:Number ):void{

        if( defenseValue <= 0 ){
            m_infoView['list_def' ].dataSource = [];
        }else if( defenseValue <= 0.12 ){
            m_infoView['list_def' ].dataSource = [''];
        }else if( defenseValue <= 0.24 ){
            m_infoView['list_def' ].dataSource = ['',''];
        }else if( defenseValue <= 0.36 ){
            m_infoView['list_def' ].dataSource = ['','',''];
        }else if( defenseValue <= 0.48 ){
            m_infoView['list_def' ].dataSource = ['','','',''];
        }else if( defenseValue <= 0.60 ){
            m_infoView['list_def' ].dataSource = ['','','','',''];
        }else if( defenseValue <= 0.72 ){
            m_infoView['list_def' ].dataSource = ['','','','','',''];
        }else if( defenseValue <= 0.84 ){
            m_infoView['list_def' ].dataSource = ['','','','','','',''];
        }else{
            m_infoView['list_def' ].dataSource = ['','','','','','','',''];
        }

    }
    public function resetUI():void{
        if( !m_infoView )
                return;
        m_infoView['box_reduceeff'].visible =
                m_infoView['box_redrec'].visible =
                        m_infoView['box_reducerec'].visible = false;
        m_infoView['txt_roleName' ].text =
                m_infoView['txt_name'].text = '';
        if( m_infoView['hp' ] is KOFProgressBarII ){
            m_infoView['hp' ].index = 0;
            if( m_infoView['box_bloodCount'] )
                m_infoView['box_bloodCount' ].visible = false;
            if( m_infoView['clip_bloodbg'] )
                m_infoView['clip_bloodbg' ].visible = false;
        }
        if( m_infoView.hasOwnProperty('img_boss_bz') ){
            m_infoView['img_boss_bz'].visible = false;
        }
        m_infoView['hp'].value = 1;
        m_infoView['kofframeclippro_hp'].value = 1;
//        m_infoView['kofframeclippro_reduce'].value = 1;
        _redProgressBar.value = 1;
        m_nHpValue = 1;

        m_bIsTargetInControl = false;
        m_bIsInBabody = false;
        m_nHpValue = 0;
    }
    public function stopEff():void{
        m_infoView['box_reduceeff'].visible =
                m_infoView['box_redrec'].visible =
                        m_infoView['box_reducerec'].visible = false;
    }
    public function hide(removed:Boolean = true):void {
        if( m_infoView ){
            TweenLite.killTweensOf(m_infoView['hp'],true);
            TweenLite.killTweensOf(m_fightUI['atk'],true);
//            TweenLite.killTweensOf(m_infoView['kofframeclippro_reduce'],true);
            TweenMax.killTweensOf(_redProgressBar);
        }

//        resetUI();
        _stopTimeline();

//        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
//            _heroEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate);
//        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning )
//            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED ,_onCriticalHitEffHandler);
    }

    public function updateTypeEff( ):void {
        if( null == m_infoView )
            return;
        m_infoView[ 'box_typeEff'].visible = false;
        if( null == m_playerHeroData )
            return;
//        m_infoView[ 'box_typeEff'].visible = true; //策划暂时隐藏

//        ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).clip_career.index = m_playerHeroData.job;
//        if( _pBossInfoViewHandler.heroData ){
//            var job : int;
//            if( _pBossInfoViewHandler.heroData is CPlayerHeroData ){
//                job = ( _pBossInfoViewHandler.heroData as CPlayerHeroData).job;
//            }else if( _pBossInfoViewHandler.heroData is Monster ){
//                job = ( _pBossInfoViewHandler.heroData as Monster).Profession;
//            }
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_up.visible = getJobEx( m_playerHeroData.job, job ) == 1;
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_down.visible = getJobEx( m_playerHeroData.job, job ) == -1;
//        }else{
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_up.visible = false;
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_down.visible = false;
//        }
    }

    private function getJobEx( job1 : int , job2 : int ):int{
        if( job1 == job2 )
            return 0;
        if( job1 == 0 ){
            if( job2 == 1 )
                return 1;
            else
                return -1;
        }else if( job1 == 1 ){
            if( job2 == 2 )
                return 1;
            else
                return -1;
        }else if( job1 == 2 ){
            if( job2 == 0 )
                return 1;
            else
                return -1;
        }
        return 0;
    }

    public function get playerHeroData():CPlayerHeroData{
        return m_playerHeroData;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _peakGameSystem() : CPeakGameSystem {
        return system.stage.getSystem( CPeakGameSystem ) as CPeakGameSystem;
    }
    private function get _pBossInfoViewHandler() : CBossInfoViewHandler{
        return system.getBean( CFightViewHandler ).getBean( CBossInfoViewHandler ) as CBossInfoViewHandler;
    }
    private function get _pSkillViewHandler() : CSkillViewHandler{
        return system.getBean( CFightViewHandler ).getBean( CSkillViewHandler ) as CSkillViewHandler;
    }

    private function get _redProgressBar():ProgressBar
    {
        return m_infoView["progress_redBar"] as ProgressBar;
    }
}
}
