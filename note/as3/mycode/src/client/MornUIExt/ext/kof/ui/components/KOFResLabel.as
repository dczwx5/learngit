//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/9/30.
 * Time: 17:01
 */
package kof.ui.components {

import flash.events.Event;

import morn.core.components.Label;

public class KOFResLabel extends Label {
    private var _postfix:String = ""; // 后缀
    private var _units:String = "";
    private var _originText:String = "";
    public function KOFResLabel( text : String = "", skin : String = null ) {
        super( text, skin );
    }

    public function get units():String
    {
        return _units;
    }

    public function set units(value:String):void
    {
        _units = value;
        modifyShow();
        changeText();
        sendEvent(Event.CHANGE);
    }

    override public function set text(value:String):void
    {
        if (_text != value) {
            _text = value || "";
            _text = _text.replace(/\\n/g, "\n");
            _originText = _text;
            //修改货币显示规则
            modifyShow();
            changeText();
            sendEvent(Event.CHANGE);
        }
    }

    protected function modifyShow():void
    {
        var nu:Number = Number(_text);
        if(!isNaN(nu))
        {
            if(this._units=="万"){
                if(nu<10000)
                {
                    _text = nu+"";
                }
                else if(nu>=10000&&nu<100000000)
                {
                    _text = int(nu/10000)+this.units;
                }
                else if(nu>=100000000)
                {
                    _text = 9999+this.units;
                }
            }else{
                _text = _originText+"";
            }

            _text = _text + _postfix;
        }
    }

    public function set postfix(v:String) : void {
        _postfix = v;
    }

}
}
