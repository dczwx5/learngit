//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/5/20.
 */
package kof.util {

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.system.ApplicationDomain;

public class CBitmapNumber extends Sprite {
    private var formatStr:String = "0123456789.";
    private var isNumber:Boolean;
    public function CBitmapNumber(numStr:String,fontWidth:int)
    {
        _fontWidth = fontWidth;
        if(ApplicationDomain.currentDomain.hasDefinition(numStr))
        {
            var cls:Class = ApplicationDomain.currentDomain.getDefinition(numStr) as Class;
            _bd =  new cls(1,1) as BitmapData;
        }
        if(_bd)
        {
            _rect      = new Rectangle(0,0,fontWidth,_bd.height);
        }
        else
        {
            _rect      = new Rectangle(0,0,fontWidth,1);
        }
        _bm = new Bitmap(null);
        addChild(_bm);
    }

    private var _bd:BitmapData;
    private var _rect:Rectangle;
    private var _bm:Bitmap;
    private var _num:Object;
    private var _len:int;

    private var _fontWidth:int;
    private var _offsetX:int;

    public function get num():Object
    {
        return _num;
    }

    public function set num(value:Object):void
    {
        _num =  int(value);
        updateNum();
    }

    private function updateNum():void
    {
        if(_bm && _bm.bitmapData)
        {
            _bm.bitmapData.dispose();
        }
        var arr:Array = String(_num).split("");
        var pt:Point = new Point();
        if(_len > 0 && arr.length < _len)
        {//补齐0
            var k:int = _len - arr.length;
            while(k > 0)
            {
                arr.unshift(0);
                k --;
            }
        }
        _bm.bitmapData = new BitmapData(arr.length * _fontWidth, _rect.height, true, 0x00000000);
        for(var i:int = 0; i < arr.length; i++)
        {
            var index:int = formatStr.indexOf(arr[i]);
            _rect.x = _rect.width * index + _offsetX;
            _bm.bitmapData.copyPixels(_bd, _rect, pt, null, null, true);
            pt.x += _fontWidth;
        }
        width = _bm.bitmapData.width;
        _bm.x = - _bm.bitmapData.width / 2;
        _bm.y = - _bm.bitmapData.height / 2;
    }

//		public function dispose():void
//		{
//			ObjectUtils.instance.dispose(_bd);
//			_bd = null;
//			ObjectUtils.instance.dispose(_bm);
//			_bm = null;
//			_rect = null;
//			if(this.parent)
//			{
//				this.parent.removeChild(this);
//			}
//		}
}
}
