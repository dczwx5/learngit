//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/7/24.
 */
package kof.game.level.view {

import flash.events.Event;

import kof.game.common.view.CRootView;
import kof.game.instance.CInstanceAutoFightHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.level.CLevelManager;
import kof.game.lobby.CLobbySystem;
import kof.ui.master.level.MasterComingUI;

import morn.core.components.FrameClip;
import morn.core.handlers.Handler;

public class CLevelMasterComingView extends CRootView {

    private var m_characterClip : FrameClip;
    private var m_callbackFun : Function;

    public function CLevelMasterComingView() {
        super( MasterComingUI, null, [ [ MasterComingUI ] ], false );
    }

    protected override function _onShow() : void {
        this.listStageClick = true;
        m_characterClip = _ui.clipCharacter as FrameClip;
        m_characterClip.playFromTo( null, null, new Handler( _onMovieCompleted ) );
        //策划要求，此时暂停关卡
        (system.getBean( CLevelManager ) as CLevelManager).pauseLevel();
        (system.stage.getSystem( CLobbySystem ) as CLobbySystem).fightUIEnabled = false;
        (system.stage.getSystem( CInstanceSystem ).getBean( CInstanceAutoFightHandler ) as CInstanceAutoFightHandler).setForcePause( true );
    }

    private function _onMovieCompleted() : void {
        //策划要求，此时恢复关卡
        (system.getBean( CLevelManager ) as CLevelManager).continueLevel();
        (system.stage.getSystem( CLobbySystem ) as CLobbySystem).fightUIEnabled = true;
        (system.stage.getSystem( CInstanceSystem ).getBean( CInstanceAutoFightHandler ) as CInstanceAutoFightHandler).setForcePause( false );
        if ( m_callbackFun != null ) {
            m_callbackFun();
        }
    }

    override public function setData( data : Object, forceInvalid : Boolean = true ) : void {
        super.setData( data, forceInvalid );
        m_callbackFun = data.callback;
    }

    public virtual override function updateWindow() : Boolean {
        if ( false == super.updateWindow() ) return false;

        this.addToRoot();

        return true;
    }

    protected override function _onDispose() : void {
        m_characterClip.removeEventListener( Event.COMPLETE, _onMovieCompleted );
        m_characterClip = null;
    }

    protected function get _ui() : MasterComingUI {
        return rootUI as MasterComingUI;
    }

}
}
