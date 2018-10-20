//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/14.
 *
 * 拳皇大赛里面对方格斗家的怒气条
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import flash.events.Event;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.CTarget;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.demo.FightUI;

import morn.core.components.View;

import morn.core.events.UIEvent;

public class COtherSideEnereyViewHandler extends CViewHandler {
    private var m_fightUI:FightUI;
    private var _heroEventMediator : CEventMediator;
    private var _targetEventMediator : CEventMediator;
    private var _hero:CGameObject;

    private var pTarget : CTarget;

    private var m_enereyView : View;

    public function COtherSideEnereyViewHandler($fightUI:FightUI = null) {
        super();
        if($fightUI){
            m_fightUI = $fightUI;
            resetUI();
        }
    }
    private function resetUI():void{
        if( !m_enereyView )
                return;
        m_enereyView['eff_1'].visible =
                m_enereyView['eff_2'].visible =
                        m_enereyView['eff_3'].visible =
                                m_enereyView['eff_energy'].visible = false;
        m_enereyView['pro_energy'].value = 0;
    }
    public function setData(hero:CGameObject,view :View):void {
        hide();
        if(!m_fightUI ||  !hero)
            return;
        m_enereyView = view;
        resetUI();
        var pInstanceSystem:CInstanceSystem = system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if ( pInstanceSystem ) {
            var isPeak:Boolean = EInstanceType.isClassicalMode( pInstanceSystem.instanceType ) || EInstanceType.isPeak1v1( pInstanceSystem.instanceType )
                    || EInstanceType.isClubBoss( pInstanceSystem.instanceType ) || EInstanceType.isGuildWar( pInstanceSystem.instanceType)
                    || EInstanceType.isStreetFighter( pInstanceSystem.instanceType);
            m_enereyView.visible = isPeak;
            if( !isPeak )
                    return;
        }
        resetUI();

        _hero = hero;
        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
            _heroEventMediator.removeEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
        pTarget  = hero.getComponentByClass( CTarget, true ) as CTarget;
        _heroEventMediator = pTarget.getComponent( CEventMediator ) as CEventMediator;
        if ( _heroEventMediator )
            _heroEventMediator.addEventListener(CCharacterEvent.TARGET_CHANGED ,_onTargetUpdate);
        _onTargetUpdate( null );
    }

    private function _onTargetUpdate(evt:Event):void {
        var target : CGameObject = pTarget.targetObject;
        updateHanlder( target );
    }
    private function updateHanlder(target : CGameObject ):void{

        if(!target)
                return;

        if( _targetEventMediator && _targetEventMediator.owner && _targetEventMediator.owner.isRunning )
            _targetEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE, _onPropertyUpdate);

        var property : ICharacterProperty = target.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        _targetEventMediator = property.getComponent( CEventMediator ) as CEventMediator;
        if ( _targetEventMediator )
            _targetEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );

        propertyChange(property);
    }


    private function _onPropertyUpdate(evt:CPropertyUpdateEvent):void {
        var owner:CGameObject = evt.owner;
        var property : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        propertyChange(property);
    }
    private  var _lastEnNum:int;
    private function  propertyChange(property:ICharacterProperty = null):void {
        if ( !m_fightUI )
            return;

        var maxValue:int = property.MaxRagePower/property.maxRageCount;
        var enValue:Number = int(( (property.RagePower % maxValue) / maxValue) * 100 ) / 100;
        TweenLite.killTweensOf(m_enereyView['pro_energy'],true);
        TweenLite.to(m_enereyView['pro_energy'],.5,{value:enValue});

        var enNum:int = Math.floor(property.RagePower/maxValue);
        m_enereyView['eff_1'].visible =
                m_enereyView['eff_2'].visible =
                        m_enereyView['eff_3'].visible = false;
        for( var i:int = 1 ; i <= enNum ; i++ ){
            m_enereyView["eff_" + i ].visible = true;
        }
        if(enNum > 0 && enNum > _lastEnNum ){
            m_enereyView['box_eff'].x = m_enereyView["eff_" + enNum ].x;
            m_enereyView['box_eff'].y = m_enereyView["eff_" + enNum ].y;
            m_enereyView['eff_energy'].addEventListener(UIEvent.FRAME_CHANGED,onChanged );
            m_enereyView['eff_energy'].visible = true;
            m_enereyView['eff_energy'].gotoAndPlay(0);
            function onChanged(evt:UIEvent):void{
                if( m_enereyView['eff_energy'].frame >=  m_enereyView['eff_energy'].totalFrame - 1) {
                    m_enereyView['eff_energy'].removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
                    m_enereyView['eff_energy'].stop();
                    m_enereyView['eff_energy'].visible = false;
                }
            }
        }
        _lastEnNum = enNum;


    }

    public function hide(removed:Boolean = true):void {
        if(m_enereyView)
            TweenLite.killTweensOf(m_enereyView['pro_energy']);
        _lastEnNum = 0;
    }

}
}
