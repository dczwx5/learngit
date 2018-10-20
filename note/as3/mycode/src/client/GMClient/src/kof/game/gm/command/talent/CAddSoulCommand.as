//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 12:02
 */
package kof.game.gm.command.talent {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CAddSoulCommand extends CAbstractConsoleCommand {
        public function CAddSoulCommand( name : String = null, desc : String = null ) {
            super( name, desc );
            this.name = "add_soul";
            this.description = "添加斗魂，Usage：" + this.name + "斗魂id" ;
            this.label = "添加斗魂";

            this.syncToServer = true;
        }
    }
}
