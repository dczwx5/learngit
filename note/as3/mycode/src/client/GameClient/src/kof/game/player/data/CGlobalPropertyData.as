//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/8.
 */
package kof.game.player.data {

import kof.game.character.property.CBasePropertyData;

public class CGlobalPropertyData extends CBasePropertyData {
    public function CGlobalPropertyData() {

    }
    public override function updateDataByData(data:Object) : void {
        super.updateDataByData(data);
    }

    public static const _artifactProperty:String = "artifactProperty";
    public static const _talentProperty:String = "talentProperty";
    public static const _cardProperty:String = "cardMonthProperty";

    public static const _clubProperty:String = "clubProperty";
    public static const _effortProperty:String = "effortProperty";
    public static const _titleProperty:String = "titleProperty";

    public static const _gemProperty:String = "gemProperty";

}
}
