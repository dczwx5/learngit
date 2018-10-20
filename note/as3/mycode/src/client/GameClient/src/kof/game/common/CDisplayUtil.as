//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/9.
 */
package kof.game.common {

import QFLib.Interface.IDisposable;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

import morn.core.components.Component;

public class CDisplayUtil {

    public function CDisplayUtil()
    {
    }

    /**
     * 从arr数组中删除不再使用的
     * @param originArr
     * @param usedNum 有多少个有用的，usedNum=0表示所有都删除
     * @param isReuse
     */
    public static function delNotUse(originArr:Array, usedNum:int, isReuse:Boolean = true):void
    {
        if(originArr == null || originArr.length <= usedNum)
        {
            return;
        }

        for(var i:int = usedNum; i < originArr.length; i++)
        {
            var obj:DisplayObject = originArr[i];

            removeSelf(obj);

            if(obj is IDisposable)
            {
                (obj as IDisposable).dispose();
            }

            if(isReuse)
            {
                CUIFactory.disposeDisplayObj(obj);
            }
        }

        originArr.splice(usedNum);
    }

    /**
     * 从显示列表中移除
     * @param displayObject
     *
     */
    public static function removeSelf(displayObject:DisplayObject):void
    {
        if(displayObject == null)
        {
            return;
        }

        if(displayObject.parent != null)
        {
            displayObject.parent.removeChild(displayObject);
        }
    }

    public static function setObjAttr(obj:DisplayObject,x:Number = 0,y:Number = 0,width:Number = -1,height:Number = -1,parent:DisplayObjectContainer = null):void
    {
        obj.x = x;
        obj.y = y;
        if(width > 0)
        {
            obj.width = width;
        }
        if(height > 0)
        {
            obj.height = height;
        }
        if(parent)
        {
            parent.addChild(obj);
        }
    }

    public static function autoSortChildrenX(container:DisplayObjectContainer) : void {
        var left:Number = 0;
        for (var i:int = 0; i < container.numChildren; i++) {
            var item:Component = container.getChildAt(i) as Component;
            if (item.visible) {
                item.x = left;
                left += item.displayWidth
            } else {
                item.x = 0;
            }
        }
    }
}
}
