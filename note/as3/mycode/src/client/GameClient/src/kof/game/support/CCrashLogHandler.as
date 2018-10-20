//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.support {

import QFLib.Foundation.CTime;

import flash.system.Capabilities;
import flash.system.System;

import kof.framework.CAbstractHandler;
import kof.framework.IApplication;
import kof.framework.events.CEventPriority;
import kof.game.instance.IInstanceFacade;
import kof.game.level.CLevelSystem;
import kof.game.player.CPlayerSystem;

import mx.events.Request;

/**
 * 崩溃日志支持
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CCrashLogHandler extends CAbstractHandler {

    public function CCrashLogHandler() {
        super();
    }

    override protected virtual function onSetup() : Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.initialize();
        return ret;
    }

    private function initialize() : Boolean {
        var pApp : IApplication = system.stage.getBean( IApplication ) as IApplication;
        if ( pApp && pApp.eventDispatcher ) {
            pApp.eventDispatcher.addEventListener( "GET_CRASH_LOG", onGetCrashLogRequest,
                    false, CEventPriority.DEFAULT_HANDLER, true );
        }
        return true;
    }

    private function onGetCrashLogRequest( event : Request ) : void {
        if ( !event.value )
            return;

        var pPlayerSystem : CPlayerSystem = system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
        if ( pPlayerSystem && pPlayerSystem.playerData ) {
            event.value[ 'roleID' ] = pPlayerSystem.playerData.ID;
            event.value[ 'roleName' ] = pPlayerSystem.playerData.teamData.name;
            event.value[ 'level' ] = pPlayerSystem.playerData.teamData.level;
        }

        var pInstanceSystem : IInstanceFacade = system.stage.getSystem( IInstanceFacade ) as IInstanceFacade;
        if ( pInstanceSystem && pInstanceSystem.instanceContent ) {
            event.value[ 'instanceID' ] = pInstanceSystem.instanceContent.ID;
        } else {
            event.value[ 'instanceID' ] = 0;
            event.value[ 'sceneID' ] = 0;
        }

        var pLevelSystem : CLevelSystem = system.stage.getSystem( CLevelSystem ) as CLevelSystem;
        if ( pLevelSystem && pLevelSystem.currentLevel ) {
            event.value[ 'sceneID' ] = pLevelSystem.currentLevel.ID;
        }

        event.value[ 'flashVersion' ] = Capabilities.version + "_" + ( Capabilities.isDebugger ? "d" : "r" );
        event.value[ 'lastMemSize' ] = toMB( System.totalMemory );
        event.value[ 'playTime' ] = CTime.getTimeElapsedSinceStartUp();
    }

    private static function toMB( byte : uint ) : uint {
        var ret : uint = 0;
        if ( byte < 10485760 ) {
            ret = byte / 1048576;
        } else if ( byte < 104857600 ) {
            ret = byte / 1048576;
        } else {
            ret = Math.round( byte / 1048576 );
        }
        return ret;
    }

}
}
