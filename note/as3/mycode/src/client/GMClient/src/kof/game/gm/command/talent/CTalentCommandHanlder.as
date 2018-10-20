/*
 ------------------------------------------------------------------------------
 Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 ------------------------------------------------------------------------------
 */


/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/13.
 * Time: 15:30
 */
package kof.game.gm.command.talent {

import kof.game.gm.command.gmaeCore.CAbstractCommandHandler;


/**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/13
     */
    public class CTalentCommandHanlder extends CAbstractCommandHandler {
        public function CTalentCommandHanlder() {
            super();
        }

        override public function dispose() : void {
            super.dispose();
        }

        override protected virtual function onSetup() : Boolean {
            var ret : Boolean = super.onSetup();
            ret = ret && this.registerConsoleCommand( new CAddSoulCommand() );
            ret = ret && this.registerConsoleCommand( new CTalentMosaicCommand() );
            ret = ret && this.registerConsoleCommand( new CTalentOpenCommand() );
            ret = ret && this.registerConsoleCommand( new CTalentTakeOffCommand() );

            return ret;
        }
    }
}
