/*
 ------------------------------------------------------------------------------
 Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 ------------------------------------------------------------------------------
 */


/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 11:45
 */
package kof.game.gm.command.sige {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;


/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CRefreshSignDaysCommand extends CAbstractConsoleCommand {
        public function CRefreshSignDaysCommand( name : String = null, desc : String = null ) {
            super( name, desc );
            this.name = "refresh_sign_days";
            this.description = "刷新签到天数，Usage：" + this.name;
            this.label = "刷新签到天数";

            this.syncToServer = true;
        }
    }
}
