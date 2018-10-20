//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubPlatformData extends CObjectData {
    public function CSubPlatformData() {
    }

    public function get platformInfo() : Object { // 为PlatformHandler.data 提供数据
        return _rootData.data[ _platformInfo ];
    }
    [Inline]
    final public function get platform() : String {
        return _rootData.data[ _platform ];
    }
    final public function set platform( value : String ) : void {
        _rootData.data[ _platform ] = value;
    }

    public static const _platform : String = "platform";
    public static const _platformInfo : String = "platformInfo";



}
}
