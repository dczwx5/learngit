//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Lune on 2018/6/28.
 */
package kof.game.LotteryActivity {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.INetworking;
import kof.game.activityHall.CActivityHallSystem;
import kof.game.activityHall.data.CActivityHallActivityType;
import kof.game.activityHall.data.CActivityState;
import kof.game.activityHall.event.CActivityHallEvent;
import kof.game.common.system.CNetHandlerImp;
import kof.message.Activity.ActivityChangeResponse;
import kof.message.CAbstractPackMessage;
import kof.message.LotteryActivity.LotteryActivityInfoRequest;
import kof.message.LotteryActivity.LotteryActivityInfoResponse;
import kof.message.LotteryActivity.StartLotteryActivityRequest;
import kof.message.LotteryActivity.StartLotteryActivityResponse;
import kof.table.GamePrompt;
import kof.ui.CUISystem;

public class CLotteryActivityNetHander extends CNetHandlerImp {
    private var _isRequest : Boolean;//是否已经请求过数据
    public function CLotteryActivityNetHander() {
        super();
    }
    override public function dispose() : void {
        super.dispose();
    }

    override protected function onSetup() : Boolean {
        super.onSetup();
        this.bind( LotteryActivityInfoResponse, _LotteryActivityResponse );
        this.bind( StartLotteryActivityResponse,_startLotteryResponse);
        activityHallSystem.addEventListener(CActivityHallEvent.ActivityStateChanged, _onActivityStateRespone);
        LotteryActivityRequest();
        return true;
    }
    /**
     * 请求活动状态返回
     */
    //================================================
    private function _onActivityStateRespone(event:CActivityHallEvent):void{
        var response:ActivityChangeResponse = event.data as ActivityChangeResponse;
        if(!response) return;

        var activityType:int = _manager.getActivityType(response.activityID);
        if(activityType == CActivityHallActivityType.LOTTERY) {
            _manager.curActivityId = response.activityID;
            _manager.curActivityState = response.state;
            if ( response.params ) {
                _manager.startTime = response.params.startTick;
                _manager.endTime = response.params.endTick;
            }
            if ( response.state == CActivityState.ACTIVITY_START ) {
                _manager.firstOpen = true;
                _manager.openActivity();
            }
            else if ( response.state == CActivityState.ACTIVITY_END ) {
                _manager.closeActivity();
                _manager.curActivityId = 0;
            }
        }
    }
    /**
     * 请求数据返回
     */
    public function LotteryActivityRequest() : void {
        if(_isRequest) return;
        var request : LotteryActivityInfoRequest = new LotteryActivityInfoRequest();
        request.info = 1;
        networking.post( request );
        _isRequest = true;
    }

    private final function _LotteryActivityResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : LotteryActivityInfoResponse = message as LotteryActivityInfoResponse;
        _manager.rewardStates =response.positions;
        _manager.count = response.count;
    }

    /**
     * 点击抽奖
     */
    public function startLotteryRequest() : void {
        var request : StartLotteryActivityRequest = new StartLotteryActivityRequest();
        request.info = 1;
        networking.post( request );
    }

    private final function _startLotteryResponse( net : INetworking, message : CAbstractPackMessage, isError : Boolean ) : void {
        var response : StartLotteryActivityResponse = message as StartLotteryActivityResponse;
        if(response.nowPosition > 0)
        {
            _manager.newPosition = response.nowPosition;
            _manager.count = response.count;
            _manager.rewardStates = response.positions;
            _manager.backCounts = response.backCounts;
            _mainView.showReward();
        }
        var proStr:String = getGamePromptStr(response.gamePromptID);
        if( proStr != null){
            (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(proStr);
        }
    }

    private function get _manager() : CLotteryActivityManager
    {
        return system.getBean(CLotteryActivityManager) as CLotteryActivityManager;
    }
    private function get activityHallSystem() : CActivityHallSystem {
        return system.stage.getSystem(CActivityHallSystem) as CActivityHallSystem;
    }
    private function get _mainView() : CLotteryActivityMainView
    {
        return system.getBean(CLotteryActivityMainView) as CLotteryActivityMainView;
    }
    private function get _system() : CLotteryActivitySystem
    {
        return system as CLotteryActivitySystem;
    }
    /******************************table**************************************/
    public function getGamePromptStr(gamePromptID:int):String {
        var pTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.GAME_PROMPT);
        var configInfo:GamePrompt = pTable.findByPrimaryKey(gamePromptID) as GamePrompt;
        var pStr:String = null;
        if(configInfo){
            pStr = configInfo.content;
        }
        return pStr;
    }
}
}
