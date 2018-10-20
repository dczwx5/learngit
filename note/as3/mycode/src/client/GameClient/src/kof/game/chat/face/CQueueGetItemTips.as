//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2018/4/25.
 */
package kof.game.chat.face {

import com.greensock.TweenLite;

import kof.ui.chat.ItemGetTipsViewUI;

import morn.core.components.Component;

public class CQueueGetItemTips extends Component {

    public var msgAlertUI:ItemGetTipsViewUI;
    public var yTween:TweenLite;
    public var fadeInAlphaTween:TweenLite;
    public var fadeOutAlphaTween:TweenLite;

    public static const NORMAL_TIPS:int = 0;
    public static const WARNING_TIPS:int = 1;

    private var color:String = "#ffffff";

    public var msgStr : String = '';

    public function CQueueGetItemTips() {
        super();
        msgAlertUI = new ItemGetTipsViewUI();
        addChild(msgAlertUI);

        mouseEnabled = false;
        mouseChildren = false;


    }

    public function set type( value:int):void{
//        if( value == NORMAL_TIPS ){
//            msgAlertUI.clip_bg.index = 0 ;
////            color = "#ff00";
//        } else{
//            msgAlertUI.clip_bg.index = 1 ;
////            color = "#ff0000";
//        }
    }
    public function set msg( value:String):void{
        msgStr = value;
//        msgAlertUI.txt.text = "<font color = '" + color + "'>" + value + "</font>" ;
        msgAlertUI.txt.text = value  ;
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
