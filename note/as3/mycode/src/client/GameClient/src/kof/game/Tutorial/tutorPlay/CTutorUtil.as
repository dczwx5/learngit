//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/12/28.
 */
package kof.game.Tutorial.tutorPlay {

import flash.events.Event;
import kof.framework.CAppSystem;
import kof.framework.events.CEventPriority;
import kof.ui.CUIComponentTutorHandler;
import kof.ui.CUISystem;
import kof.util.CAssertUtils;

import morn.core.components.Component;

public class CTutorUtil {
    public static function GetComponentWithOutLoad(system:CAppSystem, tutorCompID:String) : Component {
        if (!tutorCompID || tutorCompID.length == 0) return null;
        var pUctHandler : CUIComponentTutorHandler = _tutorUIParser(system);
        if (!pUctHandler) return null;

        return pUctHandler.getCompByTutorID(tutorCompID);
    }


    public static function GetComponent(system:CAppSystem, tutorCompID:String, callback:Function) : void {
        if (!tutorCompID || tutorCompID.length == 0) return ;
        if (!callback) return ;
        var pUctHandler : CUIComponentTutorHandler = _tutorUIParser(system);
        if (!pUctHandler) return ;

        if ( pUctHandler.isCompRegistered( tutorCompID ) ) { // 已经注册显示在舞台上
            _startByDefault(system, tutorCompID, callback);
        } else {
            var _uct_onCompRegisteredEventHandler:Function = function ( event : Event ) : void {
                if ( pUctHandler.isCompRegistered( tutorCompID ) ) {
                    event.currentTarget.removeEventListener( event.type, _uct_onCompRegisteredEventHandler );
                    _startByDefault(system, tutorCompID, callback);
                }
            };
            pUctHandler.addEventListener( CUIComponentTutorHandler.EVENT_COMP_REGISTERED,
                    _uct_onCompRegisteredEventHandler, false, CEventPriority.DEFAULT_HANDLER, false ); // 不能用弱引用
        }
    }
    private static function _startByDefault(system:CAppSystem, tutorCompID:String, callback:Function) : void {
        var pUctHandler : CUIComponentTutorHandler = _tutorUIParser(system);
        CAssertUtils.assertNotNull( pUctHandler );
        if (callback) {
            var comp:Component = pUctHandler.getCompByTutorID( tutorCompID );
            callback(comp);
        }
    }

    // get
    private static function _tutorUIParser(system:CAppSystem) : CUIComponentTutorHandler {
        if ( !system )
            return null;
        var pUISys : CUISystem = system.stage.getSystem( CUISystem ) as CUISystem;
        if ( pUISys ) {
            return pUISys.getHandler( CUIComponentTutorHandler ) as CUIComponentTutorHandler;
        }
        return null;
    }
}
}
