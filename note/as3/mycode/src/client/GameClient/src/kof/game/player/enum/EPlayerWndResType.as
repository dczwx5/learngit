//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by AUTO on 2016/9/26.
 */
package kof.game.player.enum {

import kof.ui.imp_common.ItemTipsUI;
import kof.ui.imp_common.ItemUIUI;
import kof.ui.master.Artifact.ArtifactItemUI;
import kof.ui.master.Equipment.EquTrainUI;
import kof.ui.master.player_team.PlayerTeamUI;
import kof.ui.master.player_team.TeamSetUpUI;
import kof.ui.master.player_team.TeamUpLVUI;

public class EPlayerWndResType {
        public static const HERO_MAIN : Array = [[EquTrainUI,ItemTipsUI], ["skillbreach.swf", "frameclip_role.swf", "frameclip_bguang.swf"]];
        public static const HERO_GET : Array = [, ["role_get.swf", "roleget.swf"]]; // [ [ "role_get.swf", "roleget.swf" ] ]; // 后面那个是特效
        public static const ITEM_BATCH_USE : Array = [];

//        public static const PLAYER_TEAM_INFO : Array = [[PlayerInfoUI]];
        public static const PLAYER_TEAM_CREATE : Array = [[TeamSetUpUI]];
        public static const PLAYER_TEAM_LEVEL_UP : Array = [[TeamSetUpUI, TeamUpLVUI]];
//        public static const PLAYER_TEAM_CHANGE_NAME_CONFIRM : Array = [ [ "roleteam.swf", "messageprompt.swf" ] ];


        public static const TYPE_CHANGE_ICON:int = 0;
        public static const TYPE_CHANGE_MODEL:int = 1;
        // new team
        public static const TEAM_NEW_MAIN:Array = [[PlayerTeamUI, ArtifactItemUI, ItemUIUI]];
    }
}
