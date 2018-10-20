//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/9.
 */
package kof.game.common {

import QFLib.Interface.IDisposable;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.filters.BlurFilter;
import flash.geom.Matrix;
import flash.utils.Dictionary;
import flash.utils.Timer;

import morn.core.components.Image;
import morn.core.events.UIEvent;

public class CBitmapNumberText extends Sprite implements IDisposable
{
    public static const Left:int = 0;
    public static const Mid:int = 1;
    public static const Right:int = 2;

    private var m_pNumImg:Image;
    private var m_sText:String;
    private var m_sUrl:String;
    private var m_arrCurrBmp:Array = [];
    private var m_bIsNeedUpdate:Boolean = false;

    private var m_nCellWidth:Number = 16;
    private var m_nCellHeight:Number = 20;
    private var m_iGap:int = 2;
    private var m_pTimer:Timer;
    private var m_iTargetValue:int;
    private var m_iCurrRollIndex:int = 0;
    private var m_iRollDirection:int = 2;

    private var m_iRollingToValue:int;
    private var m_arrRollingTweens:Array;
    private var m_bIsLoaded:Boolean = false;
    private var m_iAlign:int;
    private var m_iPicNum:int = 13;
    private var m_iNumType:int;
    private var m_dicBmpData:Dictionary = new Dictionary();
    private var m_pCallBack:Function;

    private var m_bIsDisposed:Boolean;

    private static var _customCharIndexDic:Dictionary = new Dictionary();
    private var m_pCustomCharIndexObj:Object;
    private static const _charIndexObj:Object = {"0":0, "1":1, "2":2, "3":3, "4":4, "5":5,
            "6":6, "7":7, "8":8, "9":9, "+":10, "-":11, "(":12, ")":13, "/":14
    };

    private static var _filter:BlurFilter = new BlurFilter(0,10);

    public function CBitmapNumberText()
    {
        super();
    }

    public function get picNum():int
    {
        return m_iPicNum;
    }

    public function set picNum(value:int):void
    {
        if(m_dicBmpData[m_sUrl] != null && value != (m_dicBmpData[m_sUrl] as Array).length - 1)
        {
            CTest.log(m_sUrl + "资源的picNum设置有冲突,请检查");
        }
        m_iPicNum = value;
    }

    public function dispose():void
    {
        m_bIsDisposed = true;

        _disposeRolling();
        m_pCustomCharIndexObj = null;
        CDisplayUtil.delNotUse(m_arrCurrBmp, 0, true);
        m_arrCurrBmp = [];
        m_bIsLoaded = false;
        m_iAlign = Left;

        _stopRun();
        m_sText = "";
        m_iRollingToValue = 0;
        if(m_sUrl)
        {
            m_pNumImg.removeEventListener(UIEvent.IMAGE_LOADED, _onLoadedHandler);
            m_sUrl = "";
        }

        if(m_pCallBack)
        {
            m_pCallBack = null;
        }

        m_iNumType = 0;
        m_iRollDirection = 2;

        CUIFactory.disposeDisplayObj(this);
    }

    private function _disposeRolling():void
    {
        if(m_arrRollingTweens != null && m_arrRollingTweens.length > 0)
        {
            for each(var rolling:CBitmapNumberTextRolling in m_arrRollingTweens)
            {
                rolling.dispose();
                CUIFactory.disposeDisplayObj(rolling);
            }

            m_arrRollingTweens.length = 0;
        }

        m_arrRollingTweens = null;
    }

    public function set text(value:String):void
    {
        if(m_sText == value)
        {
            return;
        }

        _disposeRolling();
        m_sText = value;
        m_bIsNeedUpdate = true;
        _updateText();
        _updateLayout();
    }

    public function get text():String
    {
        return m_sText;
    }

    public function setStyle(url:String, cellWidth:Number, cellHeight:Number, gap:int=2, picNum:int = 13):void
    {
        m_nCellWidth = cellWidth;
        m_nCellHeight = cellHeight;
        m_iGap = gap;

        m_sUrl = url;
        this.picNum = picNum;
        m_bIsNeedUpdate = true;
        if(m_dicBmpData[m_sUrl] != null)
        {
            m_bIsLoaded = true;
            _updateText();
            return;
        }

        if(m_sUrl)
        {
            if(m_pNumImg == null)
            {
                m_pNumImg = CUIFactory.getImage();
            }

            m_pNumImg.addEventListener(UIEvent.IMAGE_LOADED, _onLoadedHandler);
            m_pNumImg.skin = url;
        }
    }

    private function _onLoadedHandler(e:Event):void
    {
        m_pNumImg.removeEventListener(UIEvent.IMAGE_LOADED, _onLoadedHandler);

        m_bIsLoaded = true;
        if(m_sUrl != null && m_dicBmpData[m_sUrl] != null)
        {
            _updateText();
            _updateLayout();
            return;
        }

        _initBmpDatas(m_pNumImg.bitmapData);
        _updateText();
        _updateLayout();
        if(m_iRollingToValue > 0)
        {
            rollingToValue(m_iRollingToValue);
        }
    }

    private function _initBmpDatas(bmd:BitmapData):void
    {
        var bmps:Array = [];
        m_dicBmpData[m_sUrl] = bmps;
        for(var i:int = 0; i <= m_iPicNum; i++)
        {
            var data:BitmapData = new BitmapData(m_nCellWidth, m_nCellHeight, true, 0);
            data.draw(bmd, new Matrix(1, 0, 0, 1, -i * m_nCellWidth));
            bmps.push(data);
        }
    }

    /**
     * 当组件在滚动数字的时候,需要读当前数值不能读value,要读targetValue,因为滚动的过程value会一直改变
     * @return
     *
     */
    public function get targetValue():int
    {
        return m_iTargetValue;
    }

    public function addToValue(value:Number):void
    {
        if(m_iTargetValue == value)
        {
            return;
        }

        m_iTargetValue = value;
        if(m_pTimer == null)
        {
            m_pTimer = new Timer(50);
            m_pTimer.addEventListener(TimerEvent.TIMER, _onRuning);
        }
        else
        {
            m_pTimer.delay = 5;
            m_pTimer.stop();
            m_pTimer.reset();
        }

        m_pTimer.start();
    }

    private function _onRuning(e:TimerEvent):void
    {
        var speed:int = ((m_iTargetValue - int(this.text)) >> 1) + 1;
        this.text = (int(this.text) + speed).toString();

        var index:int = m_arrCurrBmp.length - speed.toString().length;
        var len:int = m_arrCurrBmp.length;
        for(var i:int = 0; i < len; i++)
        {
            if(i >= index)
            {
                if((m_arrCurrBmp[i] as Bitmap).filters.length == 0)
                {
                    (m_arrCurrBmp[i] as Bitmap).filters = [_filter];
                }
            }
            else
            {
                (m_arrCurrBmp[i] as Bitmap).filters = [];
            }
        }

        if(int(this.text) >= m_iTargetValue)
        {
            this.text = m_iTargetValue.toString();
            _stopRun();
        }
    }

    private function _stopRun():void
    {
        if(m_pTimer)
        {
            m_pTimer.stop();
            m_pTimer.removeEventListener(TimerEvent.TIMER, _onRuning);
            m_pTimer = null;
        }

        var len:int = m_arrCurrBmp.length;
        for(var i:int = 0; i < len; i++)
        {
            (m_arrCurrBmp[i] as Bitmap).filters = [];
        }

        m_iTargetValue = 0;
    }

    public function rollingToValue(value:int):void
    {
        var from:int = parseInt(m_sText);
        var to:int = value;

        m_iRollingToValue = value;
        if(!m_bIsLoaded)
        {
            return;
        }

        if(from == to)
        {
            return;
        }

        _disposeRolling();
        m_arrRollingTweens = [];
        var isDown:Boolean = true;
        var num:int = 0;

        while((from > 0 || to > 0))
        {
            if(to == 0 && num > 0)
            {
                CDisplayUtil.delNotUse(m_arrCurrBmp, num);
                break;
            }

            var rolling:CBitmapNumberTextRolling = CUIFactory.getBitmapNumberTextRolling();

            isDown = from % 10 > to % 10;
            rolling.init(from % 10, to % 10, m_nCellWidth + m_iGap, m_nCellHeight, m_dicBmpData[m_sUrl] as Array, isDown);
            from = from / 10;
            to = to / 10;
            m_arrRollingTweens.push(rolling);
            num++;
            if(num > m_arrCurrBmp.length)
            {
                _getBitmap(-1);
            }
        }

        m_sText = value.toString();
        m_bIsNeedUpdate = true;
        _updateLayout();

        // 开始控制
        m_iCurrRollIndex = 0;
        _startRolling();
    }

    private function _startRolling():void
    {
        if(m_bIsDisposed)
        {
            return;
        }

        var rolling:CBitmapNumberTextRolling = m_arrRollingTweens[m_iCurrRollIndex];
        if(rolling == null)
        {
            return;
        }

        var index:int = m_iRollDirection == Left ? m_iCurrRollIndex : (m_arrCurrBmp.length - m_iCurrRollIndex - 1);
        var dx:int = 0;
        var dir:int = 1;
        if(m_iAlign == Right)
        {
            dx = this.width;
        }
        else if(m_iAlign == Mid)
        {
            dx = (m_arrCurrBmp.length * (m_nCellWidth + m_iGap) - m_iGap) >> 1;
        }

        var bmp:Bitmap = _getBitmap(index);
        var data:BitmapData = _getBitmapData(m_sText.charAt(index));
        bmp.bitmapData = data;

        rolling.x = dir * index * (m_nCellWidth + m_iGap) - dx;
        this.addChild(rolling);

        m_iCurrRollIndex++;
        if(m_iCurrRollIndex < m_arrCurrBmp.length)
        {
            rolling.rolling(bmp, 0.3, _startRolling);
        }
        else
        {
            rolling.rolling(bmp,0.3, m_pCallBack);
        }
    }

    private function _updateLayout():void
    {
        if(m_bIsDisposed)
        {
            return;
        }

        var dx:int = 0;
        var dir:int = 1;
        if(m_iAlign == Right)
        {
            dx = this.width;
        }
        else if(m_iAlign == Mid)
        {
            dx = this.width >> 1;
        }

        var len:int = m_arrCurrBmp.length;
        for(var i:int = 0; i < len; i++)
        {
            var bmp:Bitmap = m_arrCurrBmp[i];
            bmp.x = dir * i * (m_nCellWidth + m_iGap) - dx;
        }
    }

    public function set gap(value:int):void
    {
        m_iGap = value;
        m_bIsNeedUpdate = true;
        _updateText();
    }

    private function _updateText():void
    {
        if(m_dicBmpData[m_sUrl] == null || !m_bIsNeedUpdate)
        {
            return;
        }
        m_bIsNeedUpdate = false;

        if(m_sText == null || m_sText == "")
        {
            CDisplayUtil.delNotUse(m_arrCurrBmp, 0, true);
            return;
        }

        for(var i:int = 0; i < m_sText.length; i++)
        {
            var str:String = m_sText.charAt(i);
            var data:BitmapData = _getBitmapData(str);
            if(data == null)
            {
                continue;
            }
            var bmp:Bitmap = _getBitmap(i);
            bmp.x = i * (m_nCellWidth + m_iGap);
            bmp.bitmapData = data;
        }

        CDisplayUtil.delNotUse(m_arrCurrBmp, m_sText.length, true);
    }

    private function _getBitmap(index:int):Bitmap
    {
        var bmp:Bitmap;
        if(index < 0)
        {
            bmp = CUIFactory.createBitmap(0, 0, this);
            m_arrCurrBmp.unshift(bmp);
            _updateLayout();
        }
        else
        {
            bmp = m_arrCurrBmp[index];
            if(bmp == null)
            {
                bmp = CUIFactory.createBitmap(0, 0, this);
                m_arrCurrBmp.push(bmp);
            }
        }

        return bmp;
    }

    private function _getBitmapData(str:String):BitmapData
    {
        var charIndexObj:Object = m_pCustomCharIndexObj;
        if(charIndexObj == null)
        {
            if(_customCharIndexDic[m_iNumType])
            {
                charIndexObj = m_pCustomCharIndexObj = _customCharIndexDic[m_iNumType];
            }
        }

        if(charIndexObj == null)
        {
            charIndexObj = _charIndexObj;
        }

        if(!charIndexObj.hasOwnProperty(str))
        {
            return null;
        }

        var index:int = int(charIndexObj[str]);
        return m_dicBmpData[m_sUrl][index] as BitmapData;
    }

// property===========================================================================================================
    public function get numType():int
    {
        return m_iNumType;
    }

    public function set numType(value:int):void
    {
        m_iNumType = value;
    }

    public function get align():int
    {
        return m_iAlign;
    }

    public function set align(value:int):void
    {
        m_iAlign = value;
        _updateLayout();
    }

    public function set value(value:int):void
    {
        this.text = value.toString();
    }

    public function get value():int
    {
        return int(this.text);
    }

    public function get customCharIndexObj():Object
    {
        return m_pCustomCharIndexObj;
    }

    public function set customCharIndexObj(value:Object):void
    {
        m_pCustomCharIndexObj = value;
    }

    public override function get width():Number
    {
//        if(m_sText == null || m_sText == "")
//        {
//            return super.width;
//        }

        var len:int = m_sText.length;
        return (len * m_nCellWidth + (len - 1) * m_iGap);
    }

    public override function get height():Number
    {
        return m_nCellHeight;
    }

    public function set rollDirection(value:int):void
    {
        m_iRollDirection = value;
    }

    public function get rollDirection():int
    {
        return m_iRollDirection;
    }

    public function set callBack(value:Function):void
    {
        m_pCallBack = value;
    }

    public function get callBack():Function
    {
        return m_pCallBack;
    }

    public function set isDisposed(value:Boolean):void
    {
        m_bIsDisposed = value;
    }
}
}
