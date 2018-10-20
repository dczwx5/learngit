//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 11:59
 */
package kof.game.gm.command.talent {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CTalentTakeOffCommand extends CAbstractConsoleCommand {
        public function CTalentTakeOffCommand( name : String = null, desc : String = null) {
            super( name, desc );
            this.name = "talent_takeoff";
            this.description = "卸下斗魂，Usage：" + this.name + " 0卸下当前斗魂点上的斗魂/1一键卸下当前斗魂页所有斗魂"+" 斗魂页类型: 1 本源; 2 出战; 3 特质; 4 相克; 5 招式"+" 斗魂点id";
            this.label = "卸下斗魂";

            this.syncToServer = true;
        }
    }
}
