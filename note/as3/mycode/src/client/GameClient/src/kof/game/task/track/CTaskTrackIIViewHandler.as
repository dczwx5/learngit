//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/7.
 */
package kof.game.task.track {

import kof.framework.CViewHandler;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.ui.IUICanvas;

import morn.core.components.Box;

public class CTaskTrackIIViewHandler extends CViewHandler {


//    private var m_taskTrackUI:TaskTrackIIUI;

    public function CTaskTrackIIViewHandler( ) {
        super();

//        if ( !m_taskTrackUI ) {
//            m_taskTrackUI = new TaskTrackIIUI();
//        }
    }
    public function show():void{
//        _parentCtn.addChild( m_taskTrackUI );
    }

    private function get _parentCtn():Box{
        var pLobbySystem:CLobbySystem = system.stage.getSystem( CLobbySystem ) as CLobbySystem;
        var pLobbyViewHandler:CLobbyViewHandler = pLobbySystem.getBean(CLobbyViewHandler) as CLobbyViewHandler;
        var notice:Box = pLobbyViewHandler.pMainUI.getChildByName("task") as Box;
        return notice;
    }
    private function get iUICanvas():IUICanvas{
        return system.stage.getSystem(IUICanvas) as IUICanvas;
    }
}
}
