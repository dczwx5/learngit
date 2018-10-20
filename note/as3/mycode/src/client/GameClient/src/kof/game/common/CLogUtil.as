//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/8/29.
 */
package kof.game.common {

import kof.framework.CAppSystem;
import kof.game.player.CPlayerHandler;
import kof.game.player.CPlayerSystem;

public class CLogUtil {
    public function CLogUtil() {
    }

    /**
     * 页面打点记录
     * @param logId
     */
    public static function recordLinkLog(system:CAppSystem, logId:int):void
    {
        if(system)
        {
            var playerSystem:CPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
            if(playerSystem && playerSystem.enabled)
            {
                (playerSystem.getHandler(CPlayerHandler) as CPlayerHandler).linkLogRequest(logId);
            }
        }
    }
}
}
