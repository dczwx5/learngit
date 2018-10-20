//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/9.
 */
package kof.game.platform {

import QFLib.Foundation.CMap;

public class CPlatformFunctionMapHandler extends CPlatformModuleHandler {
    public function CPlatformFunctionMapHandler() {
        _s_pf_map = new CMap();
    }

    public function addData(key:String, data:CPlatformFunctionData) : void {
        _s_pf_map.add(key, data);
    }
    public function getByType(platform:String) : CPlatformFunctionData {
        return _s_pf_map.find(platform) as CPlatformFunctionData;
    }

    // callback(key, data);
    public function loop(callback:Function) : void {
        if (!callback) return ;

        for (var key:* in _s_pf_map) {
            callback(key, _s_pf_map.find(key));
        }
    }

    private var _s_pf_map:CMap;
}
}
