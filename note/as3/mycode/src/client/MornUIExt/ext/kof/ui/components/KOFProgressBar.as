//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.ui.components {

import flash.geom.Rectangle;

import morn.core.components.ProgressBar;

public class KOFProgressBar extends ProgressBar {

    public function KOFProgressBar( skin : String = null ) {
        super( skin );
    }

    override protected function initialize():void {
//        _barLabel.text = "0";
        _barLabel.width = 200;
//        _barLabel.height = 18;
        _barLabel.align = "center";
        _barLabel.multiline = false;
        _barLabel.wordWrap = false;
        _barLabel.stroke = "0x004080";
        _barLabel.color = 0xffffff;
    }

    override protected function changeLabelPoint():void {
        _barLabel.x = (width - _barLabel.width) * 0.5;
        _barLabel.y = (height - _barLabel.height) * 0.5 - 1;
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
    override protected function changeValue():void {
        if (sizeGrid) {
            var grid:Array = sizeGrid.split(",");
            var left:Number = grid[0];
            var right:Number = grid[2];
            var max:Number = width - left - right;
            var sw:Number = max * _value;
//            _bar.width = left + right + sw;
            _bar.scrollRect = new Rectangle(0,0,left + right + sw, _bar.height);
//            _bar.visible = _bar.width > left + right;
        } else {
            _bar.scrollRect = new Rectangle(0,0,width * _value, _bar.height);
        }
        changeLabelPoint();
    }
}
}
