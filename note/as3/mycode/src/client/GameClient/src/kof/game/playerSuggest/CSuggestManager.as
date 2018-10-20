//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/5/15.
 */
package kof.game.playerSuggest {

import kof.framework.CAbstractHandler;
import kof.game.playerSuggest.view.CSuggestViewHandler;

public class CSuggestManager extends CAbstractHandler{

    private var m_data:*;

    public function CSuggestManager()
    {
        super();
    }

    public function get data():*
    {
        return m_data;
    }

    public function set data(value:*):void
    {
        m_data = value;

        var view : CSuggestViewHandler = this.system.getBean( CSuggestViewHandler ) as CSuggestViewHandler;
        if ( null != view && view.isViewShow)
        {
            view.invalidate();
        }
    }
}
}
