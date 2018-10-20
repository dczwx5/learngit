//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/9/12.
 */
package kof.game.instance.mainInstance.data {

public class CFightingInstanceMessage {
    public function CFightingInstanceMessage() {
    }

    public function get  isPassBefore() : Boolean {
        return _isPassBefore;
    }
    public function set isPassBefore(v:Boolean) : void {
        _isPassBefore = v;
    }

    private var _isPassBefore:Boolean; // 副本在打之前已经通关
    public var instanceData:CChapterInstanceData;

}
}
