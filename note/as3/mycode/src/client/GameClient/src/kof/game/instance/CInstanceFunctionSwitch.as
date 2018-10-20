//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/6.
 */
package kof.game.instance {

import kof.framework.CAbstractHandler;

// 功能开关
public class CInstanceFunctionSwitch extends CAbstractHandler {

    public function CInstanceFunctionSwitch() {
    }

    public override function dispose():void {
        super.dispose();

    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();

        return ret;
    }


    private function get _instanceSystem() : CInstanceSystem {
        return system as CInstanceSystem;
    }
}
}