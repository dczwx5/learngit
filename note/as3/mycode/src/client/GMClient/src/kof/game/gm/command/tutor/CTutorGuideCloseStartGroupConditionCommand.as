//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.gm.command.tutor {

import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorSystem;
import kof.game.gm.command.gmaeCore.CAbstractConsoleCommand;

/**
 * 关闭引导组的开启限制
 *
 * @author auto (auto@qifun.com)
 */
public class CTutorGuideCloseStartGroupConditionCommand extends CAbstractConsoleCommand {

    public function CTutorGuideCloseStartGroupConditionCommand() {
        super();

        this.name = "closeGuideGroupStartCondition";
        this.description = "关闭引导组的开启限制，Usage：" + this.name;
        this.label = "关闭引导开启限制";
    }

    override public function onCommand( args : Array ) : Boolean {
        // request server for entering instance.
        if ( super.onCommand( args ) ) {

            var pTutorSystem : CTutorSystem = this.system.stage.getSystem( CTutorSystem ) as CTutorSystem;
            if ( pTutorSystem ) {
                pTutorSystem.manager.tutorPlay._isStartGroupIgnoreOtherCondition = true;
                return true;
            }
        }

        return false;
    }
}
}
