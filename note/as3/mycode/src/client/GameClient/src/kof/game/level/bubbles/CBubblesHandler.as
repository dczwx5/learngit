//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/9.
 */
package kof.game.level.bubbles {

import kof.game.level.*;

import QFLib.Interface.IUpdatable;

import kof.framework.CAbstractHandler;
import kof.game.bubbles.IBubblesFacade;
import kof.game.core.CGameObject;

public class CBubblesHandler extends CAbstractHandler implements IBubblesFacade, IUpdatable {

    private var _bubblesViewHandler : CBubblesViewHandler;

    private var _bubblesSwitch : Boolean;

    public function CBubblesHandler() {
        super();
        _bubblesSwitch = true;
    }

    override protected function onSetup():Boolean {
        var ret : Boolean = super.onSetup();
        ret = ret && this.addBean( _bubblesViewHandler = new CBubblesViewHandler() );
        return ret;
    }

    public function bubblesTalk( actor:CGameObject, value:String, time:int, position:int = 0, x:int = 0, y:int = 0,  hideCallBack:Function = null, type:int = 0):void{
        _bubblesViewHandler.addBubbles(actor, value, time, position, x, y, hideCallBack, type);
    }

    public function update(delta : Number):void{
        if(_bubblesViewHandler && _bubblesSwitch)
            _bubblesViewHandler.update(delta);
    }

    public function hideTalk(actor:CGameObject):void{
        _bubblesViewHandler.hide(actor);
    }

    public function stopBubblesTalk():void{
        _bubblesSwitch = false;
        _bubblesViewHandler.hideAll();
    }

    public function startBubblesTalk():void{
        _bubblesSwitch = true;
    }
}
}
