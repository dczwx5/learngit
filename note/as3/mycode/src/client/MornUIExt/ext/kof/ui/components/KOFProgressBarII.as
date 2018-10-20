//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/11/17.
 */
package kof.ui.components {

import flash.geom.Rectangle;

import morn.core.components.Clip;
import morn.core.components.Image;
import morn.core.components.Label;

import morn.core.components.ProgressBar;

public class KOFProgressBarII extends ProgressBar {

    protected var _barClip:Clip;

    protected var _clipY:int = 1;

    public function KOFProgressBarII( skin : String = null ) {
        super( skin );
    }
    override protected function initialize():void {
        _barLabel.width = 200;
        _barLabel.height = 18;
        _barLabel.align = "center";
        _barLabel.stroke = "0x004080";
        _barLabel.color = 0xffffff;
    }
    override protected function createChildren():void {
        addChild(_bg = new Image());
//        addChild(_bar = new Image());
        addChild(_barClip = new Clip());
        addChild(_barLabel = new Label());
    }

    override public function set skin(value:String):void {
        if (_skin != value) {
            _skin = value;
            _bg.url = _skin;
//            _bar.url = _skin + "$bar";
            _barClip.url = _skin + "$bar";
            _contentWidth = _bg.width;
            _contentHeight = _bg.height;
            callLater(changeLabelPoint);
            callLater(changeValue);
        }
    }

    public function set font( value:String ) : void {
        _barLabel.font = value;
    }
    public function set bold( value:Object ) : void {
        _barLabel.bold = value;
    }
    public function set color( value:Object ) : void {
        _barLabel.color = value;
    }
    public function set size( value:Object ) : void {
        _barLabel.size = value;
    }
    public function set stroke( value:String ) : void {
        _barLabel.stroke = value;
    }
    /**切片Y轴数量*/
    public function get clipY():int {
        return _clipY;
    }

    public function set clipY(value:int):void {
        if (_clipY != value) {
            _clipY = value;
            _barClip.clipY = _clipY;
        }
    }
    /**当前帧，等同于frame*/
    public function get index():int {
        return _barClip.index;
    }

    public function set index(value:int):void {
        _barClip.index = value;
    }

    override protected function changeValue():void {
        if (sizeGrid) {
            var grid:Array = sizeGrid.split(",");
            var left:Number = grid[0];
            var right:Number = grid[2];
            var max:Number = width - left - right;
            var sw:Number = max * _value;
//            _bar.width = left + right + sw;
//            _bar.scrollRect = new Rectangle(0,0,left + right + sw, _bar.height);
            _barClip.scrollRect = new Rectangle(0,0,left + right + sw, _barClip.height);
//            _bar.visible = _bar.width > left + right;
        } else {
//            _bar.scrollRect = new Rectangle(0,0,width * _value, _bar.height);
            _barClip.scrollRect = new Rectangle(0,0,width * _value, _barClip.height);
        }
    }
}
}
