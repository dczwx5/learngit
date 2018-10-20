//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story {

import kof.SYSTEM_ID;
import kof.game.KOFSysTags;
import kof.game.bundle.ISystemBundleContext;
import kof.game.common.CDelayCall;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.system.CInstanceOverHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.CInstanceUIHandler;
import kof.game.instance.enum.EInstanceType;
import kof.game.instance.event.CInstanceEvent;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.shop.enum.EShopType;
import kof.game.story.data.CStoryData;
import kof.game.story.enum.EStoryDataEventType;
import kof.game.story.event.CStoryEvent;
import kof.message.HeroStory.HeroStoryChallengeResultResponse;
import kof.message.Instance.InstanceOverResponse;

import morn.core.handlers.Handler;
//
public class CStorySystem extends CAppSystemImp  {
    public function CStorySystem() {
    }
    public override function get bundleID() : * {
        return SYSTEM_ID(SYSTEM_TAG);
    }
    // ===========================show/hide===========================
    override protected function onActivated(a_bActivated:Boolean) : void {
        super.onActivated(a_bActivated);

        if (isActived) {
            var heroID:int = ctx.getUserData(this, HERO_ID, -1);
            _uiHandler.showStory(heroID);
        } else {
            _uiHandler.hideStory();
        }
    }
    override protected function onBundleStart(ctx:ISystemBundleContext):void {
        super.onBundleStart(ctx);
        netHandler.sendGetData();
    }

    public override function dispose() : void {
        super.dispose();
        this.removeEventListener(CStoryEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
    }
    override public function initialize():Boolean {
        var ret:Boolean = super.initialize();


//        ret = ret && this.addBean(_redPoint = new CStoryRedPoint());
//        _redPoint.processNotify();

        ret = ret && this.addBean(_manager = new CStoryManager());
        ret = ret && this.addBean(new CStoryNetEventTransformHandler());
        ret = ret && this.addBean(_uiHandler = new CStoryUIHandler());
        ret = ret && this.addBean(_netHandler = new CStoryNetHandler());
        ret = ret && this.addBean(_instanceOverHandler = new CInstanceOverHandler(instanceType,
                        new Handler(_uiHandler.showResult)));

        this.registerEventType(CStoryEvent.NET_EVENT_DATA);
        this.registerEventType(CStoryEvent.NET_EVENT_UPDATE_DATA);
        this.registerEventType(CStoryEvent.NET_EVENT_BUY_FIGHT_COUNT);
        this.registerEventType(CStoryEvent.NET_EVENT_FIGHT);
        this.registerEventType(CStoryEvent.NET_EVENT_SETTLEMENT_DATA);

        this.registerEventType(CStoryEvent.DATA_EVENT);

        this.addEventListener(CStoryEvent.NET_EVENT_SETTLEMENT_DATA, _onNetResultData);
        _instanceOverHandler.listenEvent();

        return ret;
    }

    private function _onNetResultData(event:CStoryEvent):void {
        var e : CStoryEvent = event as CStoryEvent;
        if (e.type == CStoryEvent.NET_EVENT_SETTLEMENT_DATA) {
            var uiHandler : CInstanceUIHandler = stage.getSystem(CInstanceSystem ).getBean(CInstanceUIHandler) as CInstanceUIHandler;

            var pInstanceSystem:CInstanceSystem = this.stage.getSystem(CInstanceSystem) as CInstanceSystem;
            pInstanceSystem.uiHandler.hideResultPvpWinView();
            uiHandler.uiCanvas.removePVPLoadingView();
            uiHandler.uiCanvas.hideHoldingMaskView();

            var streetResultData:Object = e.data as Object;
            manager.data.updateResultData(streetResultData as HeroStoryChallengeResultResponse);
            sendEvent(new CStoryEvent(CStoryEvent.DATA_EVENT, EStoryDataEventType.SETTLEMENT, manager.data));

            if ((streetResultData as HeroStoryChallengeResultResponse).win) {
                _instanceOverHandler.instanceOverEventProcess(null);
            }
//            else {
//                uiHandler.showResultLoseView();
//            }走副本统一流程
        }
    }

    // ====================util==========================
    public function get embattleType() : int {
        return EInstanceType.TYPE_STORY;
    }
    public function get instanceType() : int  {
        return EInstanceType.TYPE_STORY;
    }
    public function get SYSTEM_TAG() : String {
        return KOFSysTags.STORY;
    }

    public function get embattleListData() : CEmbattleListData {
        var playerSystem:CPlayerSystem = stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var emList:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(embattleType);
        return emList;
    }
    public function get shopType() : int {
        return EShopType.SHOP_TYPE_15;
    }

    // ===========================get/set=============================
    [Inline]
    public function get manager() : CStoryManager { return _manager; }
    [Inline]
    public function get uiHandler() : CStoryUIHandler { return _uiHandler; }
    [Inline]
    public function get netHandler() : CStoryNetHandler { return _netHandler; }
    [Inline]
    public function get data() : CStoryData { return _manager.data; }
//    public function get redPoint() : CStoryRedPoint { return _redPoint; }


    private var _manager:CStoryManager;
    private var _netHandler:CStoryNetHandler;
    private var _uiHandler:CStoryUIHandler;
//    private var _redPoint:CStoryRedPoint; // 小红点

    private var _instanceOverHandler:CInstanceOverHandler;

}
}
