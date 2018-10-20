//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/15.
 */
package kof.ui.component {

import com.greensock.TweenLite;

import kof.ui.master.messageprompt.MPOperationTipsUI;

import morn.core.components.Component;

public class CQueueTips extends Component {

    public var msgAlertUI:MPOperationTipsUI;
    public var yTween:TweenLite;
    public var fadeInAlphaTween:TweenLite;
    public var fadeOutAlphaTween:TweenLite;

    public static const NORMAL_TIPS:int = 0;
    public static const WARNING_TIPS:int = 1;

    private var color:String = "#ffffff";

    public var msgStr : String = '';

    public function CQueueTips() {
        super();
        msgAlertUI = new MPOperationTipsUI();
        addChild(msgAlertUI);

        mouseEnabled = false;
        mouseChildren = false;


    }

    public function set type( value:int):void{
        if( value == NORMAL_TIPS ){
            msgAlertUI.clip_bg.index = 0 ;
//            color = "#ff00";
        } else{
            msgAlertUI.clip_bg.index = 1 ;
//            color = "#ff0000";
        }
    }
    public function set msg( value:String):void{
        msgStr = value;
        msgAlertUI.txt.text = "<font color = '" + color + "'>" + value + "</font>" ;
        msgAlertUI.txt.width = msgAlertUI.txt.textField.textWidth + 15;
        if( msgAlertUI.txt.width < 321 )
            msgAlertUI.txt.width = 321 ;
    }

    public function reset():void
    {
        if (yTween)
        {
            yTween.kill();
            yTween=  null;
        }
        if (fadeInAlphaTween)
        {
            fadeInAlphaTween.kill();
            fadeInAlphaTween = null;
        }
        if (fadeOutAlphaTween)
        {
            fadeOutAlphaTween.kill();
            fadeOutAlphaTween = null;
        }
    }
}
}
