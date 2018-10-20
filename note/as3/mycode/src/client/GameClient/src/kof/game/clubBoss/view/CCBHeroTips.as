//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/11/4.
 * Time: 15:23
 */
package kof.game.clubBoss.view {

import kof.ui.master.clubBoss.CBHeroTipUI;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/11/4
 */
public class CCBHeroTips {
    private var _tips:CBHeroTipUI=null;
    public function CCBHeroTips() {
        _tips = new CBHeroTipUI();
        _tips.buffBox.visible = false;
    }

    public function showRuleTips(str:String):void{
        App.tip.addChild(_tips);
        _tips.txt.text = str;
    }
}
}
