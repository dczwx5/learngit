//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.fight.skilleffect {

import QFLib.Foundation;
import QFLib.Interface.IUpdatable;

import kof.framework.events.CEventPriority;
import kof.game.character.fight.CCharacterNetworkInput;
import kof.game.character.fight.catches.CSkillCatcher;
import kof.game.character.fight.catches.ICatcherInfo;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CComponentUtility;
import kof.game.character.fight.skill.CSkillCaster;
import kof.game.character.fight.skill.CSkillDataBase;
import kof.game.character.fight.skill.CSkillHit;
import kof.game.core.CGameObject;
import kof.table.SkillEndCatch;
import kof.util.CAssertUtils;

/**
 * 技能抓取结束事件效果
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSkillCatchEndEffect extends CAbstractSkillEffect implements IUpdatable {

    private var m_fElapsedTime : Number;
    private var m_pSkillContext : CComponentUtility;
    private var m_bEventAttached : Boolean;
    private var m_pCatchEndData : SkillEndCatch;
    private var m_pEndDirectly : Boolean;

    /**
     * Creates a new CSkillCatchEndEffect.
     */
    public function CSkillCatchEndEffect( id : int, startFrame : Number, duration : Number, hitEvent : String,
                                          type : int, description : String = null ) {
        super( id, startFrame, hitEvent, type, description );

        this.m_effectDuarationFrame = duration / CSkillDataBase.TIME_IN_ONEFRAME;
    }

    override public function dispose() : void {

        //应策划要求 如果该效果没有执行到的时候，不对已抓取的目标进行释放！！！
        if( boStarted || m_pEndDirectly )
            _releaseCatchers();
//        doEndCatches();
//        if ( m_pSkillContext )
//            m_pSkillContext.fightTriggle.removeEventListener( CFightTriggleEvent.HURT_TARGET, _onAnyTargetHurt );

        m_pSkillContext = null;
        m_pCatchEndData = null;
        super.dispose();
    }

    /** @inheritDoc */
    override public function initData( ... args ) : void {
        CONFIG::debug {
            Foundation.Log.logTraceMsg( "**@CSkillCatchEndEffect: 初始化结束抓取效果。" );
        }

        if ( !args || !args.length )
            return;

        super.initData( args );

        m_pSkillContext = args[ 0 ] as CComponentUtility;

        CAssertUtils.assertNotNull( m_pSkillContext, "Invalid args[0] as CComponentUtility." );

        if ( effectID ) {
            m_pCatchEndData = CSkillCaster.skillDB.catchEndTable.findByPrimaryKey( effectID );
            if ( !m_pCatchEndData )
                Foundation.Log.logErrorMsg( "找不到 '抓取结束' 配置，ID：" + effectID );
        }

        m_fElapsedTime = 0.0;
        m_bEventAttached = false;
    }

    override public function update( delta : Number ) : void {
        super.update( delta );

        if ( isNaN( m_fElapsedTime ) || m_pEndDirectly )
            return;

        m_fElapsedTime += delta;

//        if ( !m_bEventAttached && m_fElapsedTime >= effectStartTime ) {
//            m_bEventAttached = true;
//            m_pSkillContext.fightTriggle.addEventListener( CFightTriggleEvent.HURT_TARGET, _onAnyTargetHurt, false, CEventPriority.DEFAULT, true );
//        }

        if ( m_fElapsedTime >= effectStartTime + effectDuarationTime ) {
            // triggered.
            m_fElapsedTime = NaN;

            doEndCatches();
        }
    }

    public function catchEndTargetDirectly( target : Array ) : void {
        Foundation.Log.logTraceMsg("直接对目标执行结束抓取效果！！！");
        m_pEndDirectly = true;
        _releaseCatchers();

    }

    protected function doEndCatches() : void {

        var targets : Array = _releaseCatchers();
        if ( !targets || targets.length == 0 )
            return;
        _doEndCatchHitToTargets( targets );
        /**
         if ( !m_pSkillContext )
         return;

         var vCatcher : CSkillCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;

         if ( !vCatcher )
         return;

         var targets : Array = [];
         for each ( var vInfo : ICatcherInfo in vCatcher.infoIterator ) {
            targets.push( vInfo.target );
        }

         // Erases all catching objects.
         vCatcher.removeAll();

         var pSkillCaster : CSkillCaster = m_pSkillContext.owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
         if ( targets.length && m_pCatchEndData ) {

            var hitID : int = m_pCatchEndData.EndHit;
            _syncCatchEnd( targets );
            if ( hitID != 0 && (!pNetComp || !pNetComp.isAsPuppet ))
                pSkillCaster.castHitToTargets( hitID, targets, null,true );
        }*/
    }

    protected function _releaseCatchers() : Array {
        if ( !m_pSkillContext )
            return null;

        var vCatcher : CSkillCatcher = m_pSkillContext.owner.getComponentByClass( CSkillCatcher, true ) as CSkillCatcher;

        if ( !vCatcher )
            return null;

        var targets : Array = [];
        for each ( var vInfo : ICatcherInfo in vCatcher.infoIterator ) {
            targets.push( vInfo.target );
        }

        // Erases all catching objects.
        vCatcher.removeAll();
        return targets;
    }

    protected function _doEndCatchHitToTargets( targets : Array ) : void {
        var pSkillCaster : CSkillCaster = m_pSkillContext.owner.getComponentByClass( CSkillCaster, true ) as CSkillCaster;
        if ( targets.length && m_pCatchEndData ) {

            var hitID : int = m_pCatchEndData.EndHit;
            _syncCatchEnd( targets );
            var skillHit : CSkillHit;
            if ( hitID != 0 && (!pNetComp || !pNetComp.isAsPuppet ) ) {
                skillHit = pSkillCaster.castHitToTargets( hitID, targets, null, true );
                if ( skillHit != null )
                    skillHit.update( 0 );
            }
        }
    }

    private function get pNetComp() : CCharacterNetworkInput {
        return owner.getComponentByClass( CCharacterNetworkInput, true ) as CCharacterNetworkInput;
    }

    private function _onAnyTargetHurt( event : CFightTriggleEvent ) : void {
        if ( m_pSkillContext )
            m_pSkillContext.fightTriggle.removeEventListener( CFightTriggleEvent.HURT_TARGET, _onAnyTargetHurt );

        doEndCatches();
    }

    private function _syncCatchEnd( targets : Array ) : void {
        if ( targets != null && targets.length > 0 ) {
            var vecTars : Vector.<CGameObject> = new <CGameObject>[];
            for each( var target : CGameObject in targets ) {
                vecTars.push( target );
            }
            m_pSkillContext.fightTriggle.dispatchEvent( new CFightTriggleEvent( CFightTriggleEvent.REQUEST_SYNC_CATCH, null, [ vecTars, m_pCatchEndData.ID, 1 ] ) );
        }
    }

}
}

// vim:ft=as3 ts=4 sw=4 tw=120
