//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/23.
 */
package kof.game.common {

import com.greensock.TimelineLite;
import com.greensock.TweenMax;
import com.greensock.easing.Back;

import flash.display.Bitmap;

import flash.geom.Point;

import kof.framework.CAppSystem;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

import morn.core.components.Image;

/**
 * 获得经验、战力增加的时候，从界面处飘到经验条或者左上角战力显示那里的效果
 */
public class CFlyPointEffect
{
    private static var _instance:CFlyPointEffect;

    private var m_pCallback:Function;
    private var m_arrTweens:Array = [];
    private var m_arrCurrBmp:Array = [];
    private var m_pPointImg:Image;
    private var m_bIsPlaying:Boolean;

    public function CFlyPointEffect()
    {
    }

    public static function get instance():CFlyPointEffect
    {
        if(_instance == null)
        {
            _instance = new CFlyPointEffect();
        }

        return _instance;
    }

    /**
     * num个光点，以sp点为中心r为半径随机散开， 然后再tween到ep点结束
     * @param sp
     * @param ep
     * @param num
     * @param r
     *
     */
    public function play(sp:Point, ep:Point, system:CAppSystem, num:int = 30, r:int = 80, callback:Function = null,
                         isTweeningNotStop:Boolean = false):void
    {
        m_pCallback = callback;
        if(isTweeningNotStop && m_arrTweens != null && m_arrTweens.length > 0)
        {
            return;
        }

        dispose();

        m_bIsPlaying = true;

        for(var i:int = 0; i < num; i++)
        {
            var bmp:Bitmap = getBmp();
            (system.stage.getSystem(IUICanvas) as CUISystem).effectLayer.addChild(bmp);
            var tween:TimelineLite = getLite(i);

            m_arrCurrBmp.push(bmp);
            var randx:int = (Math.random() - 0.5) * 2 * r;
            var randy:int = (Math.random() - 0.5) * 2 * r;
            bmp.x = sp.x;
            bmp.y = sp.y;
            bmp.scaleX = bmp.scaleY = 0.5;
//            var scale:Number = 0.6 + Math.random() * 0.4;
            var scale:Number = 0.1 + Math.random() * 0.9;

            //贝塞尔曲线的中间点
            var per:Number = 0.15 + Math.random() * 0.7;
            var tmpY:int = per * sp.y + (1 - per) * ep.y + (0.5 - Math.random()) * 50;
            var tmpX:int = per * sp.x + (1 - per) * ep.x  + (0.5 - Math.random()) * 50;
            var time:Number;
            var time1:Number = 0.9;
            if(i == num - 1)
            {
                tween.append(TweenMax.to(bmp, time1, {"x":sp.x+randx, "y":sp.y+randy, "scaleX":scale,
                    "scaleY":scale}));
                var toX:int = ep.x + (Math.random()*0.5)*10;
                var toY:int = ep.y + (Math.random()*0.5)*10;
                tween.append(TweenMax.to(bmp, 1, {"x":toX, "y":toY, "scaleX":0.7, "scaleY":0.7,
//                    "bezierThrough":[{"x":tmpX, "y":tmpY}]}));
                    "bezier":[{"x":tmpX, "y":tmpY},{"x":toX, "y":toY}]}));
                tween.append(TweenMax.to(bmp, 0.2, {"x":ep.x+(randx), "y":ep.y+(randy),
                    "alpha":0.7, "onComplete":tweenEnd}));
            }
            else
            {
                time = 0.5 + Math.random()*0.4;
                tween.append(TweenMax.to(bmp, time, {"x":sp.x+randx, "y":sp.y+randy,
                    "scaleX":scale, "scaleY":scale}));
                toX = ep.x + (Math.random()*0.5)*10;
                toY = ep.y+ (Math.random()*0.5)*10;
                tween.append(TweenMax.to(bmp, 1, {"x":toX, "y":toY, "scaleX":0.7, "scaleY":0.7,
                    "bezier":[{"x":tmpX, "y":tmpY},{"x":toX, "y":toY}]}));
                tween.append(TweenMax.to(bmp, 0.2, {"delay":time1-time, "x":ep.x+(randx), "y":ep.y+(randy),
                    "alpha":0.7}));
            }
        }
    }

    private function tweenEnd():void
    {
        dispose();

        if(m_pCallback != null)
        {
            m_pCallback.apply();
            m_pCallback = null;
        }

        m_bIsPlaying = false;
    }

    public function dispose():void
    {
        if(m_arrTweens != null && m_arrTweens.length > 0)
        {
            for each(var lite:TimelineLite in m_arrTweens)
            {
                if(lite != null && lite._active)
                {
                    lite.kill();
                    lite.clear();
                }
            }
        }
        m_arrTweens = [];
        if(m_arrCurrBmp != null && m_arrCurrBmp.length > 0)
        {
            for each(var bmp:Bitmap in m_arrCurrBmp)
            {
                CUIFactory.disposeBitmap(bmp);
            }
        }
        m_arrCurrBmp = [];
    }

    private function getBmp():Bitmap
    {
        var bmp:Bitmap = CUIFactory.createBitmap(0, 0, null);

        if(m_pPointImg == null)
        {
            m_pPointImg = CUIFactory.getImage();
            m_pPointImg.url = "icon/common/point_huang.png";
        }

        bmp.bitmapData = m_pPointImg.bitmapData;
        bmp.visible = m_bVisible;
        return bmp;
    }

    private function getLite(index:int):TimelineLite
    {
        var timelineLite:TimelineLite = m_arrTweens[index];
        if(timelineLite == null)
        {
            timelineLite = new TimelineLite();
            m_arrTweens[index] = timelineLite;
        }

        return timelineLite;
    }

    private var m_bVisible:Boolean = true;
    public function set visible(value:Boolean):void
    {
        m_bVisible = value;

        if(m_arrCurrBmp != null && m_arrCurrBmp.length > 0)
        {
            for each(var bmp:Bitmap in m_arrCurrBmp)
            {
                if(bmp)
                {
                    bmp.visible = value;
                }
            }
        }
    }

    public function get visible():Boolean
    {
        return m_bVisible;
    }

    public function get isPlaying():Boolean
    {
        return m_bIsPlaying;
    }
}
}