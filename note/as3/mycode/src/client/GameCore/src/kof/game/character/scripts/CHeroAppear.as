//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.character.scripts {

import QFLib.ResourceLoader.ELoadingPriority;

import flash.events.Event;

import kof.game.character.CCharacterEvent;
import kof.game.character.CEventMediator;
import kof.game.character.display.IDisplay;

/**
 * 主角出场
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CHeroAppear extends CPlayerInitializer {

    /**
     * Creates a new CHeroAppear.
     */
    public function CHeroAppear() {
        super();
    }

    override protected function get asHost() : Boolean {
        return true;
    }

    override protected virtual function onDataUpdated() : void {
//        var pEventMediator : CEventMediator = getComponent( CEventMediator ) as CEventMediator;
//        if ( pEventMediator ) {
//            pEventMediator.dispatchEvent( new Event( CCharacterEvent.READY, false, false ) );
//        }

        super.onDataUpdated();

        var pDisplay : IDisplay =  this.getComponent( IDisplay ) as IDisplay;
        if ( pDisplay ) {
            pDisplay.loadingPriority = ELoadingPriority.CRITICAL;
        }
//        m_bAppearDone = true;1
    }
}
}
