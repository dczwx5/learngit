//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/9/21.
 */
package kof.game.resourceInstance {

import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;

public class CResourceInstanceManager extends CAbstractHandler implements IUpdatable {

    private var data:Array;

    public function CResourceInstanceManager() {
        super();
    }

    public function update( delta : Number ) : void {
    }

    public function get m_data() : Array {
        return data;
    }

    public function set m_data( value : Array ) : void {
        data = value;
    }
}
}
