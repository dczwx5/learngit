//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/10/6.
 */
package kof.game.player.data.subData {

import kof.data.CObjectData;

public class CSubTutorData extends CObjectData {
    public function CSubTutorData() {
    }
    public function get guideIndex() : int {
        return _rootData.data[ _guideIndex ];
    }
    [Inline]
    public function get battleGuideStep() : int {
        return _rootData.data[ _battleGuideStep ];
    }
    [Inline]
    public function set battleGuideStep(v:int) : void {
        _rootData.data[ _battleGuideStep ] = v;
    }

    public static const _guideIndex : String = "guideIndex";
    public static const _battleGuideStep : String = "fightGuide";

}
}
