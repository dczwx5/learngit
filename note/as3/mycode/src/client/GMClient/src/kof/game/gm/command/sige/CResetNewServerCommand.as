//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 11:49
 */
package kof.game.gm.command.sige {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CResetNewServerCommand extends CAbstractConsoleCommand {
        public function CResetNewServerCommand( name : String = null, desc : String = null ) {
            super( name, desc );
            this.name = "reset_new_Server";
            this.description = "设置为新服，Usage：" + this.name;
            this.label = "设置为新服";

            this.syncToServer = true;
        }
    }
}
