//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import flash.events.Event;

import kof.framework.events.CEventPriority;
import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.level.CLevelMediator;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.core.CSubscribeBehaviour;

/**
 * 独立抽象的角色死亡组件
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCharacterDie extends CSubscribeBehaviour {

    /**
     * Creates a new CCharacterDie.
     */
    public function CCharacterDie() {
        super( 'characterDead' );
    }

    override public function dispose() : void {
        super.dispose();
    }

    override protected virtual function onEnter() : void {
        super.onEnter();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.addEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onCharacterStateValueChanged, false, CEventPriority.DEFAULT, true );
        }
    }

    override protected virtual function onDataUpdated() : void {
        super.onDataUpdated();
    }

    override protected virtual function onExit() : void {
        super.onExit();

        var pEventMediator : CEventMediator = this.getComponent( CEventMediator ) as CEventMediator;
        if ( pEventMediator ) {
            pEventMediator.removeEventListener( CCharacterEvent.STATE_VALUE_UPDATE, _onCharacterStateValueChanged );
        }
    }

    private function _onCharacterStateValueChanged( event : Event ) : void {
        var pStateBoard : CCharacterStateBoard = getComponent( CCharacterStateBoard ) as CCharacterStateBoard;
        if ( pStateBoard && pStateBoard.isDirty( CCharacterStateBoard.DEAD ) && true == pStateBoard.getValue( CCharacterStateBoard.DEAD ) ) {
            this.onDie();
        }
    }

    protected function onDie() : void {
        var pLevelMediator : CLevelMediator = this.getComponent( CLevelMediator ) as CLevelMediator;
        if ( pLevelMediator ) {
            var dieEvent : CCharacterEvent = new CCharacterEvent( CCharacterEvent.DIE, owner );
            pLevelMediator.sendEvent( dieEvent );
        }
    }

}
}
