//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/11.
 */
package kof.game.cultivate {

import kof.SYSTEM_ID;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.status.CGameStatus;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.common.view.resultWin.CMultiplePVPResultViewHandler;
import kof.game.cultivate.data.CClimpData;
import kof.game.cultivate.event.CCultivateEvent;
import kof.game.common.system.CAppSystemImp;
import kof.game.cultivate.imp.CCultivateLoadingDataProvider;
import kof.game.cultivate.imp.CCultivateResultDataProvider;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.loading.CPVPLoadingData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.message.ClimbTower.ClimbTowerChallengeResultResponse;
import kof.table.InstanceType;
import kof.ui.IUICanvas;

import morn.core.handlers.Handler;

// send reset_climb_tower
public class CCultivateSystem extends CAppSystemImp  {
    public function CCultivateSystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(KOFSysTags.CULTIVATE);
    }
    public override function dispose() : void {
        super.dispose();

        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.removeEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
        }

        this.removeEventListener(CCultivateEvent.NET_EVENT_RESULT_DATA, _onNetResultData);

    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


        ret = ret && this.addBean(_redPoint = new CCultivateRedPoint());
        _redPoint.processNotify();

        ret = ret && this.addBean(_manager = new CCultivateManager());
        ret = ret && this.addBean(_uiHandler = new CCultivateUIHandler());
        ret = ret && this.addBean(_netHandler = new CCultivateNetHandler());
        ret = ret && this.addBean(new CCultivateLoadingDataProvider());
        ret = ret && this.addBean(new CCultivateResultDataProvider());
        ret = ret && this.addBean(new CMultiplePVPResultViewHandler());

        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(EInstanceType.TYPE_CLIMP_CULTIVATE,
                        new Handler(_uiHandler.showResult)));

        this.registerEventType(CCultivateEvent.NET_EVENT_DATA);
        this.registerEventType(CCultivateEvent.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CCultivateEvent.DATA_EVENT);
        this.registerEventType(CCultivateEvent.NET_EVENT_REWARD_BOX_DATA);
        this.registerEventType(CCultivateEvent.NET_EVENT_RESET_DATA);

        this.addEventListener(CCultivateEvent.NET_EVENT_RESULT_DATA, _onNetResultData);

        return ret;
    }
    private function _onNetResultData(event:CCultivateEvent):void {
        manager.climpData.updateResultData(event.data as ClimbTowerChallengeResultResponse);
        _instanceOverHandler.instanceOverEventProcess(null);
    }

    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);
        if (isActived) {
            if (CGameStatus.checkStatus(this)) {
                var playerData:CPlayerData = (stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
                var hasEmbattleData:Boolean = playerData.embattleManager.hasEmbattleData(EInstanceType.TYPE_CLIMP_CULTIVATE);
                _uiHandler.showClimpView(hasEmbattleData);
            } else {
                setActived(false);
            }
        } else {
            _uiHandler.hideClimpView();
        }
    }

    override protected function onBundleStart(ctx:ISystemBundleContext) : void {
        super.onBundleStart(ctx);

        // 目前爬塔没有其他结算, 先用overInstance的事件, 后面换成爬塔的结算协议
        var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
        if (pInstanceSystem) {
            pInstanceSystem.addEventListener(CInstanceEvent.ENTER_INSTANCE, _onEnterInstanceHandler);
            _instanceOverHandler.listenEvent();

        }

        netHandler.sendGetCultivateData();
    }

    private function _onEnterInstanceHandler(e:CInstanceEvent)　:　void　{
        if (e.type == CInstanceEvent.ENTER_INSTANCE) {
            var pInstanceSystem:CInstanceSystem = stage.getSystem(CInstanceSystem) as CInstanceSystem;
            if(EInstanceType.isClimp(pInstanceSystem.instanceType))　{
                var ui:IUICanvas = stage.getSystem(IUICanvas) as IUICanvas;
                if (ui) {
                    var pvpLoadingData:CPVPLoadingData = (getBean(CCultivateLoadingDataProvider) as CCultivateLoadingDataProvider).getLoadingData();
//                    ui.showMultiplePVPLoadingView(pvpLoadingData);
                    ui.showDoublePVPLoadingView(pvpLoadingData);
                }
            }
        }
    }

    // ===========================get/set=============================
    // 最少出战人数
    public function get fighterCountLess() : int {
        if (_fightCountLess != -1) {
            return _fightCountLess;
        }
        var database:IDatabase = stage.getSystem(IDatabase) as IDatabase;
        var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
        var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var fighterCount:int = 3;
        if (instanceTypeRecord) {
            fighterCount = instanceTypeRecord.embattleNumMin;
        }
        _fightCountLess = fighterCount;
        return fighterCount;
    }
    public function get fightCountMax() : int {
        if (_fightCountMax != -1) {
            return _fightCountMax;
        }
        var database:IDatabase = stage.getSystem(IDatabase) as IDatabase;
        var instanceTypeTable:IDataTable = database.getTable(KOFTableConstants.INSTANCE_TYPE);
        var instanceTypeRecord:InstanceType = instanceTypeTable.findByPrimaryKey(EInstanceType.TYPE_CLIMP_CULTIVATE);
        var fighterCount:int = 3;
        if (instanceTypeRecord) {
            fighterCount = instanceTypeRecord.embattleNumLimit;
        }
        _fightCountMax = fighterCount;
        return fighterCount;
    }

    private var _fightCountLess:int = -1;
    private var _fightCountMax:int = -1;
    [Inline]
    public function get manager() : CCultivateManager { return _manager; }
    [Inline]
    public function get uiHandler() : CCultivateUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CCultivateNetHandler { return _netHandler; }
    [Inline]
    public function get climpData() : CClimpData { return _manager.climpData; }



    private var _manager:CCultivateManager;
    private var _netHandler:CCultivateNetHandler;
    private var _uiHandler:CCultivateUIHandler;
    private var _redPoint:CCultivateRedPoint; // 小红点

    private var _instanceOverHandler:CInstanceOverHandler;

}
}
