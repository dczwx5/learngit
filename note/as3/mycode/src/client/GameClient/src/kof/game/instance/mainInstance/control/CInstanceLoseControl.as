//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/11/3.
 */
package kof.game.instance.mainInstance.control {

import QFLib.Math.CMath;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.common.data.CErrorData;
import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.CInstanceExitProcess;
import kof.game.instance.mainInstance.data.CInstanceDataCollection;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.level.CLevelManager;
import kof.game.level.CLevelSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.player.enum.EPlayerWndTabType;
import kof.game.player.view.playerNew.enumNew.EHeroDevelopPanelName;
import kof.game.switching.CSwitchingJump;
import kof.game.switching.CSwitchingSystem;
import kof.table.Enhanceability;


public class CInstanceLoseControl extends CInstanceControler{
    public function CInstanceLoseControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.HIDE, _onHide);
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.HIDE, _onHide);
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        var errorData:CErrorData = null;
        var win:CViewBase;
        var dataCollection:CInstanceDataCollection;
        var playerSystem:CPlayerSystem;
        switch (subType) {
            case EInstanceViewEventType.INSTANCE_LOSE_JUMP :

                system.addExitProcess(null, null, function () : void {
                    var enhance:Enhanceability = e.data as Enhanceability;
                    CSwitchingJump.jump(system, enhance.TagID);
                }, null, 9999);


                system.removeExitProcess(null, CInstanceExitProcess.FLAG_INSTANCE);
                _wnd.close();

                break;
        }

    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem(CPlayerSystem) as CPlayerSystem;
    }

    private function _onHide(e:CViewEvent) : void {
        system.exitInstance();
        ((system.stage.getSystem(CLevelSystem) as CLevelSystem).getHandler(CLevelManager) as CLevelManager).levelID = 10000;
        _wnd.uiCanvas.showSceneLoading();
    }

    public function getRecommondList() : Array {
        var pPlayerData:CPlayerData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;

        // 随机找到匹配的3条
        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        var pEnhanceabilityTable:IDataTable = pDatabase.getTable( KOFTableConstants.ENHANCE_ABILITY );
        var pEnhanceList:Array = pEnhanceabilityTable.toArray();
        var filterList:Array = new Array();
        var enhance:Enhanceability;

        var pSwitchSystem:CSwitchingSystem = system.stage.getSystem(CSwitchingSystem) as CSwitchingSystem;


        for each (enhance in pEnhanceList) {
            var isSystemOpen:Boolean = pSwitchSystem.isSystemOpen(enhance.TagID);
            if (pPlayerData.teamData.level >= enhance.MinLevel && isSystemOpen) {
                filterList[filterList.length] = enhance;
            }
        }
        var finalList:Array = new Array();
        var i:int;
        for (i = 0; i < 3; i++) {
            if (filterList.length > 0) {
                var randomIndex:int = CMath.rand() * filterList.length;
                finalList[finalList.length] = filterList[randomIndex];
                filterList.splice(randomIndex, 1);
            }
        }
        return  finalList;
    }
}
}
