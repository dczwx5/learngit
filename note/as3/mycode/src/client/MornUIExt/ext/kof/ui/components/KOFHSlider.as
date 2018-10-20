//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/7.
 * Time: 17:05
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.HSlider;
import morn.core.components.Label;
import morn.core.handlers.Handler;

public class KOFHSlider extends HSlider {
    private var _completeHandler:Handler=null;
    public function KOFHSlider( skin : String = null ) {
        super( skin );
    }

    override protected function onStageMouseUp(e:MouseEvent):void
    {
        super.onStageMouseUp(e);
        if(_completeHandler)
        {
            _completeHandler.execute();
        }
    }

    /**数据变化处理器*/
    public function get scrollCompleteHandler():Handler {
        return _completeHandler;
    }

    public function set scrollCompleteHandler(value:Handler):void {
        _completeHandler = value;
    }

    public function get lable():Label
    {
        return _label;
    }
}
}
