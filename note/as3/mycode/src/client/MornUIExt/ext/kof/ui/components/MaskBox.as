//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/7/28.
 */
package kof.ui.components {

import flash.display.Shape;

import morn.core.components.Component;
import morn.editor.core.IBox;

public class MaskBox extends Component implements IBox {
    private var _mask : Shape;

    protected var _maskX : int       = 0;

    protected var _maskY : int       = 0;

    protected var _maskWidth : int   = 0;

    protected var _maskHeight : int  = 0;

    protected var _maskType : String = "rect";

    public function MaskBox()
    {
        _mask = new Shape;
    }

    public function get maskX() : int
    {
        return _maskX;
    }

    public function set maskX(value : int) : void
    {
        _maskX = value;
        callLater(refreshMask);
    }

    public function get maskY() : int
    {
        return _maskY;
    }

    public function set maskY(value : int) : void
    {
        _maskY = value;
        callLater(refreshMask);
    }

    public function get maskWidth() : int
    {
        return _maskWidth;
    }

    public function set maskWidth(value : int) : void
    {
        _maskWidth = value;
        callLater(refreshMask);
    }

    public function get maskHeight() : int
    {
        return _maskHeight;
    }

    public function set maskHeight(value : int) : void
    {
        _maskHeight = value;
        callLater(refreshMask);
    }

    public function get maskType() : String
    {
        return _maskType;
    }

    public function set maskType(value : String) : void
    {
        _maskType = value;
        callLater(refreshMask);
    }

    private function refreshMask() : void
    {
        if (_maskHeight * _maskWidth == 0)
        {
            this.mask = null;
            if (_mask.parent != null)
            {
                _mask.parent.removeChild(_mask);
            }
        }
        else
        {
            _mask.graphics.clear();
            _mask.graphics.beginFill(0, 0);
            if (_maskType == "round")
            {
                _mask.graphics.drawEllipse(0, 0, _maskWidth, _maskHeight);
            }
            else
            {
                _mask.graphics.drawRect(0, 0, _maskWidth, _maskHeight);
            }
            _mask.graphics.endFill();
            if (_mask.parent == null)
            {
                this.addChild(_mask);
            }
            this.mask = _mask;
        }
        _mask.x = _maskX;
        _mask.y = _maskY;
    }

 }
}
