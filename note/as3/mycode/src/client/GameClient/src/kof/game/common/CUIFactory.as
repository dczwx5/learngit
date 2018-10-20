//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/10.
 */
package kof.game.common {

import QFLib.Memory.CResourcePool;
import QFLib.Memory.CResourcePools;

import avmplus.getQualifiedClassName;

import flash.display.Bitmap;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.utils.getDefinitionByName;

import kof.game.playerCard.util.CTransformSpr;

import morn.core.components.Component;

import morn.core.components.Image;

public class CUIFactory {

    public static var resourcePools:CResourcePools;

    public function CUIFactory() {
    }

    public static function getResourcePool(cls:Class):CResourcePool
    {
        if(resourcePools == null)
        {
            resourcePools = new CResourcePools();
        }

        var pool:CResourcePool;
        var qualifiedName:String = getQualifiedClassName(cls);
        pool = resourcePools.getPool(qualifiedName);
        if(pool == null)
        {
            pool = new CResourcePool(qualifiedName, cls);
            resourcePools.addPool(qualifiedName, pool);
        }

        return pool;
    }

    public static function getDisplayObj(cls:Class):DisplayObject
    {
        var pool:CResourcePool = getResourcePool(cls);
        return pool.allocate() as DisplayObject;
    }

    public static function disposeDisplayObj(obj:DisplayObject):void
    {
        if(obj)
        {
            obj.x = 0;
            obj.y = 0;
            obj.scaleX = 1;
            obj.scaleY = 1;
            obj.alpha = 1;
            obj.filters = null;
            obj.visible = true;
            obj.rotation = 0;
            obj.mask = null;

            if(obj is Bitmap)
            {
                (obj as Bitmap).bitmapData = null;
            }

            if(obj is Component)
            {
                (obj as Component).dataSource = null;
            }

            if(obj.parent)
            {
                obj.parent.removeChild(obj);
            }

            var qualifiedName:String = getQualifiedClassName(obj);
            var cls:Class = getDefinitionByName(qualifiedName) as Class;
            var pool:CResourcePool = getResourcePool(cls);
            pool.recycle(obj);
        }
    }

    public static function getBitmap():Bitmap
    {
        return getDisplayObj(Bitmap) as Bitmap;
    }

    public static function disposeBitmap(bmp:Bitmap):void
    {
        if(bmp)
        {
            bmp.bitmapData = null;
            disposeDisplayObj(bmp);
        }
    }

    public static function getImage():Image
    {
        return getDisplayObj(Image) as Image;
    }

    public static function disposeImage(image:Image):void
    {
        if(image)
        {
            image.url = "";
            disposeDisplayObj(image);
        }
    }

    public static function getSprite():Sprite
    {
        return getDisplayObj(Sprite) as Sprite;
    }

    public static function getBitmapNumberText():CBitmapNumberText
    {
        return getDisplayObj(CBitmapNumberText) as CBitmapNumberText;
    }

    public static function getBitmapNumberTextRolling():CBitmapNumberTextRolling
    {
        return getDisplayObj(CBitmapNumberTextRolling) as CBitmapNumberTextRolling;
    }

    public static function getTransformSpr():CTransformSpr
    {
        return getDisplayObj(CTransformSpr) as CTransformSpr;
    }

    /**
     *
     * @param x
     * @param y
     * @param cellWidth 单个数字宽
     * @param cellHeight 单个数字高
     * @param url 数字图片url(skin)
     * @param parent
     * @param gap 数字间间距
     * @param align 对其方式(Left/Mid/Right)
     * @param defaulText 默认值
     * @param picNum 数字个数，从0开始(如 012345 则picNum为5)
     * @return
     */
    public static function gBitmapNumberText(x:int, y:int, cellWidth:Number, cellHeight:Number, url:String,
                                             parent:DisplayObjectContainer = null, gap:int = -1,
                                             align:int = 0, defaulText:String = "", picNum:int = 9):CBitmapNumberText
    {
        var bmpText:CBitmapNumberText = CUIFactory.getBitmapNumberText();
        bmpText.isDisposed = false;
        bmpText.setStyle(url, cellWidth, cellHeight, gap, picNum);

        bmpText.x = x;
        bmpText.y = y;
        bmpText.align = align;
        bmpText.text = defaulText;
        if(parent)
        {
            parent.addChild(bmpText);
        }

        return bmpText;
    }

    public static function createBitmap(x:Number = 0, y:Number = 0, parent:DisplayObjectContainer = null):Bitmap
    {
        var bmp:Bitmap = CUIFactory.getBitmap();
        CDisplayUtil.setObjAttr(bmp, x, y, -1, -1, parent);
        return bmp;
    }
}
}
