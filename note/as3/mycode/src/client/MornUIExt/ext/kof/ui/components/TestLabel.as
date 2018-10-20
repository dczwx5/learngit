//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui.components {

import morn.core.components.Label;

/**
 * MORN UI扩展组件测试
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class TestLabel extends Label {

    private var m_bCacheAsBitmap : Boolean;

    public function TestLabel( text : String = "", skin : String = null ) {
        super( text, skin );
    }

    override public function get cacheAsBitmap() : Boolean {
        return m_bCacheAsBitmap;
    }

    override public function set cacheAsBitmap( value : Boolean ) : void {
        if ( m_bCacheAsBitmap == value )
            return;
        m_bCacheAsBitmap = value;
        super.cacheAsBitmap = value;
    }

}
}
