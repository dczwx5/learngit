//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/9/22.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.Button;

import morn.core.components.Dialog;

public class BasePopupView extends Dialog {
    public function BasePopupView() {
        super();
    }

    /**默认按钮处理*/
    override protected function onClick(e:MouseEvent):void {
        App.dialog.close(this);
        var btn:Button = e.target as Button;
        if (btn) {
            switch (btn.name) {
                case CLOSE:
                    break;
                case CANCEL:
                    break;
                case SURE:
                    break;
                case NO:
                    break;
                case OK:
                    break;
                case YES:
//                    close(btn.name);
                    App.dialog.close(this);
                        trace("+++++++++++++++")
                    break;
            }
        }
    }
}
}
