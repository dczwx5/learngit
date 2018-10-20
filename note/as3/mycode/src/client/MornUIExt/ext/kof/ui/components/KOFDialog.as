//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/1/23.
 */
package kof.ui.components {

import flash.events.MouseEvent;

import morn.core.components.Button;

import morn.core.components.Dialog;

public class KOFDialog extends Dialog {

    public function KOFDialog() {

    }

    /**默认按钮处理*/
    protected override function onClick(e:MouseEvent):void {
        var btn:Button = e.target as Button;
        if (btn) {
            switch (btn.name) {
                case CLOSE:
                    if (_closeHandler != null) {
                        _closeHandler.executeWith([btn.name]);
                    }
                    break;
                case CANCEL:
                case SURE:
                case NO:
                case OK:
                case YES:
                    close(btn.name);
                    if (_closeHandler != null) {
                        _closeHandler.executeWith([btn.name]);
                    }
                    break;
            }
        }
    }

    public override function close(type:String = null):void {
        App.dialog.close(this);
    }

}
}