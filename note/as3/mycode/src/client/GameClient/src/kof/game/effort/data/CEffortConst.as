//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort.data {

import kof.game.common.CLang;
import kof.game.common.CLang;

/**
 * 成就系统常量
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortConst {

    public static const SCENARIO:int = 1;
    public static const DEVELOP:int = 2;
    public static const FIGHT:int = 3;
    public static const CONSUME:int = 4;
    public static const TYPES:int = 4;

    public static const EFFORT_TYPE_FIGHT:String = "effort_type_fight";
    public static const EFFORT_TYPE_SCENARIO:String = "effort_type_scenario";
    public static const EFFORT_TYPE_CONSUME:String = "effort_type_consume";
    public static const EFFORT_TYPE_DEVELOP:String = "effort_type_develop";

    public static const EFFORT_POINT_LABEL:String = "effort_point_label";
    public static const EFFORT_POINT_LABEL1:String = "effort_point_label1";
    public static const EFFORT_BINDDIAMOND:String = "effort_binddiamond";
    public static const EFFORT_ACHIEVE_POINT:String = "effort_achieve_point";
    public static const EFFORT_ACHIEVEMENT_TIME_LABEL:String = "effort_achievement_time_label";
    public static const EFFORT_NOT_ACHIEVEMENT_LABEL:String = "effort_not_achievement_label";
    public static const EFFORT_STAGE_LABEL:String = "effort_stage_label";



    public static const TYPE_CONST_LIST:Array = [EFFORT_TYPE_SCENARIO,EFFORT_TYPE_DEVELOP,EFFORT_TYPE_FIGHT,EFFORT_TYPE_CONSUME];


    public function CEffortConst() {
    }

    public static function getLangByType(type:int):String
    {
        return CLang.Get(TYPE_CONST_LIST[type - 1]) + CLang.Get(EFFORT_POINT_LABEL1);
    }

    public static function getLangByTypeA(type:int):String
    {
        return CLang.Get(TYPE_CONST_LIST[type - 1]) + CLang.Get(EFFORT_POINT_LABEL);
    }
}
}
