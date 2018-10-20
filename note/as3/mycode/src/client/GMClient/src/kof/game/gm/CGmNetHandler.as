//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/1/16.
 */
package kof.game.gm {

import kof.game.common.system.CNetHandlerImp;

public class CGmNetHandler extends CNetHandlerImp {
    public function CGmNetHandler() {
        super();
    }

    public override function dispose() : void {
        super.dispose();

    }

    override protected function onSetup() : Boolean {
        super.onSetup();

        return true;
    }

    public override function update(delta : Number) : void {
        super.update(delta);

    }

}
}