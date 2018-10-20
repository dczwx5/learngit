//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/9.
 */
package kof.game.common {

import QFLib.Interface.IDisposable;

import com.greensock.TweenMax;

import flash.display.Bitmap;
import flash.display.Shape;

import flash.display.Sprite;
import flash.filters.BlurFilter;
import flash.utils.clearTimeout;
import flash.utils.setTimeout;

public class CBitmapNumberTextRolling extends Sprite implements IDisposable
{
    private var m_pTween:TweenMax;
    private var m_pSpr:Sprite;
    private var m_arrBmp:Array;
    private var m_bIsDown:Boolean;
    private var m_pCallback:Function;
    private var m_pBmp:Bitmap;
    private var m_iDh:int;
    private var m_pMask:Bitmap;
    private var m_iTimeId:int;
    private var m_pShape:Shape;

    private static var _filter:BlurFilter = new BlurFilter(0,10);

    public function CBitmapNumberTextRolling()
    {
    }

    public function init(from:int, to:int, w:int, h:int, bitmapDatas:Array, isDown:Boolean = false):void
    {
        m_bIsDown = isDown;
        var num:int = 0;
        var dir:int = 1;
        if(isDown)
        {
            dir = -1;
        }

        m_pSpr = CUIFactory.getSprite();
        this.addChild(m_pSpr);
        m_arrBmp = [];
        var len:int = to > from ? to : 10 + to;
        var isAdd:Boolean = true;
        for(var i:int = from; i <= len; i++)
        {
            isAdd = !isAdd;
            if(i != from && i != len && len > 5 && isAdd)
            {
                continue;
            }

            var index:int = i % 10;
            var bmp:Bitmap = CUIFactory.getBitmap();
            bmp.y = h * num * dir;
            m_iDh = bmp.y;
            bmp.bitmapData = bitmapDatas[index];
            m_arrBmp.push(bmp);
            m_pSpr.addChild(bmp);
            num++;
        }

        m_pMask = CUIFactory.getBitmap();
        m_pMask.bitmapData = bitmapDatas[0];
        this.addChild(m_pMask);
        this.mask = m_pMask;
    }

    public function rolling(controlBmp:Bitmap, duration:Number = 1.0, callback:Function = null):void
    {
        m_pBmp = controlBmp;
        m_pCallback = callback;
        m_pSpr.y = 0;
        m_pBmp.visible = false;

        m_pSpr.filters = [_filter];

        m_pTween = TweenMax.to(m_pSpr, duration, {y:-m_iDh, onComplete:tweenEnd});

        m_iTimeId = setTimeout(function():void
        {
            if(m_pCallback)
            {
                m_pCallback.apply();
                m_pCallback = null;
            }
        }, 100);
    }

    private function tweenEnd():void
    {
        m_pSpr.filters = [];

        if(m_pBmp != null)
        {
            m_pBmp.visible = true;
            m_pBmp = null;
        }
//            if(m_pCallback != null)
//            {
//                m_pCallback.apply();
//                m_pCallback = null;
//            }

        CDisplayUtil.delNotUse(m_arrBmp, 0);
        m_arrBmp = null;

        if(m_pSpr != null)
        {
            CUIFactory.disposeDisplayObj(m_pSpr);
            m_pSpr = null;
        }

        if(m_pShape)
        {
            CUIFactory.disposeDisplayObj(m_pShape);
            m_pShape = null;
        }
    }

    public function dispose():void
    {
        if(m_pTween != null)
        {
            m_pTween.kill();
            m_pTween = null;
        }

        if(m_iTimeId)
        {
            clearTimeout(m_iTimeId);
            m_iTimeId = 0;
        }

        if(m_pBmp != null)
        {
            m_pBmp.visible = true;
            m_pBmp = null;
        }

        CDisplayUtil.delNotUse(m_arrBmp, 0);
        m_arrBmp = null;
        m_pCallback = null;

        if(m_pSpr != null)
        {
            CUIFactory.disposeDisplayObj(m_pSpr);
            m_pSpr = null;
        }

        if(m_pMask != null)
        {
            CUIFactory.disposeDisplayObj(m_pMask);
            m_pMask = null;
        }
    }
}
}
