//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.skillcalc {

import flash.utils.Dictionary;

import kof.game.character.fight.*;

import QFLib.Interface.IUpdatable;

import kof.game.character.fight.skill.CSkillDataBase;

import kof.game.character.fight.skillcalc.CFightCalc;

import kof.game.character.fight.skillcalc.CFightCDCalc;
import kof.game.character.fight.skillcalc.CFightOthersCalc;
import kof.game.character.fight.skillcalc.hurt.CFightHurtFacade;
import kof.game.character.fight.skillcalc.hurt.CFightProperty;
import kof.game.character.fight.skillcalc.hurt.CFightPropertyFacade;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.CCharacterSyncBoard;
import kof.game.character.fight.sync.INeedSync;
import kof.game.character.level.CLevelMediator;

import kof.game.character.property.CCharacterProperty;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CGameComponent;

/**
 * 战斗计算器
 *
 * |- 打击命中伤害计算
 * |- 自动恢复机制
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CFightCalc extends CGameComponent implements IUpdatable, INeedSync {

    public function CFightCalc() {
        super( "fightCalc" );
    }

    override public function dispose() : void {

        if ( m_calcEntity )
            m_calcEntity = null;
        if ( m_recovery )
            m_recovery.dispose();
        m_recovery = null;

        if ( m_fightCDCalc )
            m_fightCDCalc.dispose();

        m_fightCDCalc = null;

        if ( m_fightOtherCalc )
            m_fightOtherCalc.dispose();
        m_fightOtherCalc = null;

        if ( m_fightHurtFacade )
            m_fightHurtFacade.dispose();
        m_fightHurtFacade = null;

        if ( m_fightPropertyFacade )
            m_fightPropertyFacade.dispose();
        m_fightPropertyFacade = null;

        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
        m_calcEntity = new CCalcEntity( owner );
        m_recovery = new CPropertyRecovery( this );
        m_fightCDCalc = new CFightCDCalc( owner );
        m_fightOtherCalc = new CFightOthersCalc( owner );
        m_fightHurtFacade = new CFightHurtFacade( owner );
        m_fightPropertyFacade = new CFightPropertyFacade( owner );

        var levelMediator : CLevelMediator = pLevelMediator;
        if( levelMediator ) {
            if( levelMediator.isPVE || levelMediator.isMainCity )
                m_calcEntity.bEnableRestoreRagePower = true;
        }
    }

    public function update( delta : Number ) : void {
        if ( stateBoard.getValue( CCharacterStateBoard.DEAD ) ) return;
        if ( m_calcEntity )
            m_calcEntity.update( delta );

        if ( m_recovery )
            m_recovery.update( delta );

        if ( m_fightCDCalc )
            m_fightCDCalc.update( delta );

        if ( m_fightOtherCalc )
            m_fightOtherCalc.update( delta );

    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
//        if( m_calcEntity )
//                m_calcEntity.pCharacterProperty = owner.getComponentByClass( CCharacterProperty , true ) as CCharacterProperty;
        if ( m_recovery )
            m_recovery.pCharacterProperty = owner.getComponentByClass( CCharacterProperty, true ) as CCharacterProperty;
    }

    public function removeSkillCDByID( skillID : int ) : void {
        fightCDCalc.removeSkillCD( skillID );
    }

    public function _resetDodgeCD() : void{
        if( fightCDCalc ) {
            removeSkillCDByID( CSkillDataBase.SKILL_ID_QUICKSTAND_SIM );
            removeSkillCDByID( CSkillDataBase.SKILL_ID_DODGE_SIM );
        }
    }

    override protected virtual function onExit() : void {
        dispose();
        super.onExit();
    }

    public function get battleEntity() : CCalcEntity {
        return m_calcEntity;
    }

    public function get fightCDCalc() : CFightCDCalc {
        return m_fightCDCalc;
    }

    public function get recovery() : CPropertyRecovery {
        return m_recovery;
    }

    public function get otherFightCalc() : CFightOthersCalc {
        return m_fightOtherCalc
    }

    public function get fightHurtFacade() : CFightHurtFacade {
        return m_fightHurtFacade;
    }

    public function get fightPropertyFacade() : CFightPropertyFacade {
        return m_fightPropertyFacade;
    }

    final public function get stateBoard() : CCharacterStateBoard {
        return owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
    }

    public function syncFrom() : void {
        var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        if ( pSyncBoard ) {
            var cdPool : Object = fightCDCalc.encodeCDPool();
            if ( null != cdPool )
                pSyncBoard.setValue( CCharacterSyncBoard.SKILL_CD_LIST, cdPool );
        }
    }

    public function syncTo() : void {
        var pSyncBoard : CCharacterSyncBoard = owner.getComponentByClass( CCharacterSyncBoard, true ) as CCharacterSyncBoard;
        if ( pSyncBoard ) {
            var syncData : Object = pSyncBoard.getValue( CCharacterSyncBoard.SKILL_CD_LIST ) as Object;
            if ( syncData != null ) {
                fightCDCalc.decodeCDPool( syncData );
            }
        }
    }

    public function syncCDFromData( cds : Object ) : void {
        if ( cds != null ) {
            fightCDCalc.decodeCDPool( cds );
        }
    }

    private function get pLevelMediator() : CLevelMediator{
        return owner.getComponentByClass( CLevelMediator , true ) as CLevelMediator;
    }

    private var m_calcEntity : CCalcEntity;//攻击值 防御值 怒气
    private var m_recovery : CPropertyRecovery;
    private var m_fightCDCalc : CFightCDCalc;//cd
    private var m_fightOtherCalc : CFightOthersCalc; //连击数
    private var m_fightHurtFacade : CFightHurtFacade; //伤害处理
    private var m_fightPropertyFacade : CFightPropertyFacade;//属性计算
    public static var CONST_THOUSAND : int = 10000;


}
}
