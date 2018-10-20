//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/4/18.
 */
package kof.game.switching {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.CAppSystem;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.CSystemBundleContext;
import kof.game.bundle.ISystemBundle;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.view.playerNew.enumNew.EHeroDevelopPanelName;
import kof.table.SystemIDs;
import kof.ui.CUISystem;

// 通用跳转入口
public class CSwitchingJump {
    public static function jump(system:CAppSystem, sysTag:String, shopType:int = -1) : void {
        var uiCanvas:CUISystem;
        var pSwitch:CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;
        if (!pSwitch.isSystemOpen(sysTag)) {
            uiCanvas = system.stage.getSystem(CUISystem) as CUISystem;
            uiCanvas.showMsgAlert(CLang.Get("common_system_not_open"));
            return ;
        }

        var pBundleCtx : CSystemBundleContext = system.stage.getSystem( CSystemBundleContext ) as CSystemBundleContext;
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pSysIDsTable:IDataTable = pDatabase.getTable(KOFTableConstants.SYSTEM_IDS);

        var openTagID:String = _findParentTag(pSysIDsTable, sysTag);
        if (!openTagID)
            return ;

        var pBundle:ISystemBundle = pBundleCtx.getSystemBundle( SYSTEM_ID( openTagID ) );
        if (sysTag == KOFSysTags.MALL && shopType != -1) {
            pBundleCtx.setUserData(pBundle, "shop_type", [shopType]);
        }
        pBundleCtx.setUserData(pBundle, CBundleSystem.ACTIVATED, true); // 有的在上面的操作就已经包含了active = true

        var pPlayerSystem:CPlayerSystem;
        switch (sysTag) {
            case KOFSysTags.HERO_LEVEL_UP :
                pPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                pPlayerSystem.showHeroMainWinByName(EHeroDevelopPanelName.NAME_HERO_DEVELOP);
                break;
            case KOFSysTags.SKIL_LEVELUP :
            case KOFSysTags.SKIL_BREAK :
                pPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                pPlayerSystem.showHeroMainWinByName(EHeroDevelopPanelName.NAME_SKILL_DEVELOP);
                break;
            case KOFSysTags.EQP_STRONG :
            case KOFSysTags.EQP_BREAK :
            case KOFSysTags.EQP_ATTSTRONG :
            case KOFSysTags.EQP_HPSTRONG :
                pPlayerSystem = system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
                pPlayerSystem.showHeroMainWinByName(EHeroDevelopPanelName.NAME_EQUIP_DEVELOP);
                break;

            case KOFSysTags.CLUB_GAME :
                var pClubSystem:CClubSystem = system.stage.getSystem(CClubSystem) as CClubSystem;
                var pClubMgr:CClubManager = pClubSystem.getHandler(CClubManager) as CClubManager;
                if (pClubMgr) {
                    if (pClubMgr.clubID && pClubMgr.clubID.length > 0) {
                        pClubSystem.showGameView();
                    } else {
                        uiCanvas = system.stage.getSystem(CUISystem) as CUISystem;
                        uiCanvas.showMsgAlert(CLang.Get("club_no_club"));
                    }
                }

                break;
        }

        var bCurrentValue:Boolean = pBundleCtx.getUserData(pBundle, CBundleSystem.ACTIVATED, false);
        if (!bCurrentValue) {
        }

    }

    private static function _findParentTag(pSysIDsTable:IDataTable, sysTag:String) : String {
        var findList:Array = pSysIDsTable.findByProperty("Tag", sysTag);
        if (!findList || findList.length == 0) {
            return null;
        }
        var sysIDRecord:SystemIDs = findList[0];
        var openTagID:String;
        if (sysIDRecord.ParentID > 0) {
            var parentRecord:SystemIDs = pSysIDsTable.findByPrimaryKey(sysIDRecord.ParentID);
            if (!parentRecord) {
                return null;
            }
            return parentRecord.Tag;
        } else {
            openTagID = sysTag;
        }
        return openTagID;
    }
}
}
