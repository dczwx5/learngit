//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/9/19.
 */
package kof.game.reciprocation {

import QFLib.Memory.CResourcePool;

import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;

import kof.framework.CAppSystem;

import kof.framework.CViewHandler;
import kof.game.KOFSysTags;
import kof.game.lobby.CLobbySystem;
import kof.game.lobby.view.CLobbyViewHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

import morn.core.components.Component;

import morn.core.components.Component;

public class CFlyItemViewHandler extends CViewHandler {

    /** 飞入“背包”等用的时间(秒) */
    public static const FlyToTime:Number = 0.6;

    private var m_pBmpPool:CResourcePool;

    public function CFlyItemViewHandler( bLoadViewByDefault : Boolean = false )
    {
        super( bLoadViewByDefault );
    }

    override protected function onSetup() : Boolean
    {
        var ret : Boolean = super.onSetup();
        m_pBmpPool = new CResourcePool("BmpPool", Bitmap);
        return ret;
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
    public function flyItemToBag(sourceItem:Component, startPoint:Point, system:CAppSystem, callBack:Function = null,
                                        width:Number = 0, height:Number = 0, toPx:int = -10, toPy:int = -20):void
    {
        if(sourceItem == null)
        {
            return;
        }

        if(!system.enabled)
        {
            return;
        }

        var bmp:Bitmap = m_pBmpPool.allocate() as Bitmap;
        var bmpWidth:int = width > 0 ? width : sourceItem.width;
        var bmpHeight:int = height > 0 ? height : sourceItem.height;
        var bmd:BitmapData = new BitmapData(bmpWidth, bmpHeight);
        bmd.draw(sourceItem, new Matrix(1,0,0,1));
        bmp.bitmapData = bmd;

        sourceItem = null;

        bmp.x = startPoint.x;
        bmp.y = startPoint.y;
        (system.stage.getSystem(IUICanvas) as CUISystem).stage.flashStage.addChild(bmp);

        // 先往左上方缓动
        var toX:int = bmp.x + toPx;
        var toY:int = bmp.y + toPy;
//        var toScaleX:Number = 40 / bmp.width;
//        var toScaleY:Number = 40 / bmp.height;

        var toScaleX:Number = 1;
        var toScaleY:Number = 1;

        TweenMax.to(bmp, 0.8, {x:toX, y:toY, scaleX:toScaleX, scaleY:toScaleY});

        // 往背包位置缓动
        var toPoint:Point = (system.stage.getSystem(CLobbySystem ).getHandler(CLobbyViewHandler ) as CLobbyViewHandler).getPrimaryIconGlobalPoint(KOFSysTags.BAG);

        if ( !toPoint ) {
            onCompleteFlyItem( bmp, callBack, system );
            return;
        }

        TweenMax.to(bmp, FlyToTime, {
            delay:1.0,
            x:toPoint.x,
            y:toPoint.y,
            scaleX:1,
            scaleY:1,
//            ease:Quad.easeIn,
//            bezier:[{x:toPoint.x+10, y:bmp.y}],
            onComplete:onCompleteFlyItem,
            onCompleteParams:[bmp,callBack,system]
        });
    }

    private function onCompleteFlyItem(bmp:Bitmap,callBack:Function,system:CAppSystem):void
    {
        if(bmp)
        {
            bmp.x = 0;
            bmp.y = 0;
            bmp.bitmapData.dispose();
            bmp.bitmapData = null;
            bmp.rotation = 0;
            bmp.scaleX = 1;
            bmp.scaleY = 1;

            if(bmp.parent)
            {
                bmp.parent.removeChild(bmp);
            }

            m_pBmpPool.recycle(bmp);

            (system.stage.getSystem(CLobbySystem).getHandler(CLobbyViewHandler) as CLobbyViewHandler).shineIcon(KOFSysTags.BAG);
        }

        if(callBack != null)
        {
            callBack.call();
        }
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
    public function flyItemToTarget(sourceItem:Component, startPoint:Point, target:Component, system:CAppSystem, callBack:Function = null,
                                 width:Number = 0, height:Number = 0, toPx:int = -10, toPy:int = -20, targetScalc:Number = 1.0):void
    {
        if(sourceItem == null)
        {
            return;
        }

        if(!system.enabled)
        {
            return;
        }

        if (!startPoint) {
            startPoint = sourceItem.localToGlobal(new Point(0, 0));
        }

        var bmp:Bitmap = m_pBmpPool.allocate() as Bitmap;
        var bmpWidth:int = width > 0 ? width : sourceItem.width;
        var bmpHeight:int = height > 0 ? height : sourceItem.height;
        var bmd:BitmapData = new BitmapData(bmpWidth, bmpHeight, true, 0);

        bmd.draw(sourceItem, new Matrix(1,0,0,1));
        bmp.bitmapData = bmd;

        sourceItem = null;

        bmp.x = startPoint.x;
        bmp.y = startPoint.y;
        (system.stage.getSystem(IUICanvas) as CUISystem).stage.flashStage.addChild(bmp);

        // 先往左上方缓动
        var toX:int = bmp.x + toPx;
        var toY:int = bmp.y + toPy;
//        var toScaleX:Number = 40 / bmp.width;
//        var toScaleY:Number = 40 / bmp.height;

        var toScaleX:Number = 1;
        var toScaleY:Number = 1;

        TweenMax.to(bmp, 0.8, {x:toX, y:toY, scaleX:toScaleX, scaleY:toScaleY});

        // 往背包位置缓动
        var toPoint:Point = new Point(0, 0);
        toPoint = target.localToGlobal(toPoint);

        if ( !toPoint ) {
            onCompleteFlyItem( bmp, callBack, system );
            return;
        }

        TweenMax.to(bmp, FlyToTime, {
            delay:1.0,
            x:toPoint.x,
            y:toPoint.y,
            scaleX:targetScalc,
            scaleY:targetScalc,
//            ease:Quad.easeIn,
//            bezier:[{x:toPoint.x+10, y:bmp.y}],
            onComplete:onCompleteFlyItemToTarget,
            onCompleteParams:[bmp,callBack,system, targetScalc]
        });
    }

    private function onCompleteFlyItemToTarget(bmp:Bitmap,callBack:Function,system:CAppSystem, targetScalc:Number):void
    {
        if(bmp)
        {
            bmp.x = 0;
            bmp.y = 0;
            bmp.bitmapData.dispose();
            bmp.bitmapData = null;
            bmp.rotation = 0;
            bmp.scaleX = targetScalc;
            bmp.scaleY = targetScalc;

            if(bmp.parent)
            {
                bmp.parent.removeChild(bmp);
            }

            m_pBmpPool.recycle(bmp);
        }

        if(callBack != null)
        {
            callBack.call();
        }
    }
}
}
