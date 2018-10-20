//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.Foundation;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CCharacterInitializer;
import kof.game.character.CEventMediator;
import kof.game.character.ai.CAIComponent;
import kof.game.character.animation.IAnimation;
import kof.game.character.animation.IAnimation;
import kof.game.character.display.IDisplay;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.level.CLevelMediator;
import kof.game.character.level.CScenarioComponent;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.scene.CSceneMediator;
import kof.game.character.scripts.appear.CAppearAction;
import kof.game.character.scripts.appear.CFallAppearAction;
import kof.game.character.scripts.appear.CNormalAppearAction;
import kof.game.character.scripts.appear.CPlayAnimationAppearAction;
import kof.game.character.scripts.appear.CRunAppearAction;
import kof.game.character.scripts.appear.CSkillAppearAction;
import kof.game.scene.CSceneEvent;
import kof.table.Monster.EMonsterType;

/**
 * 怪物出场
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CMonsterAppear extends CCharacterInitializer {

    static private var s_pAppearActionHandlers : Vector.<Class>;

    private var m_bAppearDone : Boolean;

    private var m_pAppearAction:CAppearAction;

    private var m_pPlayHandler : CPlayHandler;
    /**
     * Creates a new CMonsterAppear.
     */
    public function CMonsterAppear( playHandle : CPlayHandler = null) {
        super();
        m_pPlayHandler = playHandle;
        if ( !s_pAppearActionHandlers ) {
            s_pAppearActionHandlers = new <Class>[];
            s_pAppearActionHandlers.push( CNormalAppearAction ); // default appear ignore.
            s_pAppearActionHandlers.push( CRunAppearAction ); // walk appear didn't supported now.
            s_pAppearActionHandlers.push( CFallAppearAction );
//            s_pAppearActionHandlers.push( CPlayAnimationAppearAction );
            s_pAppearActionHandlers.push( CSkillAppearAction );
        }
}

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    override protected virtual function onDataUpdated() : void {
        var pLevelMediator : CLevelMediator = this.getComponent(CLevelMediator) as CLevelMediator;
        if (pLevelMediator) {
            var pAppearData : Object = pLevelMediator.getBornActionDataByEntityID( this.entityID );
            this.moveToAvailablePosition = pAppearData.moveToAvailablePosition;
        }

        super.onDataUpdated();

        var isScenarioActor:Boolean = this.owner.getComponentByClass(CScenarioComponent, false);
        if (isScenarioActor) {
            m_bAppearDone = true;
        } else {

            var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
            if ( pEventMediator ) {
                pEventMediator.addEventListener( CCharacterEvent.DISPLAY_READY, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
            }
        }
        var property:CMonsterProperty = owner.getComponentByClass(CMonsterProperty,true) as CMonsterProperty;
        if(property && property.shadow == 0)
        {
            (owner.getComponentByClass(IDisplay,true) as IDisplay).modelDisplay.castShadow = false;
        }
    }

    private function _onCharacterDisplayReady( event : CCharacterEvent ) : void {
        var pLevelMediator : CLevelMediator = this.getComponent(CLevelMediator) as CLevelMediator;
        if (pLevelMediator) {
            var pAppearData:Object = pLevelMediator.getBornActionDataByEntityID(this.entityID);
            var bool:Boolean = owner.data.hasOwnProperty("addFromCreate") ? owner.data.addFromCreate : false;
            if (pAppearData && bool) {
                // need to perform a appear action.
                executeAppearAction(pAppearData);
            }
            else{
                (owner.getComponentByClass(CAIComponent,false ) as CAIComponent).appearComplete = true;
                m_bAppearDone = true;
            }
        } else {
            m_bAppearDone = true;
        }

        if (  monsterType == EMonsterType.UNIQUE || monsterType == EMonsterType.BOSS || monsterType == EMonsterType.EXTRAME_BOSS || monsterType == EMonsterType.WORLD_BOSS) {
            var pSceneFacade : CSceneMediator = getComponent(CSceneMediator) as CSceneMediator;
            if (pSceneFacade) {
                pSceneFacade.sendEvent(new CSceneEvent(CSceneEvent.BOSS_APPEAR, owner));
            }
        }

        var pProperty : CMonsterProperty = getComponent( CMonsterProperty ) as CMonsterProperty;
        if ( pProperty ) {
            if( pProperty.initialGravity == 1 ) {
               var pAnimation : IAnimation = getComponent( IAnimation ) as IAnimation;
                if( pAnimation)
                        pAnimation.setDefaultCharacterGravityAcc( 0 );
            }
        }
    }

    public function get monsterType() : int {
        var pProperty : CMonsterProperty = getComponent( CMonsterProperty ) as CMonsterProperty;
        if ( pProperty ) {
            return pProperty.monsterType;
        }
        return 0;
    }

    override protected function get asHost() : Boolean {
        if( CCharacterDataDescriptor.isSummoned( owner.data )) {
            if( m_pPlayHandler!= null && m_pPlayHandler.hero != null ) {
               return CCharacterDataDescriptor.getRoleID( owner.data) == CCharacterDataDescriptor.getRoleID( m_pPlayHandler.hero.data )
            }
        }
        return true;
    }

    final public function get entityID() : int {
        if ( owner && owner.data )
            return int( owner.data.entityID );
        return 0;
    }

    final public function get ID() : int {
        if ( owner && owner.data )
            return int( owner.data.id );
        return 0;
    }

    final public function get entityType() : int {
        if ( owner && owner.data )
            return int( owner.data.entityType );
        return 0;
    }

    override protected virtual function get isDone() : Boolean {
        return super.isDone && m_bAppearDone;
    }

    private function executeAppearAction( pAppearData : Object ) : void {
        var pLevelMediator : CLevelMediator = this.getComponent( CLevelMediator ) as CLevelMediator;
        if ( !pLevelMediator )
            return;

        var iTypeOfAppear : int = pLevelMediator.getAppearType( pAppearData );
        if ( iTypeOfAppear < s_pAppearActionHandlers.length ) {
            // It have a valid appear action handler.
            var pHandlerClass : Class = s_pAppearActionHandlers[ iTypeOfAppear ];
            if ( !pHandlerClass )
                Foundation.Log.logWarningMsg( "There's no specified Appear action handler for type: " +
                        iTypeOfAppear.toString() + ", Fallback to normal action." );

            if ( !pHandlerClass ) {
                pHandlerClass = CNormalAppearAction;
            }

            m_pAppearAction = new pHandlerClass( owner, pAppearData );
            m_pAppearAction.execute( _onCompleted );
        } else if ( 0 == iTypeOfAppear ) { // The default appear.
            // ignore.
            m_bAppearDone = true;
        }
    }

    /**
     * Triggered when appear action executed completed.
     */
    private function _onCompleted(value:Boolean) : void {

        var pLevelMediator : CLevelMediator = this.getComponent(CLevelMediator) as CLevelMediator;
        if(pLevelMediator == null){
            return;
        }
        var pAppearData:Object = pLevelMediator.getBornActionDataByEntityID(this.entityID);
        if (value && pAppearData && pAppearData.isPlayAction) {
            m_pAppearAction = new CPlayAnimationAppearAction( owner, pAppearData );
            m_pAppearAction.execute( _onCompleted );
            return;
        }

        m_bAppearDone = true;
        m_pAppearAction = null;
        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.APPEAR_END ) );

        (owner.getComponentByClass(CAIComponent,false ) as CAIComponent).appearComplete = true;
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );
        if(m_pAppearAction){
            m_pAppearAction.update(delta);
        }
    }
}
}
// vim:ft=as3 ts=4 sw=4 et tw=0
