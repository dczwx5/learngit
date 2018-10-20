//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/6/26.
 */
package kof.game.gem {

import kof.game.common.view.CViewManagerHandler;
import kof.game.gem.view.CGemSuitTipsView;

public class CGemUIHandler extends CViewManagerHandler{
    public function CGemUIHandler() {
    }

    override protected function onSetup():Boolean
    {
        var ret : Boolean = super.onSetup();

        this.registTips( CGemSuitTipsView );

        return ret;
    }

    public override function dispose() : void {
        super.dispose();

    }
}
}
