//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/6/14.
 */
package kof.game.fightui.compoment {

import QFLib.Graphics.RenderCore.starling.utils.WeakRef;

import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.TweenMax;
import com.greensock.TweenMax;
import com.greensock.easing.Elastic;

import flash.events.Event;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CFacadeMediator;
import kof.game.character.CTarget;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.common.CTest;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.fightui.CFightViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.scene.CSceneSystem;
import kof.table.Monster;
import kof.table.Monster.EMonsterType;
import kof.table.PracticeOpponent;
import kof.ui.components.KOFFrameClipProgressBar;
import kof.ui.components.KOFNum;
import kof.ui.components.KOFProgressBarII;
import kof.ui.demo.FightLeftUI;
import kof.ui.demo.FightRightUI;

import morn.core.components.Box;
import morn.core.components.FrameClip;
import morn.core.components.ProgressBar;
import morn.core.components.View;
import morn.core.events.UIEvent;

public class CBossInfoViewHandler extends CViewHandler {

    private var pTarget : CTarget;
    private var _heroEventMediator : CEventMediator;
    private var _targetEventMediator : CEventMediator;
    private var _lastHpValue : int;
    private var m_iLastBloodCount:int;
    private var _defaultTarget:WeakRef;
    private var _reduceEffTimeline:TimelineLite;
    private var _x:int;
    private var _y:int;
    private var _pCharacterMediator : CCharacterFightTriggle;
    private var m_infoView : View;
    private var m_sideLeft : Boolean;
    private var m_bloodnumberFlg : Boolean;//boss的血条是否需要分管显示
    private var m_bloodTotalNum : int;//总共分多少管血
    private var m_bloodValue : int;//每一管血的血量
    private var m_hero : CGameObject;
    private var m_heroData : * ;//CPlayerHeroData 或者 Monster

    public function CBossInfoViewHandler() {
        super();
    }
    public function setData( hero : CGameObject , view :View ,sideLeft :Boolean = true) : void {
        hide();
        if( !hero)
            return;
        m_hero = hero;
        m_infoView = view;
        m_sideLeft = sideLeft;
        m_infoView.visible = false;
        m_heroData = null;
        _playerInfoViewHandler.updateTypeEff();
        if( m_infoView.hasOwnProperty('img_boss_bz') ){
            m_infoView['img_boss_bz' ].visible = false;
            m_infoView['box_bloodCount' ].visible = false;
            m_infoView['hp' ].index = 0;
        }
        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
            _heroEventMediator.removeEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
        pTarget  = hero.getComponentByClass( CTarget, true ) as CTarget;
        _heroEventMediator = pTarget.getComponent( CEventMediator ) as CEventMediator;
        if ( _heroEventMediator )
            _heroEventMediator.addEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
        _onTargetUpdate( null );

        _onQEchange();


    }
    private function _onTargetUpdate(evt:Event):void {
        var target : CGameObject = pTarget.targetObject;

//        if( getGameObjectType( target ) == EMonsterType.NORMAL ){//如果是普通小怪，不更新血条
//            return;
//        }
        //金币副本与经验副本类型的关卡，不显示小怪血条
        m_infoView['box_dan' ].visible = false;
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
//        if( pInstanceSystem && pInstanceSystem.instanceType == EInstanceType.TYPE_PEAK_GAME_FAIR ){
//            m_infoView['box_dan' ].visible = true;
//        }else{
//            m_infoView['box_dan' ].visible = false;
//        }

        if ( pInstanceSystem && ( pInstanceSystem.instanceType == EInstanceType.TYPE_GOLD_INSTANCE ||
                pInstanceSystem.instanceType == EInstanceType.TYPE_TRAIN_INSTANCE ) ) {
             return;
        }

        if( getGameObjectStyle( target ) == 1){//如果是可破坏物件，不更新血条
            return;
        }

        var pLevelMediator : CLevelMediator = m_hero.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
         if( pLevelMediator && !pLevelMediator.isAttackable( target ))
                 return;



        updateHanlder( target );
        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning )
            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED ,_onCriticalHitEffHandler);
        if( target ){
            _pCharacterMediator = target.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
            _pCharacterMediator.addEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED,_onCriticalHitEffHandler, false, 0, true );
        }
    }

    private function updateHanlder(target : CGameObject ):void{
//        if( getGameObjectType( target ) == EMonsterType.NORMAL ){//如果是普通小怪，不更新血条
//            return;
//        }
        //金币副本与经验副本类型的关卡，不显示小怪血条
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if ( pInstanceSystem && ( pInstanceSystem.instanceType == EInstanceType.TYPE_GOLD_INSTANCE ||
                pInstanceSystem.instanceType == EInstanceType.TYPE_TRAIN_INSTANCE ) ) {
            return;
        }
        if( getGameObjectStyle( target ) == 1){//如果是可破坏物件，不更新血条
            return;
        }
        hide();
        resetUI();
        if( _targetEventMediator && _targetEventMediator.owner && _targetEventMediator.owner.isRunning )
        {
            _targetEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyUpdate);
            _targetEventMediator.removeEventListener(CCharacterEvent.STATE_VALUE_UPDATE, _onStateUpdate);
        }

        if(!target){
            resetUI();
            defaultData();
            m_infoView.visible = false;
            m_heroData = null;
            _playerInfoViewHandler.updateTypeEff();
            return;
        }

        if( m_infoView.hasOwnProperty('img_boss_bz') ){
            m_infoView['img_boss_bz' ].visible = getGameObjectType( target ) == EMonsterType.BOSS || getGameObjectType( target ) == EMonsterType.WORLD_BOSS;
        }
        var property : ICharacterProperty = target.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        var pFacadeMediator : CFacadeMediator = target.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;
