//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/20.
 */
package kof.game.common {

import flash.geom.Point;

import kof.framework.CAppSystem;

import kof.game.reciprocation.CFlyItemViewHandler;
import kof.game.reciprocation.CReciprocalSystem;

import morn.core.components.Component;

import morn.core.components.Component;

public class CFlyItemUtil {
    public function CFlyItemUtil()
    {
    }

    /**
     * 物品直线飞到背包
     * @param sourceItem
     * @param startPoint
     * @param system
     * @param callBack
     * @param width
     * @param height
     * @param toPx
     * @param toPy
     *
     */
    public static function flyItemToBag(sourceItem:Component, startPoint:Point, system:CAppSystem, callBack:Function = null,
                                        width:Number = 0, height:Number = 0, toPx:int = -10, toPy:int = -20):void
    {
        if(!system.enabled)
        {
            return;
        }

        var flyItemView:CFlyItemViewHandler = system.stage.getSystem(CReciprocalSystem ).getHandler(CFlyItemViewHandler) as CFlyItemViewHandler;
        flyItemView.flyItemToBag(sourceItem, startPoint, system, callBack, width, height, toPx, toPy);
    }
    public static function flyItemToTarget(sourceItem:Component, startPoint:Point, target:Component, system:CAppSystem, callBack:Function = null,
                                        width:Number = 0, height:Number = 0, toPx:int = -10, toPy:int = -20, targetScalc:Number = 1.0):void
    {
        if(!system.enabled)
        {
            return;
        }

        var flyItemView:CFlyItemViewHandler = system.stage.getSystem(CReciprocalSystem ).getHandler(CFlyItemViewHandler) as CFlyItemViewHandler;
        flyItemView.flyItemToTarget(sourceItem, startPoint, target, system, callBack, width, height, toPx, toPy, targetScalc);
    }
}
}
