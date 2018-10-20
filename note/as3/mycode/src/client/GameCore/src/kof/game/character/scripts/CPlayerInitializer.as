//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.Foundation;
import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CCharacterEvent;
import kof.game.character.CCharacterInitializer;
import kof.game.character.CEventMediator;
import kof.game.character.ai.CAIComponent;
import kof.game.character.display.IDisplay;
import kof.game.character.level.CLevelMediator;
import kof.game.character.level.CScenarioComponent;
import kof.game.character.scripts.appear.CAppearAction;
import kof.game.character.scripts.appear.CFallAppearAction;
import kof.game.character.scripts.appear.CNormalAppearAction;
import kof.game.character.scripts.appear.CPlayAnimationAppearAction;
import kof.game.character.scripts.appear.CRunAppearAction;
import kof.game.character.scripts.appear.CSkillAppearAction;
import kof.game.character.state.CCharacterInput;

/**
 * 玩家类型的组件初始化脚本逻辑
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CPlayerInitializer extends CCharacterInitializer {

    static private var s_pAppearActionHandlers : Vector.<Class>;
    public var m_bAppearDone : Boolean;
    private var m_pAppearAction:CAppearAction;

    public function CPlayerInitializer() {
        super();

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

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();

        var isScenarioActor:Boolean = this.owner.getComponentByClass(CScenarioComponent, false);
        var level:CLevelMediator = this.owner.getComponentByClass( CLevelMediator, false) as CLevelMediator;
        if (isScenarioActor || level.instanceFacade.isMainCity) {
            m_bAppearDone = true;
        } else {
            var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
            if(level.instanceFacade.isStart){
                _onCharacterDisplayReady(null);
            }else {
                if ( pEventMediator ) {
                    pEventMediator.addEventListener( CCharacterEvent.INSTANCE_STARTED, _onCharacterDisplayReady, false, CEventPriority.DEFAULT, true );
                }
            }

        }

        var pDisplay : IDisplay = this.getComponent( IDisplay ) as IDisplay;
        if ( pDisplay ) {
            pDisplay.loadingPriority = ELoadingPriority.LOW;
        }
    }

    private function _onCharacterDisplayReady( event : Event ) : void {
        var pLevelMediator : CLevelMediator = this.getComponent(CLevelMediator) as CLevelMediator;
        if (pLevelMediator) {
            var pAppearData:Object = pLevelMediator.getBornActionDataByEntityID(this.entityID,1);
            if (pAppearData) {
                // need to perform a appear action.
                executeAppearAction(pAppearData);
            } else{
                (owner.getComponentByClass(CAIComponent,false ) as CAIComponent).appearComplete = true;
                m_bAppearDone = true;
            }
        } else {
            m_bAppearDone = true;
        }
    }

    private function executeAppearAction( pAppearData : Object ) : void {
        var pInput : CCharacterInput = getComponent( CCharacterInput ) as CCharacterInput;
        if ( pInput ) {
            pInput.enabled = false;
        }
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
        var pInput : CCharacterInput = getComponent( CCharacterInput ) as CCharacterInput;
        if ( pInput ) {
            pInput.enabled = true;
        }

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

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator )
            pEventMediator.dispatchEvent( new Event( CCharacterEvent.APPEAR_END ) );

        (owner.getComponentByClass(CAIComponent,false ) as CAIComponent).appearComplete = true;

        m_bAppearDone = true;
        m_pAppearAction = null;
    }

    override protected virtual function onExit() : void {
        super.onExit();
    }

    final public function get entityID() : int {
        if ( owner && owner.data )
            return int( owner.data.entityID );
        return 0;
    }

    override public virtual function update( delta : Number ) : void {
        super.update( delta );
        if(m_pAppearAction){
            m_pAppearAction.update(delta);
        }
    }

    override protected virtual function get isDone() : Boolean {
        return super.isDone && m_bAppearDone;
    }

    override protected function get asHost() : Boolean {
        var isRobot : Boolean = CCharacterDataDescriptor.isRobot( owner.data );
        var iMyOperateSide : int = CCharacterDataDescriptor.getOperateSide( owner.data );
        return iMyOperateSide == 1 || isRobot ;
    }

}
}
