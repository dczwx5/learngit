//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/31.
 * Time: 15:25
 */
package kof.game.clubBoss {

import kof.framework.CAppSystem;
import kof.game.clubBoss.datas.CCBDataManager;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/31
 */
public class CFightControl {
    private var system : CAppSystem = null;

    public function CFightControl(system : CAppSystem) {
        this.system = system;
        _init();
    }

    private function _init():void{

    }
}
}
