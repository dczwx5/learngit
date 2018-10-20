//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/2/27.
 */
package kof.ui.components {

import morn.core.components.Button;
import morn.core.components.Tab;

public class KOFTab extends Tab {
    public var _labelFont:String;

    public function KOFTab( labels : String = null, skin : String = null ) {
        super( labels, skin );

        labelBold
    }

    public function get labelFont() : String {
        return _labelFont;
    }
    public function set labelFont( value : String ) : void {
        _labelFont = value;
        callLater( changeLabels );
    }

    override protected function changeLabels():void {
        super.changeLabels();
        if (_items) {
            for ( var i : int = 0, n : int = _items.length; i < n; i++ ) {
                var btn : Button = _items[ i ] as Button;
                if ( _skin ) {
                    btn.labelFont = _labelFont;
                }
            }
        }

    }
}
}