//        if( pFacadeMediator ){
//            var pMonsterProperty : CMonsterProperty = pFacadeMediator.getComponent( CMonsterProperty ) as CMonsterProperty;
//            if( pMonsterProperty )  //打中小怪不显示大血条
//                pMonsterProperty.monsterType == EMonsterType.NORMAL ? m_infoView.visible = false : m_infoView.visible = true;
//            else
//                m_infoView.visible = true;
//        }
        m_infoView.visible = true;
        m_bloodnumberFlg = false;
        m_heroData = null;
        if (pFacadeMediator && pFacadeMediator.isMonster) {
            var monster : Monster = _tableMonster.findByPrimaryKey( property.prototypeID );
            m_infoView['img'].url = monster.headicon + '.png';
            m_infoView['txt_roleName' ].text = monster.Name;
            m_infoView['txt_name'].text = monster.title;
            m_heroData = monster;
            updateTypeEff();
            _playerInfoViewHandler.updateTypeEff();

            m_bloodnumberFlg = monster.Bloodnumber > 1;
            if( m_bloodnumberFlg ){
                m_bloodTotalNum = monster.Bloodnumber;
                m_bloodValue = Math.floor( property.MaxHP / m_bloodTotalNum );
            }


        }else if(pFacadeMediator && pFacadeMediator.isPlayer){

            m_infoView['img'].url = CPlayerPath.getUIHeroIconBigPath(property.prototypeID);
            var playerHeroData : CPlayerHeroData = _playerData.heroList.getHero( property.prototypeID );
            m_infoView['txt_roleName' ].text = playerHeroData.heroName;
            m_heroData = playerHeroData;
            updateTypeEff();
            _playerInfoViewHandler.updateTypeEff();

            var pInstanceSys:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            var isPractice:Boolean;
            if ( pInstanceSys ) {
                isPractice = EInstanceType.isPractice( pInstanceSys.instanceType );
            }
            if( isPractice ){//练习场例外
                var practiceOpponent : PracticeOpponent = getPracticeOpponentByID( property.prototypeID );
                m_infoView['txt_name'].text = practiceOpponent.Title;
            }else{
                m_infoView['txt_name'].text = property.nickName;
            }
        }
        var hpValue:Number;
        if( m_bloodnumberFlg ){
            var bloodCount : int = getBloodCount( property.HP );
//            m_iLastBloodCount = bloodCount;
            m_infoView['hp' ].index = getBloodIndex( bloodCount );
            if( property.HP <= 0 ){
                m_infoView['box_bloodCount' ].visible = false;
                m_infoView['clip_bloodbg'].visible = false;
                hpValue = 0;
            }else {
                m_infoView['box_bloodCount' ].visible = m_bloodTotalNum - bloodCount + 1 > 1;
                if( m_infoView['box_bloodCount' ].visible )
                    m_infoView['kofnum_bloodCount' ].num = m_bloodTotalNum - bloodCount + 1;

                m_infoView['clip_bloodbg'].visible = bloodCount < m_bloodTotalNum ;
                if( m_infoView['clip_bloodbg'].visible )
                    m_infoView['clip_bloodbg'].index = getBloodIndex( bloodCount  + 1 );

                hpValue = int(( ( property.HP - m_bloodValue * ( m_bloodTotalNum - bloodCount ) )/m_bloodValue)*100)/100;
            }

        }else{
            hpValue = int(( property.HP/property.MaxHP)*100)/100;
        }

        m_infoView['hp'].value = hpValue;
        m_infoView['kofframeclippro_hp'].value = hpValue;
        _redProgressBar.value = hpValue;
        m_nHpValue = hpValue;
