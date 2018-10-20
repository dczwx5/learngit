//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/7.
 */
package kof.game.character.property.interfaces {

import kof.game.character.property.*;

public interface ICalcNextProperty {
    // 下一等级
    function calcNextLevelProperty() : CBasePropertyData;
    // 下一品质
    function calcNextQualityProperty() : CBasePropertyData;
    // 下一星级
    function calcNextStarProperty() : CBasePropertyData;
}
}
