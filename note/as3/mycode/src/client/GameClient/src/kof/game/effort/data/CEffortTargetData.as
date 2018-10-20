//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/30
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.data {

import QFLib.Utils.StringUtil;

import kof.game.common.CLang;
import kof.table.EffortConfig;
import kof.table.EffortTargetConfig;

/**
 * @author Leo.Li
 * @date 2018/5/30
 */
public class CEffortTargetData {

    /**
     * EffortTargetConfig.ID
     */
    public var targetConfigId:int;
    private var _obtainTick:Number = 0;
    public var current:int;
    public var max:int;
    public var achievementTimeStr:String;
    public var isComplete:Boolean;
    public var cfg:EffortConfig;

    public function CEffortTargetData() {
    }

    public function get obtainTick() : Number {
        return _obtainTick;
    }

    public function set obtainTick( value : Number ) : void {
        _obtainTick = value;
        achievementTimeStr = CLang.Get(CEffortConst.EFFORT_ACHIEVEMENT_TIME_LABEL,{v1:StringUtil.dayFormat(value,".")});
    }
}
}
