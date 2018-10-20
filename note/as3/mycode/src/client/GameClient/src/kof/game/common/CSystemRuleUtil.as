//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/24.
 */
package kof.game.common {

import flash.events.MouseEvent;

import morn.core.components.Component;
import morn.core.events.UIEvent;

public class CSystemRuleUtil {
    public function CSystemRuleUtil() {
    }

    /**
     * 添加某个系统的玩法规则
     * @param ruleTargetObj 要添加规则tips的UI组件
     * @param rule
     */
    public static function setRuleTips(ruleTargetObj:Component, rule:String):void
    {
        ruleTargetObj.toolTip = rule;
//        ruleTargetObj.addEventListener(MouseEvent.CLICK, _onClickTipHandler);
        if (Boolean(rule)) {
            ruleTargetObj.addEventListener(MouseEvent.CLICK, _onClickTipHandler);
        } else {
            ruleTargetObj.removeEventListener(MouseEvent.CLICK, _onClickTipHandler);
        }
    }

    private static function _onClickTipHandler(e:MouseEvent):void
    {
        var component:Component = e.target as Component;
        component.dispatchEvent(new UIEvent(UIEvent.SHOW_TIP, component.toolTip, true));

        App.tip.defaultTipHandler.apply(null, [component.toolTip]);
    }
}
}
