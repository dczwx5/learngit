//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {


/**
 * 系统控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSystemHandler extends CAbstractHandler {

    public function CSystemHandler() {
        super();
    }

    private var _networking:INetworking;

    public function get networking():INetworking {
        return _networking;
    }

    kof_framework function set networking(value:INetworking):void {
        this._networking = value;
    }

}
}
