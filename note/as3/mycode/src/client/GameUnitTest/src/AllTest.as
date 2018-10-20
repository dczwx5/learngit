//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

import flash.display.Sprite;

import org.flexunit.internals.TraceListener;
import org.flexunit.runner.FlexUnitCore;

public class AllTest extends Sprite {

    /** @private */
    private var m_pCore : FlexUnitCore;

    public function AllTest() {
        super();

        m_pCore = new FlexUnitCore();
        m_pCore.addListener( new TraceListener() );
        m_pCore.run();
    }
}
}
