//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2017/9/28.
 */
package kof.game.reciprocation.marquee {

import com.greensock.TweenLite;

import kof.ui.master.main.PublicNoticeUI;

import morn.core.components.Component;

public class CMarqueeTips extends Component {

    private var m_marqueeUI:PublicNoticeUI;

    public var fadeInAlphaTween:TweenLite;
    public var fadeOutAlphaTween:TweenLite;


    public function CMarqueeTips() {
        super();

        m_marqueeUI = new PublicNoticeUI();
        addChild(m_marqueeUI);

        mouseChildren = false;
        mouseEnabled = false;
    }

    public function set msg(value:String):void{
        m_marqueeUI.txtLabel.text = value ;
    }

    public function reset():void
    {
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
