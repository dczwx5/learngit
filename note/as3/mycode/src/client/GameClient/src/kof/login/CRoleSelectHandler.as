//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.login {

import QFLib.Application.Component.CContainerLifeCycle;

/**
 * 角色选择功能控制器
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CRoleSelectHandler extends CContainerLifeCycle {

    /**
     * Constructor
     */
    public function CRoleSelectHandler() {
        super();
    }

    private var _view:CRoleSelectView;

    public function get view():CRoleSelectView {
        return _view;
    }

    override protected function doStart():Boolean {
        var ret:Boolean = super.doStart();

        this.addBean((_view = new CRoleSelectView()));

        return ret;
    }

    override protected function doStop():Boolean {
        var ret:Boolean = super.doStop();

        this.removeBean(_view);

        return ret;
    }

    override public function dispose():void {
        super.dispose();
        _view = null;
    }

}
}
