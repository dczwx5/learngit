//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/8/26.
 * 能量信息
 */
package kof.game.fightui.compoment {

import com.greensock.TweenLite;

import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.events.CPropertyUpdateEvent;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.property.CPlayerProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.core.CGameObject;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.demo.FightUI;

import morn.core.components.View;

import morn.core.events.UIEvent;

public class CEnereyViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;
    private var _heroEventMediator : CEventMediator;
    private var _hero:CGameObject;

    private var m_enereyView : View;

    public function CEnereyViewHandler($fightUI:FightUI = null) {
        super();
        if($fightUI){
            m_fightUI = $fightUI;
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
    public function setData(hero:CGameObject,view :View ):void {
        hide();
        if(!m_fightUI ||  !hero)
            return;
        _hero = hero;
        m_enereyView = view;
        resetUI();
        if(_heroEventMediator && _heroEventMediator.owner && _heroEventMediator.owner.isRunning)
            _heroEventMediator.removeEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate);

        var pPlayerProperty : CPlayerProperty = hero.getComponentByClass( CPlayerProperty, true ) as CPlayerProperty;
        _heroEventMediator = pPlayerProperty.getComponent( CEventMediator ) as CEventMediator;
        if ( _heroEventMediator )
            _heroEventMediator.addEventListener(CCharacterEvent.CHARACTER_PROPERTY_UPDATE,_onPropertyUpdate, false, 0, true );
        var property : ICharacterProperty = hero.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        propertyChange(property);

        m_enereyView.visible = true;
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
//        if(enNum > 0 && enNum > _lastEnNum ){
//            m_enereyView['box_eff'].x = m_enereyView["eff_" + enNum ].x;
//            m_enereyView['box_eff'].y = m_enereyView["eff_" + enNum ].y;
//            m_enereyView['eff_energy'].addEventListener(UIEvent.FRAME_CHANGED,onChanged );
//            m_enereyView['eff_energy'].visible = true;
//            m_enereyView['eff_energy'].gotoAndPlay(0);
//            function onChanged(evt:UIEvent):void{
//                if( m_enereyView['eff_energy'].frame >=  m_enereyView['eff_energy'].totalFrame - 1) {
//                    m_enereyView['eff_energy'].removeEventListener( UIEvent.FRAME_CHANGED, onChanged );
//                    m_enereyView['eff_energy'].stop();
//                    m_enereyView['eff_energy'].visible = false;
//                }
//            }
//        }
        _lastEnNum = enNum;


        var pDB : IDatabase = system.stage.getSystem( IDatabase ) as IDatabase;
        var pTablePlayerSkil : IDataTable = pDB.getTable( KOFTableConstants.PLAYER_SKILL );
        var pPlayerSkill : PlayerSkill = pTablePlayerSkil.findByPrimaryKey( _hero.data.prototypeID );

        var pTableSkil : IDataTable = pDB.getTable( KOFTableConstants.SKILL );
        var pSkill : Skill = pTableSkil.findByPrimaryKey( pPlayerSkill.SkillID[5] );

        if(pSkill && property.RagePower >= pSkill.ConsumePGP){
            m_fightUI.spcicalSkill.mc_fire_1.visible =
                    m_fightUI.spcicalSkill.mc_fire_2.visible = true;
        }else{
            m_fightUI.spcicalSkill.mc_fire_1.visible =
                    m_fightUI.spcicalSkill.mc_fire_2.visible = false;
        }

        _pSkillViewHandler.updateEnerey( enNum );
    }

    public function hide(removed:Boolean = true):void {
        if(m_enereyView)
            TweenLite.killTweensOf(m_enereyView['pro_energy']);
        _lastEnNum = 0;
    }

    private function get _pSkillViewHandler():CSkillViewHandler{
        return system.getHandler( CSkillViewHandler ) as CSkillViewHandler;
    }
}
}
