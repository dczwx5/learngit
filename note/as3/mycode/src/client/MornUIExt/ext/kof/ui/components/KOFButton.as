//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/7/29.
 */
package kof.ui.components {

import flash.security.X500DistinguishedName;

import morn.core.components.Button;

public class KOFButton extends Button {
    public function KOFButton( skin : String = null, label : String = "" ) {
        super( skin, label );
    }
    private var _clickEvent:String;
    public function get clickEvent() : String {
        return _clickEvent;
    }

    public function set clickEvent( value:String ) : void {
        _clickEvent = value;
    }
}
}
