//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/8.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.LinkButton;

public class KOFLinkButton extends LinkButton {
    public function KOFLinkButton( label : String = "" ) {
        super( label );
    }
    override protected function initialize():void {
        super.initialize();
        _btnLabel.underline = false;
    }
    override protected function onMouse(e:MouseEvent):void {
       super.onMouse(e);
        if( e.type == MouseEvent.ROLL_OVER ){
            _btnLabel.underline = true;
        }else if( e.type == MouseEvent.ROLL_OUT ){
            _btnLabel.underline = false;
        }
    }
}
}
