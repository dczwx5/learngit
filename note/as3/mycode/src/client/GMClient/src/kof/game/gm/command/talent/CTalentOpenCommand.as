//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 11:52
 */
package kof.game.gm.command.talent {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CTalentOpenCommand extends CAbstractConsoleCommand {
        public function CTalentOpenCommand( name : String = null, desc : String = null ) {
            super( name, desc );
            this.name = "talent_open";
            this.description = "开启斗魂，Usage：" + this.name +" 斗魂点id";
            this.label = "开启斗魂";

            this.syncToServer = true;
        }
    }
}
