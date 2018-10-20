//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/11/6.
 * Time: 18:29
 */
package kof.game.clubBoss.view {

import kof.ui.master.clubBoss.CBHeroTipUI;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/11/6
 */
public class CBuffTips {
    private var _tips:CBHeroTipUI=null;
    public function CBuffTips() {
        _tips = new CBHeroTipUI();
        _tips.rule.visible = false;
    }
    public function showBuffTips(str:String):void{
        App.tip.addChild(_tips);
        _tips.buffTxt.text = str;
    }

}
}
