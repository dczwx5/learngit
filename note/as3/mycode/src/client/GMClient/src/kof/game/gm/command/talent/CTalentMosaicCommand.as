//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/12.
 * Time: 11:56
 */
package kof.game.gm.command.talent {

import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/12
     */
    public class CTalentMosaicCommand extends CAbstractConsoleCommand {
        public function CTalentMosaicCommand( name : String = null, desc : String = null ) {
            super( name, desc );
            this.name = "talent_mosaic";
            this.description = "斗魂镶嵌，Usage：" + this.name + " 斗魂点id"+" 斗魂id";
            this.label = "斗魂镶嵌";

            this.syncToServer = true;
        }
    }
}
