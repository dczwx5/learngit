//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/6/8.
//----------------------------------------------------------------------
package kof.game.character.fight.sync.synctimeline.base.strategy {

import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.fight.sync.synctimeline.base.CBaseFightTimeLineNode;
import kof.game.character.fight.sync.synctimeline.base.action.CBaseFighterKeyAction;
import kof.game.character.fight.sync.synctimeline.base.action.EFighterActionType;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CBaseStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CCatchStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CDodgeStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CHealStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CHitStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CMissileAbsorbStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CMissileActivateStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CSkillEndStrategy;
import kof.game.character.fight.sync.synctimeline.base.strategy.base.CSkillStrategy;
import kof.game.core.CGameComponent;

public class CSyncStrategyComp extends CGameComponent {
    public function CSyncStrategyComp() {
        super( "SyncStrategyComp" );
    }

    override protected function onEnter() : void {
        super.onEnter();
        if ( pFightTrigger )
            pFightTrigger.addEventListener( CFightTriggleEvent.EVT_TIME_LINE_NODE_INSERTED, _onTimeLineInserted );
    }

    override public function dispose() : void {
        if ( m_theSyncContext )
            m_theSyncContext.dispose();
        m_theSyncContext = null;
        super.dispose();
    }

    override protected function onExit() : void {
        super.onExit();
    }

    private function _onTimeLineInserted( e : CFightTriggleEvent ) : void {
        var theNode : CBaseFightTimeLineNode;
        var theAction : CBaseFighterKeyAction;
        var theFighterCtx : CSyncContext;
        theNode = e.parmList && e.parmList.length > 0 ? e.parmList[ 0 ] : null;
        theAction = e.parmList && e.parmList.length > 1 ? e.parmList[ 1 ] : null;

        if ( !theNode || !theAction ) return;
        theFighterCtx = _createSyncContext( theAction, theNode );
        if ( theFighterCtx )
            theFighterCtx.takeAction();
    }

    private function _createSyncContext( action : CBaseFighterKeyAction, arrivingNode : CBaseFightTimeLineNode ) : CSyncContext {
        var pStrategy : CBaseStrategy;
        pStrategy = _getStrategyByType( action.type );

        if ( pStrategy ) {
            if ( m_theSyncContext == null ) {
                m_theSyncContext = new CSyncContext( owner );
            }
            else
                m_theSyncContext.resetStrategy();

            pStrategy.action = action;
            pStrategy.timelineNode = arrivingNode;

            m_theSyncContext.setStrategy( pStrategy );
        } else {
            if ( m_theSyncContext )
                m_theSyncContext.setStrategy( null );
        }
        return m_theSyncContext;
    }

    private function _getStrategyByType( actionType : int ) : CBaseStrategy {
        var type : int = actionType;
        var pStrategy : CBaseStrategy;
        switch ( type ) {
            case EFighterActionType.E_SKILL_ACTION:
                pStrategy = new CSkillStrategy();
                break;
            case EFighterActionType.E_SKILL_END_ACTION:
                pStrategy = new CSkillEndStrategy();
                break;
            case EFighterActionType.E_HIT_ACTION:
                pStrategy = new CHitStrategy();
                break;
            case EFighterActionType.E_CATCH_ACTION:
                pStrategy = new CCatchStrategy();
                break;
            case EFighterActionType.E_HEAL_ACTION:
                pStrategy = new CHealStrategy();
                break;
            case EFighterActionType.E_DODGE_ACTION:
                pStrategy = new CDodgeStrategy();
                break;
            case EFighterActionType.E_ABSORB_MISSILE:
                pStrategy = new CMissileAbsorbStrategy();
                break;
            case EFighterActionType.E_ACTIVATE_MISSILE:
                pStrategy = new CMissileActivateStrategy();
                break;
            default:
                return null;
        }
        return pStrategy;
    }

    final private function get pFightTrigger() : CCharacterFightTriggle {
        return owner.getComponentByClass( CCharacterFightTriggle, true ) as CCharacterFightTriggle;
    }

    public function getCurrentSyncContext() : CSyncContext {
        return m_theSyncContext;
    }

    private var m_theSyncContext : CSyncContext;
}
}
