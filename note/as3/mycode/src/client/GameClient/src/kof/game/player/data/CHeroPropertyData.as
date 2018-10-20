//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/8.
 */
package kof.game.player.data {

import kof.game.character.property.CBasePropertyData;
import kof.game.impression.util.CImpressionUtil;
import kof.game.player.data.property.CGlobalProperty;
import kof.game.player.data.property.CPlayerHeroProperty;

public class CHeroPropertyData extends CBasePropertyData {
    public function CHeroPropertyData() {

        _baseProperty = new CPlayerHeroProperty();
    }
    public override function updateDataByData(data:Object) : void {
        _baseProperty.updateDataByData(data);
    }

    public function recalcProperty(globalProperty:CGlobalProperty,globalPercentProperty:CBasePropertyData) : void {
        this.clearData();
        this.add(_baseProperty);
        this.add(globalProperty);

//        var impressionProperty:CBasePropertyData = CImpressionUtil.getImpressionStarAttr();
        if(globalPercentProperty != null)
        {
            this.addPercent(globalPercentProperty);
        }
    }

    private var _baseProperty:CPlayerHeroProperty; // 基础属性
}
}
