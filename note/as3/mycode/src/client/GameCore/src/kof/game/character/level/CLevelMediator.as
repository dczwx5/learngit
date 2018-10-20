//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.level {

import QFLib.Math.CAABBox3;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Rectangle;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.core.CGameObject;
import kof.game.instance.IInstanceFacade;
import kof.game.level.ILevelFacade;
import kof.game.scene.ISceneFacade;

/**
 * A extra component for level supporting, delegating instance also.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CLevelMediator extends CSceneMediator {

    private var m_pLevelFacade : ILevelFacade;
    private var m_pInstanceFacade : IInstanceFacade;
    private const LEVEL_STARTED : String = "levelStarted";

    public function CLevelMediator( pSceneFacade : ISceneFacade, pInstanceFacade : IInstanceFacade, pLevelFacade : ILevelFacade ) {
        super( pSceneFacade );
        this.name = "level";

        m_pInstanceFacade = pInstanceFacade;
        m_pLevelFacade = pLevelFacade;
    }

    override public function dispose() : void {
        super.dispose();

        this.m_pLevelFacade = null;
        this.m_pInstanceFacade = null;

        if ( instanceEventDisptcher )
            instanceEventDisptcher.removeEventListener( LEVEL_STARTED, _instanceStarted );
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        if ( instanceEventDisptcher )
            instanceEventDisptcher.addEventListener( LEVEL_STARTED, _instanceStarted );
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    override public function sendEvent( event : Event ) : Boolean {
        var ret : Boolean = super.sendEvent( event );

        if ( m_pLevelFacade ) {
            switch ( event.type ) {
                case CCharacterEvent.DIE:
                    ret = ret && m_pLevelFacade.sendEvent( event );
                    break;
                default:
                    break;
            }
        }

        return ret;
    }

    public function getBornActionDataByEntityID( entityID : int, ownerType : int = 0 ) : Object {
        var levelSystem : ILevelFacade = this.m_pLevelFacade;
        if ( levelSystem ) {
            if ( ownerType == 0 ) {
                return levelSystem.getAppearData( entityID );
            }
            else if ( ownerType == 1 ) {
                return levelSystem.getHerotAppearData( entityID );
            }
        }
        return null;
    }

    public function getHideFootEffect( entityID : int ) : Boolean {
        var levelSys : ILevelFacade = this.m_pLevelFacade;
        if ( levelSys ) {
            return levelSys.getHideFootEffect( entityID );
        }
        return false;
    }

    public function get isPVE() : Boolean {
        var instanceFacade : IInstanceFacade = this.instanceFacade;
        if ( instanceFacade ) {
            return instanceFacade.isPVE;
        }
        return false;
    }

    public function get isAera() : Boolean {
        var instanceFacade : IInstanceFacade = this.instanceFacade;
        if ( instanceFacade ) {
            return instanceFacade.isArena;
        }
        return false;
    }

    public function getLevelCurTrunk() : Rectangle {
        var levelSys : ILevelFacade = this.m_pLevelFacade;
        var rec : Rectangle;
        if ( levelSys )
            rec = levelSys.getCurTrunkRec();
        return rec;
    }

    public function getCurrentCameraRec() : Rectangle{
        var levelSys : ILevelFacade = this.m_pLevelFacade;
        var rec : Rectangle;
        if ( levelSys )
            rec = levelSys.getCurReallyTrunkRect();
        return rec;
    }
    public function getXOffsetOfTrunkPerBox( box : CAABBox3, direction : int ) : Number {
        var trunkRec : Rectangle =  getCurrentCameraRec();//getLevelCurTrunk();
        if ( trunkRec == null || box == null )
            return NaN;

        if ( direction == 1 ) {
            return trunkRec.right - box.max.x;
        }
        else if ( direction == -1 ) {
            return box.min.x - trunkRec.left ;
        }

        return NaN;
    }

    public function get isTrainLevel() : Boolean {
        var instanceFacade : IInstanceFacade = this.instanceFacade;
        if ( instanceFacade ) {
            return instanceFacade.isPractice;
        }
        return false;
    }

    final public function isAppearType( entityData : Object, matchType : int ) : Boolean {
        var appearType : int = this.getAppearType( entityData );
        return appearType == matchType;
    }

    final public function getAppearType( pAppearData : Object ) : int {
        if ( 'appearType' in pAppearData )
            return int( pAppearData.appearType );
        return 0;
    }

    private function _instanceStarted( e : Event ) : void {
        if ( pEventMediator )
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.INSTANCE_STARTED ) );
    }

    protected function getCampID( pObj : CGameObject ) : int {
        var pProperty : ICharacterProperty = pObj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
        if ( pProperty ) {
            return pProperty.campID;
        }
        return 0;
    }

    public function isPlayingScenario() : Boolean {
        return m_pLevelFacade.isPlayingScenario();
    }

    public function isTeachingLevel() : Boolean {
        return instanceFacade.isTeaching;
    }

    final public function isAttackable( pTarget : CGameObject ) : Boolean {
        //fixme  播放剧情忽视阵营
        if ( !pTarget || !pTarget.isRunning )
            return false;

        if ( m_pLevelFacade && m_pLevelFacade.isPlayingScenario() ) {
            var isImScenarioActor : Boolean = this.getComponent( CScenarioComponent );
            var isTargetScenarioActor : Boolean = pTarget.getComponentByClass( CScenarioComponent, false );
            if ( isImScenarioActor && (isTargetScenarioActor == isTargetScenarioActor) ) {
                return true;
            } else if ( isImScenarioActor != isTargetScenarioActor ) {
                return false;
            } else {
                // 都不是剧情怪, 跑原本流程
            }
        }

        var iMyCampID : int = getCampID( owner );

        var iTargetCampID : int = getCampID( pTarget );
        var isAttackable : Boolean = m_pLevelFacade.isAttackable( iMyCampID, iTargetCampID );
        return isAttackable;
    }

    final public function isFriendly( pTarget : CGameObject ) : Boolean {
        if ( !pTarget )
            return false;

        var iMyCampID : int = getCampID( owner );
        var iTargetCampID : int = getCampID( pTarget );

        return m_pLevelFacade.isFriendly( iMyCampID, iTargetCampID );
    }

    final private function get instanceEventDisptcher() : IEventDispatcher {
        return m_pInstanceFacade as IEventDispatcher;
    }

    final private function get pEventMediator() : CEventMediator {
        if ( owner )
            return owner.getComponentByClass( CEventMediator, true ) as CEventMediator;
        return null;
    }

    public function get instanceFacade() : IInstanceFacade {
        return m_pInstanceFacade;
    }

    public function getSingPoints( index : int ) : Object {
        return m_pLevelFacade.getSingPoins( index );
    }

    public function get isMainCity() : Boolean {
        if ( instanceFacade ) {
            return instanceFacade.isMainCity;
        }

        return false;
    }

    public function get isPlelude() : Boolean{
        if( instanceFacade ){
            return instanceFacade.currentIsPrelude;
        }
        return false;
    }

    public function getNPC( id : int ) : Object {
        return m_pLevelFacade.getNpcByID( id );
    }
}
}
