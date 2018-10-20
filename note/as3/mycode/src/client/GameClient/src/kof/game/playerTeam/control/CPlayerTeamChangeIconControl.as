//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/10/27.
 */
package kof.game.playerTeam.control {

import kof.game.player.enum.EPlayerWndResType;
import kof.game.playerTeam.CPlayerTeamManager;
import kof.game.common.view.event.CViewEvent;
import kof.game.playerTeam.view.CPlayerTeamChangeImageViewHandler;

public class CPlayerTeamChangeIconControl extends CPlayerTeamControlerBase {
    public function CPlayerTeamChangeIconControl() {
        super();
    }

    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }

    private function _onUIEvent(e:CViewEvent) : void {
        if (e.subEvent == CViewEvent.OK) {
            var iconID:int = (_wnd as CPlayerTeamChangeImageViewHandler).getSelectIcon();
            var type:int = e.data as int;
            var curHeadID:int;
            if (-1 != iconID) {
                if (type == EPlayerWndResType.TYPE_CHANGE_ICON) {
                    // 头像
                    curHeadID = (_system.getBean(CPlayerTeamManager) as CPlayerTeamManager).playerData.teamData.useHeadID;
                    if (iconID != curHeadID) {
                        netHandler.sendChangeHead(iconID);
                    }
                } else {
                    curHeadID = (_system.getBean(CPlayerTeamManager) as CPlayerTeamManager).playerData.teamData.prototypeID;
                    if (iconID != curHeadID) {
                        netHandler.sendChangeTeamModel(iconID);
                    }
                }
            }
        }
    }


}
}
