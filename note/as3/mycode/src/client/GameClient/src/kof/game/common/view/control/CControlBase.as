//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/26.
 */
package kof.game.common.view.control {

import QFLib.Interface.IDisposable;
import kof.framework.CAppSystem;
import kof.game.common.view.CViewBase;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

public class CControlBase implements IDisposable {
    public function CControlBase() {
    }

    public function dispose() : void {

    }

    public virtual function create() : void {

    }

    public function set window(v:CViewBase) : void {
        _wnd = v;
    }
    public function setSystem(v:CAppSystem) : void {
        _system = v;
    }
    public function get uiCanvas() : IUICanvas {
        return (_system.stage.getSystem(IUICanvas) as IUICanvas);
    }
    public function get uiSystem() : CUISystem {
        return uiCanvas as CUISystem;
    }

    protected var _wnd:CViewBase;
    protected var _system:CAppSystem;
}
}