//        _frameClipBar.value = hpValue;
//        _frameClipBar.bar.autoPlay = false;
//        _frameClipBar.bar.frame = 0;
//        _frameClipBar.bar.alpha = 1;
//        _frameClipBar.alpha = 1;



        _lastHpValue = property.HP;
        m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;

        m_infoView.visible = true;
        if( CCharacterDataDescriptor.isMonster( target.data ) && getGameObjectType( target ) == EMonsterType.NORMAL )
            m_infoView.visible = property.HP > 0;

        if( property.HP <= 0 )
            showNextBossHPView();


        var defenseValue:Number = int(( property.DefensePower/property.MaxDefensePower)*100)/100;
        _onUpdateDefView( defenseValue );

        _targetEventMediator = property.getComponent( CEventMediator ) as CEventMediator;
        if ( _targetEventMediator )
        {
            _targetEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );
            _targetEventMediator.addEventListener(CCharacterEvent.STATE_VALUE_UPDATE,_onStateUpdate, false, 0, true );

        }
    }

    private function _onPropertyUpdate(evt:CPropertyUpdateEvent ):void {
        var owner:CGameObject = evt.owner;
        var property : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if( property )
            propertyChange( owner , property );
    }

    private var m_bIsTargetInControl:Boolean;// 目标是否处于可控状态
    private function _onStateUpdate(e:Event):void
    {
        var owner:CGameObject = pTarget.targetObject;
        if(owner)
        {
            var stateBoard:CCharacterStateBoard = owner.getComponentByClass(CCharacterStateBoard, true) as CCharacterStateBoard;
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
    private var m_iTargetBloodCount:int;
    private var m_bIsInBloodTween:Boolean;
    private var m_bIsInBabody:Boolean;// 是否霸体状态
    private function propertyChange( target:CGameObject , property:ICharacterProperty):void
    {
        if(_lastHpValue == property.HP)
        {
            return;
        }

        if( m_bloodnumberFlg )// 多管血
        {
            if( property.HP <= 0 )// 血量为0时特殊处理
            {
                m_nHpValue = 0;
                m_iTargetBloodCount = getBloodCount( property.HP );
                m_iLastBloodCount = m_iTargetBloodCount;

                m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;
                TweenMax.killTweensOf(m_infoView['hp']);
                m_infoView['hp' ].value = m_nHpValue;// 真实血条
                m_infoView['kofframeclippro_hp'].value = m_nHpValue;// 血条上的水波特效

                m_infoView['box_bloodCount' ].visible = false;// 血管数
                m_infoView['clip_bloodbg'].visible = false;// 背景血条

                m_bIsInBloodTween = false;

                return;
            }

            if(m_bIsInBloodTween)
            {
                return;
            }

            var bloodCount : int = getBloodCount( property.HP );// 达到第几管血
            m_iTargetBloodCount = bloodCount;
            if(m_iLastBloodCount == 0)
            {
                m_iLastBloodCount = m_iTargetBloodCount;
            }

            m_infoView['hp' ].index = getBloodIndex( bloodCount );

            if( property.HP <= 0 )
            {
                m_infoView[ 'box_bloodCount' ].visible = false;
                m_infoView['clip_bloodbg'].visible = false;
                m_nHpValue = 0;
            }
            else
            {
                /*
                if(m_iLastBloodCount == m_iTargetBloodCount)
                {
                    m_infoView['box_bloodCount' ].visible = m_bloodTotalNum - bloodCount + 1 > 1;
                    if( m_infoView['box_bloodCount' ].visible )
                    {
                        m_infoView['kofnum_bloodCount' ].num = m_bloodTotalNum - bloodCount + 1;
                    }

                    m_infoView['clip_bloodbg'].visible = bloodCount < m_bloodTotalNum ;
                    if( m_infoView['clip_bloodbg'].visible )
                    {
                        m_infoView['clip_bloodbg'].index = getBloodIndex( bloodCount  + 1 );
                    }
                }
                */

                m_nHpValue = int(( ( property.HP - m_bloodValue * ( m_bloodTotalNum - bloodCount ) )/m_bloodValue)*100)/100;
            }

            if(m_iLastBloodCount < m_iTargetBloodCount)// 一次打掉>=1管血
            {
                m_iLastBloodCount += 1;
                m_bIsInBloodTween = true;
                TweenMax.to(m_infoView['hp'], 0.3, {value:0, onComplete:_onBloodTweenEnd, onCompleteParams:[m_iLastBloodCount]});
                m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;
            }
            else
            {
                m_bIsInBloodTween = false;
                m_iLastBloodCount = m_iTargetBloodCount;
            }
        }
        else
        {
            m_nHpValue = int(( property.HP/property.MaxHP)*100)/100;
        }

        if(m_bIsInBloodTween)
        {
            return;
        }

        if(TweenMax.isTweening(m_infoView['hp']))
        {
            TweenMax.killTweensOf(m_infoView['hp']);
        }

        TweenMax.to(m_infoView['hp'], 0.5, {value:m_nHpValue});

        var owner:CGameObject = pTarget.targetObject;
        if(owner)
        {
            var pStatBoard : CCharacterStateBoard = target.getComponentByClass( CCharacterStateBoard , true ) as CCharacterStateBoard;
            m_bIsInBabody = pStatBoard.getValue( CCharacterStateBoard.PA_BODY);// 是否霸体
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

        m_infoView['kofframeclippro_hp'].value = m_nHpValue;
        m_infoView['txt_hp'].text = property.HP + "/" + property.MaxHP;

        if(_lastHpValue != property.HP)
        {
            if(_lastHpValue > property.HP)
            {
                reduceEff();
            }
            _lastHpValue = property.HP;
        }

        m_infoView.visible = true;
        if( CCharacterDataDescriptor.isMonster( target.data ) && getGameObjectType( target ) == EMonsterType.NORMAL )
            m_infoView.visible = property.HP > 0;

        if( property.HP <= 0 )
            showNextBossHPView();

        var defenseValue:Number = int(( property.DefensePower/property.MaxDefensePower)*100)/100;
        _onUpdateDefView( defenseValue );
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

    /**
     * 从第m管血的起点位置缓动到第n管血的终点位置
     * @param bloodCount 当前缓动的那管血
     */
    private function _onBloodTweenEnd(bloodCount:int):void
    {
        m_infoView['hp'].index = getBloodIndex( bloodCount );

        var box_bloodCount:Box = m_infoView['box_bloodCount'] as Box;
        box_bloodCount.visible = m_bloodTotalNum - bloodCount + 1 > 1;
        if( box_bloodCount.visible )
        {
            var kofnum_bloodCount:KOFNum = m_infoView['kofnum_bloodCount'] as KOFNum;
            var num:int = m_bloodTotalNum - bloodCount + 1;
            kofnum_bloodCount.num = num;

            if(num >= 100)
            {
                box_bloodCount.x = 528;
            }
            else if(num >= 10)
            {
                box_bloodCount.x = 536;
            }
            else
            {
                box_bloodCount.x = 546;
            }
        }

        m_infoView['clip_bloodbg'].visible = bloodCount < m_bloodTotalNum ;
        if( m_infoView['clip_bloodbg'].visible )
        {
            m_infoView['clip_bloodbg'].index = getBloodIndex( bloodCount  + 1 );
        }

        if(m_iLastBloodCount < m_iTargetBloodCount)
        {
            m_iLastBloodCount += 1;
            TweenMax.fromTo(m_infoView['hp'], 0.3,{value:1}, {value:0, onComplete:_onBloodTweenEnd, onCompleteParams:[m_iLastBloodCount]});
        }
        else
        {
            m_iLastBloodCount = m_iTargetBloodCount;
            TweenMax.fromTo(m_infoView['hp'], 0.3,{value:1}, {value:m_nHpValue, onComplete:onCompleteHandler});

            function onCompleteHandler():void
            {
                m_bIsInBloodTween = false;

                if(m_nHpValue <= 0)
                {
                    m_infoView['hp' ].value = m_nHpValue;
                    var kofnum_bloodCount:KOFNum = m_infoView['kofnum_bloodCount'] as KOFNum;
                    var num:int = m_bloodTotalNum - bloodCount + 1;
                    kofnum_bloodCount.num = num;
                    box_bloodCount.visible = false;
                    m_infoView['clip_bloodbg'].visible = false;
                }
            }
        }
    }

    private function reduceEff():void{
        var width : int = Math.abs( m_infoView['hp'].scaleX ) * m_infoView['hp'].width;
        if( m_sideLeft )//要注意UI修改
            m_infoView['box_reduceeff'].x = (585 - width ) + (1- m_infoView['hp'].value )*width;
        else
            m_infoView['box_reduceeff'].x = 560 - (1- m_infoView['hp'].value )*width;
        reduceEffHandler(  m_infoView['box_reduceeff'] ,m_infoView['reduceeff'] );
        reduceEffHandler(  m_infoView['box_reducerec']  ,m_infoView['reducerec']  );
        _stopTimeline();
        _x = m_infoView.x;
        _y = m_infoView.y;
        _reduceEffTimeline = new TimelineLite();//Elastic
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x : _x - Math.random()*15,y:_y - Math.random()*15,ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x : _x + Math.random()*15,y:_y + Math.random()*15,ease:Elastic.easeInOut}));
        _reduceEffTimeline.append(TweenLite.to(m_infoView, .1,{x :_x,y:_y ,ease:Elastic.easeInOut,onComplete:onComplete}));
        function onComplete():void{
            _stopTimeline();
            if( m_infoView is FightRightUI )
                m_infoView.right = 0;
            else if( m_infoView is FightLeftUI )
                m_infoView.left = 0;
        }
    }
    public function defaultData():void{
        if(_defaultTarget)
            updateHanlder( _defaultTarget.get() );
    }
    public function onBossAppear( target : CGameObject ):void{
        _defaultTarget = new WeakRef(target);
        updateHanlder( target );
    }
    public function resetUI():void
    {
        if( !m_infoView )
        {
            return;
        }

        m_infoView['txt_name'].text = "";
        m_infoView['txt_hp'].text = "";
        m_infoView['img'].url = "";
        m_infoView['txt_roleName' ].text = "";
//        _frameClipBar.value = m_infoView['hp'].value = 1;
        _redProgressBar.value = 1;
        m_nHpValue = 1;
        m_infoView['hp'].value = 1;
        m_infoView['kofframeclippro_hp'].value = 1;
        m_infoView['list_def' ].dataSource = ['','','','','','','',''];
        m_infoView['box_reduceeff'].visible = false;
        m_infoView['box_redrec'].visible = false;
        m_infoView['box_reducerec'].visible = false;

        if( m_infoView['hp' ] is KOFProgressBarII )
        {
            m_infoView['hp' ].index = 0;
            if( m_infoView['box_bloodCount'] )
            {
                m_infoView['box_bloodCount' ].visible = false;
            }

            if( m_infoView['clip_bloodbg'] )
            {
                m_infoView['clip_bloodbg' ].visible = false;
            }
        }

        if( m_infoView.hasOwnProperty('img_boss_bz') )
        {
            m_infoView['img_boss_bz' ].visible = false;
            m_infoView['box_bloodCount' ].visible = false;
            m_infoView['hp' ].index = 0;
        }

        m_bIsInBloodTween = false;
        m_bIsTargetInControl = false;
        m_bIsInBabody = false;
        m_iLastBloodCount = 0;
        m_iTargetBloodCount = 0;
    }

    public function stopEff():void
    {
        m_infoView['box_reduceeff'].visible = false;
        m_infoView['box_redrec'].visible = false;
        m_infoView['box_reducerec'].visible = false;
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
        frameClip.addEventListener(UIEvent.FRAME_CHANGED,onChanged);
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

    private function _onQEchange():void{
        if (!_pCInstanceSystem) {
            return ;
        }
        var isPVE:Boolean = EInstanceType.isPVE(_pCInstanceSystem.instanceType);
        if (!isPVE) return ;
        showNextBossHPView();
    }

    //如果目标被打死 切换到下一个没有死的boss,精英怪,或者玩家对手
    private function showNextBossHPView():void{

        var pHero:CGameObject  = _playHandler.hero;
        var pSceneObject:CGameObject;
        var property : ICharacterProperty;

        var selfSide : int ;
        m_sideLeft ?  selfSide = 1 : selfSide = 2 ;

//        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
//        if ( pInstanceSystem ) {
//            var isPeak:Boolean = EInstanceType.isPeakGame( pInstanceSystem.instanceType );
//        }

        if (pHero && pHero.isRunning) {
            var targetList:Vector.<CGameObject> = new <CGameObject>[];
            var allGameObj:Array = _pCSceneSystem.allGameObjectIterator as Array;
            var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            var isPVE:Boolean;
            if ( pInstanceSystem ) {
                isPVE = EInstanceType.isPVE( pInstanceSystem.instanceType );
            }
            if( isPVE ){
                for each( pSceneObject in allGameObj){
                    if ( ( CCharacterDataDescriptor.isMonster( pSceneObject.data ) && getGameObjectType( pSceneObject ) != EMonsterType.NORMAL )
                            || CCharacterDataDescriptor.isRobot( pSceneObject.data ) ) {
                        property = pSceneObject.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                        if( property.HP > 0 )
                            targetList.push(pSceneObject);
                    }
                }
            }else{
                for each( pSceneObject in allGameObj){
                    if ( !CCharacterDataDescriptor.isHero( pSceneObject.data ) && CCharacterDataDescriptor.isPlayer( pSceneObject.data ) && pSceneObject.data.side != selfSide ) {
                        property = pSceneObject.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                        if( property.HP > 0 )
                            targetList.push(pSceneObject);
                    }
                }
            }

            if( targetList.length )
                (pHero.getComponentByClass(CTarget,true) as CTarget).setTargetObjects(targetList);
        }

    }
    private function getGameObjectType( gameObject : CGameObject):int{
        if( !gameObject )
                return 0;
        var pFacadeMediator : CFacadeMediator = gameObject.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;
        if( pFacadeMediator ){
            var pMonsterProperty : CMonsterProperty = pFacadeMediator.getComponent( CMonsterProperty ) as CMonsterProperty;
            if( pMonsterProperty )
                return pMonsterProperty.monsterType;
            else
                return 1;//todo 弄清楚为什么这个时候没有取到  pMonsterProperty
        }
        return 0;
    }
    private function getGameObjectStyle( gameObject : CGameObject):int{
        if( !gameObject )
                return -1;
        var pFacadeMediator : CFacadeMediator = gameObject.getComponentByClass(CFacadeMediator, true) as CFacadeMediator;
        if( pFacadeMediator ){
            var pMonsterProperty : CMonsterProperty = pFacadeMediator.getComponent( CMonsterProperty ) as CMonsterProperty;
            if( pMonsterProperty )
                return pMonsterProperty.style;
            else
                return -1;
        }
        return -1;
    }
    //第几管血
    private function getBloodCount( hp : int  ):int{
        var count : int;
        var index : int ;
        for( index = m_bloodTotalNum ; index >= 0 ; index-- ){
            if( hp >= m_bloodValue * index ) {
                count = m_bloodTotalNum - index;
                break;
            }
        }
        if( count == 0 )
            count = 1;
        return count;
    }
    //血条clip的index
    private function getBloodIndex( bloodCount : int  ):int{
        var index : int  = bloodCount % 5 - 1;
        if( index < 0 )
            index = 4;
        return index;
    }

    public function hide(removed:Boolean = true):void
    {
        if( m_infoView)
        {
            TweenLite.killTweensOf(m_infoView['hp'], true);
//            TweenMax.killTweensOf(_frameClipBar);
            TweenMax.killTweensOf(_redProgressBar);
        }

        _stopTimeline();
        _defaultTarget = null;

        m_bIsInBloodTween = false;
        m_bIsTargetInControl = false;
        m_bIsInBabody = false;
        m_iLastBloodCount = 0;
        m_iTargetBloodCount = 0;

//        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
//            _heroEventMediator.removeEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
//        if( _pCharacterMediator && _pCharacterMediator.owner && _pCharacterMediator.owner.isRunning )
//            _pCharacterMediator.removeEventListener(CFightTriggleEvent.EVT_BEING_CRITICALHITTED ,_onCriticalHitEffHandler);
//        if( _targetEventMediator && _targetEventMediator.owner && _targetEventMediator.owner.isRunning )
//            _targetEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyUpdate);
    }
    private function getPracticeOpponentByID( ID : int ) : PracticeOpponent{
        var ary : Array = _tablePractice.toArray();
        var practiceOpponent : PracticeOpponent;
        for each( practiceOpponent in ary ){
            if( ID == practiceOpponent.PlayerBasicID ){
                return practiceOpponent;
                break;
            }
        }
        return null;
    }
    public function updateTypeEff( ):void {
        if( null == m_infoView )
            return;
        m_infoView['box_typeEff'].visible = false;
        if( null == m_heroData )
                return;
//        m_infoView[ 'box_typeEff'].visible = true;  //策划暂时隐藏

        var job : int;
            if( m_heroData is CPlayerHeroData ){
            job = ( m_heroData as CPlayerHeroData).job;
        }else if( m_heroData is Monster ){
            job = ( m_heroData as Monster).Profession;
        }
//        ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).clip_career.index = job;
//        if( _playerInfoViewHandler.playerHeroData ){
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_up.visible = getJobEx( job, _playerInfoViewHandler.playerHeroData.job ) == 1;
//            ( m_infoView[ 'box_typeEff'] as TypeCounterUI ).frameClip_down.visible = getJobEx(job, _playerInfoViewHandler.playerHeroData.job ) == -1;
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
    public function get heroData():*{
        return m_heroData;
    }
    private function get _databaseSystem():CDatabaseSystem {
        return  system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _pCECSLoop():CECSLoop {
        return  system.stage.getSystem(CECSLoop) as CECSLoop;
    }
    private function get _pCSceneSystem():CSceneSystem {
        return  system.stage.getSystem(CSceneSystem) as CSceneSystem;
    }
    private function get _pCInstanceSystem():CInstanceSystem {
        return  system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
    private function get _playHandler():CPlayHandler {
        return  _pCECSLoop.getBean(CPlayHandler) as CPlayHandler;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _tableMonster():IDataTable{
        return _databaseSystem.getTable( KOFTableConstants.MONSTER );
    }
    private function get _tablePractice():IDataTable{
        return _databaseSystem.getTable( KOFTableConstants.PRACTICE );
    }
    private function get _playerInfoViewHandler() : CPlayerInfoViewHandler{
        return system.getBean( CFightViewHandler ).getBean( CPlayerInfoViewHandler ) as CPlayerInfoViewHandler;
    }

//    private function get _frameClipBar():KOFFrameClipProgressBar
//    {
//        return m_infoView['kofframeclippro_reduce'] as KOFFrameClipProgressBar;
//    }

    private function get _progressBar():KOFProgressBarII
    {
        return m_infoView["hp"] as KOFProgressBarII;
    }

    private function get _redProgressBar():ProgressBar
    {
        return m_infoView["progress_redBar"] as ProgressBar;
    }
}
}
