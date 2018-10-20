//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2018/4/17.
 */
package kof.game.guildWar {

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.common.CRewardUtil;
import kof.game.common.system.CNetHandlerImp;
import kof.game.guildWar.enum.CGuildWarState;
import kof.game.guildWar.event.CGuildWarEvent;
import kof.game.guildWar.view.CGuildWarGiftMethodViewHandler;
import kof.game.item.CItemSystem;
import kof.game.item.data.CRewardListData;
import kof.message.CAbstractPackMessage;
import kof.message.GuildWar.GuildWarAllocateRewardBagRecordRequest;
import kof.message.GuildWar.GuildWarAllocateRewardBagRecordResponse;
import kof.message.GuildWar.GuildWarAllocateRewardBagRequest;
import kof.message.GuildWar.GuildWarAllocateRewardBagResponse;
import kof.message.GuildWar.GuildWarAppointSpaceClubRankRequest;
import kof.message.GuildWar.GuildWarAppointSpaceClubRankResponse;
import kof.message.GuildWar.GuildWarAppointSpaceFightReportRequest;
import kof.message.GuildWar.GuildWarAppointSpaceFightReportResponse;
import kof.message.GuildWar.GuildWarAppointSpaceMatchRequest;
import kof.message.GuildWar.GuildWarAppointSpaceMatchResponse;
import kof.message.GuildWar.GuildWarAppointSpaceRoleRankRequest;
import kof.message.GuildWar.GuildWarAppointSpaceRoleRankResponse;
import kof.message.GuildWar.GuildWarBuffInfoRequest;
import kof.message.GuildWar.GuildWarBuffInfoResponse;
import kof.message.GuildWar.GuildWarBuffRequest;
import kof.message.GuildWar.GuildWarBuffResponse;
import kof.message.GuildWar.GuildWarGamePromptResponse;
import kof.message.GuildWar.GuildWarGetRewardRequest;
import kof.message.GuildWar.GuildWarInfoRequest;
import kof.message.GuildWar.GuildWarInfoResponse;
import kof.message.GuildWar.GuildWarInfoUpdateResponse;
import kof.message.GuildWar.GuildWarMatchCancelRequest;
import kof.message.GuildWar.GuildWarProgressSyncRequest;
import kof.message.GuildWar.GuildWarProgressSyncResponse;
import kof.message.GuildWar.GuildWarReceiveDaySpaceRewardRequest;
import kof.message.GuildWar.GuildWarReceiveDaySpaceRewardResponse;
import kof.message.GuildWar.GuildWarRewardBagInfoRequest;
import kof.message.GuildWar.GuildWarRewardBagInfoResponse;
import kof.message.GuildWar.GuildWarSettlementResponse;
import kof.message.GuildWar.GuildWarSpaceClubInfoRequest;
import kof.message.GuildWar.GuildWarSpaceClubInfoResponse;
import kof.message.GuildWar.GuildWarSpaceClubTotalScoreRankRequest;
import kof.message.GuildWar.GuildWarSpaceClubTotalScoreRankResponse;
import kof.message.GuildWar.GuildWarStarSupremacyRewardUIResponse;
import kof.message.GuildWar.GuildWarTotalScoreRankRequest;
import kof.message.GuildWar.GuildWarTotalScoreRankResponse;
import kof.table.GamePrompt;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;

public class CGuildWarNetHandler extends CNetHandlerImp {
    public function CGuildWarNetHandler() {
        super();
    }

    public override function dispose() : void
    {
        super.dispose();
    }

    override protected function onSetup() : Boolean
    {
        super.onSetup();

        bind( GuildWarInfoResponse, _onGuildWarInfoResponse );
        bind( GuildWarInfoUpdateResponse, _onGuildWarInfoUpdateResponse );
        bind( GuildWarSpaceClubInfoResponse, _onGuildWarSpaceClubInfoResponse );
        bind( GuildWarAppointSpaceMatchResponse, _onGuildWarAppointSpaceMatchResponse );
        bind( GuildWarProgressSyncResponse, _onGuildWarProgressSyncResponse );
        bind( GuildWarGamePromptResponse, _onGuildWarGamePromptResponse );
        bind( GuildWarSettlementResponse, _onGuildWarSettlementResponse );
        bind( GuildWarAppointSpaceClubRankResponse, _onStationClubRankResponse );
        bind( GuildWarAppointSpaceRoleRankResponse, _onStationRoleRankResponse );
        bind( GuildWarTotalScoreRankResponse, _onGuildWarTotalScoreRankResponse );
        bind( GuildWarSpaceClubTotalScoreRankResponse, _onGuildWarSpaceClubTotalScoreRankResponse );
        bind( GuildWarStarSupremacyRewardUIResponse, _onGuildWarStarSupremacyRewardUIResponse );
        bind( GuildWarAppointSpaceFightReportResponse, _onFightReportResponse );
        bind( GuildWarBuffInfoResponse, _onGuildWarBuffInfoResponse );
        bind( GuildWarBuffResponse, _onGuildWarBuffResponse );
        bind( GuildWarReceiveDaySpaceRewardResponse, _onGuildWarReceiveDaySpaceRewardResponse );
        bind( GuildWarRewardBagInfoResponse, _onGuildWarRewardBagInfoResponse );
        bind( GuildWarAllocateRewardBagResponse, _onGuildWarAllocateRewardBagResponse );
        bind( GuildWarAllocateRewardBagRecordResponse, _onGuildWarAllocateRewardBagRecordResponse );

        return true;
    }

//====================================================================================================================>>
    /**
     * 公会战信息请求
     */
    public function guildWarInfoRequest():void
    {
        var request:GuildWarInfoRequest = new GuildWarInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    private final function _onGuildWarInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarInfoResponse = message as GuildWarInfoResponse;

        if(response && response.guildWarData)
        {
            _manager.initGuildWarInfoData(response.guildWarData);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.InitBaseInfo, null));
        }
    }
//<<====================================================================================================================



//<<====================================================================================================================
    /**
     * 公会战信息改变反馈
     * @param net
     * @param message
     */
    private final function _onGuildWarInfoUpdateResponse( net:INetworking, message:CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response:GuildWarInfoUpdateResponse = message as GuildWarInfoUpdateResponse;

        if(response && response.guildWarDataUpdate)
        {
            _manager.updateGuildWarInfoData(response.guildWarDataUpdate);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateBaseInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战各空间站俱乐部信息请求
     */
    public function guildWarSpaceClubInfoRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarSpaceClubInfoRequest = new GuildWarSpaceClubInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战各空间站俱乐部信息反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarSpaceClubInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarSpaceClubInfoResponse = message as GuildWarSpaceClubInfoResponse;

        if(response && response.spaceClubData)
        {
            _manager.updateStationInfo(response.spaceClubData);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateStationInfo, null));
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>
    /**
     * 公会战某个空间站匹配请求
     */
    public function guildWarAppointSpaceMatchRequest(stationId:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAppointSpaceMatchRequest = new GuildWarAppointSpaceMatchRequest();
        request.spaceId = stationId;

        networking.post(request);
    }

    /**
     * 公会战某个空间站匹配反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarAppointSpaceMatchResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAppointSpaceMatchResponse = message as GuildWarAppointSpaceMatchResponse;

        if(response && response.matchData)
        {
            _manager.updateMatchData(response.matchData);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateMatchInfo, null));
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>
    /**
     * 公会战进度同步请求
     */
    public function guildWarProgressSyncRequest(progress:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarProgressSyncRequest = new GuildWarProgressSyncRequest();
        request.progress = progress;

        networking.post(request);
    }

    /**
     * 公会战进度同步反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarProgressSyncResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarProgressSyncResponse = message as GuildWarProgressSyncResponse;

        if(response)
        {
            _manager.updateProgress(response.enemyProgress);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateProgressInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战某个空间站俱乐部排行请求
     */
    public function stationClubRankRequest(spaceId:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAppointSpaceClubRankRequest = new GuildWarAppointSpaceClubRankRequest();
        request.spaceId = spaceId;

        networking.post(request);
    }

    /**
     * 公会战某个空间站俱乐部排行反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onStationClubRankResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAppointSpaceClubRankResponse = message as GuildWarAppointSpaceClubRankResponse;

        if(response)
        {
            var data:Object = {};
            data.spaceId = response.spaceId;
            data.clubRankDatas = response.clubRankDatas;
            data.myClubRankData = response.myClubRankData;
            _manager.updateStationClubRankData(data);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateClubRankInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战某个空间站个人排行请求
     */
    public function stationRoleRankRequest(spaceId:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAppointSpaceRoleRankRequest = new GuildWarAppointSpaceRoleRankRequest();
        request.spaceId = spaceId;

        networking.post(request);
    }

    /**
     * 公会战某个空间站个人排行反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onStationRoleRankResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAppointSpaceRoleRankResponse = message as GuildWarAppointSpaceRoleRankResponse;

        if(response)
        {
            var data:Object = {};
            data.spaceId = response.spaceId;
            data.roleRankDatas = response.roleRankDatas;
            data.myRoleRankData = response.myRoleRankData;
            _manager.updateStationRoleRankData(data);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateRoleRankInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战某个空间站战报请求
     */
    public function fightReportRequest(spaceId:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAppointSpaceFightReportRequest = new GuildWarAppointSpaceFightReportRequest();
        request.spaceId = spaceId;

        networking.post(request);
    }

    /**
     * 公会战某个空间站战报反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onFightReportResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAppointSpaceFightReportResponse = message as GuildWarAppointSpaceFightReportResponse;

        if(response && response.fightReportData)
        {
            var data:Object = {};
            data.spaceId = response.spaceId;
            data.alwaysWinData = response.alwaysWinData;
            data.fightReportData = response.fightReportData;
            _manager.updateFightReportInfo(data);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateFightReportInfo, null));
        }
    }
//<<====================================================================================================================


//<<====================================================================================================================
    /**
     * 公会战错误码反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarGamePromptResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarGamePromptResponse = message as GuildWarGamePromptResponse;

        if(response.gamePromptID)
        {
            var gamePromptTable:IDataTable = (system.stage.getSystem(IDatabase) as IDatabase).getTable(KOFTableConstants.GAME_PROMPT);
            var configInfo:GamePrompt = gamePromptTable.findByPrimaryKey(response.gamePromptID) as GamePrompt;
            if(configInfo)
            {
                (system.stage.getSystem( CUISystem ) as CUISystem).showMsgAlert(configInfo.content,CMsgAlertHandler.NORMAL);
            }
        }
    }


//<<====================================================================================================================
    /**
     * 公会战结算反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarSettlementResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarSettlementResponse = message as GuildWarSettlementResponse;

        if(response && response.settlementData)
        {
            _manager.updateResultData(response.settlementData);
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战匹配取消请求
     */
    public function guildWarMatchCancelRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarMatchCancelRequest = new GuildWarMatchCancelRequest();
        request.flag = 1;

        networking.post(request);
    }
//<<====================================================================================================================




//====================================================================================================================>>
    /**
     * 公会战手动领取奖励请求
     */
    public function guildWarGetRewardRequest(guildWarRewardID:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarGetRewardRequest = new GuildWarGetRewardRequest();
        request.guildWarRewardID = guildWarRewardID;

        networking.post(request);
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战总能源排行请求（排的都是自己俱乐部的数据）
     * （俱乐部所有成员的总积分排行, 因为俱乐部人数有限制，所以该榜单没有条数限制，0分不上榜）
     */
    public function guildWarTotalScoreRankRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarTotalScoreRankRequest = new GuildWarTotalScoreRankRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战总能源排行反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarTotalScoreRankResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarTotalScoreRankResponse = message as GuildWarTotalScoreRankResponse;

        if(response)
        {
            _manager.updateTotalScoreRankData(response.totalScoreRankDatas);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateTotalScoreRankInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战空间站能源排行请求（排的都是自己俱乐部的数据）
     */
    public function guildWarSpaceClubTotalScoreRankRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarSpaceClubTotalScoreRankRequest = new GuildWarSpaceClubTotalScoreRankRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战空间站能源排行
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarSpaceClubTotalScoreRankResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarSpaceClubTotalScoreRankResponse = message as GuildWarSpaceClubTotalScoreRankResponse;

        if(response)
        {
            _manager.updateStationTotalScoreRankData(response.clubTotalScoreRankDatas);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateStationTotalScoreRankInfo, null));
        }
    }
//<<====================================================================================================================



//<<====================================================================================================================
    /**
     * 公会战结算反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarStarSupremacyRewardUIResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarStarSupremacyRewardUIResponse = message as GuildWarStarSupremacyRewardUIResponse;

        if(response && response.spaceIds)
        {
            _manager.updateObtainSpaceIds(response.spaceIds);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.ObtainSpaceShowInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>
    /**
     * 公会战战斗激活信息请求
     */
    public function guildWarBuffInfoRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarBuffInfoRequest = new GuildWarBuffInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战战斗激活信息反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarBuffInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarBuffInfoResponse = message as GuildWarBuffInfoResponse;

        if(response)
        {
            _manager.updateBuffInfo(response.buffDatas);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateBuffInfo, null));
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>

    /**
     * 公会战鼓舞请求
     * @param buffType 鼓舞类型 ：1普通鼓舞 2钻石鼓舞
     */
    public function guildWarBuffRequest(buffType:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarBuffRequest = new GuildWarBuffRequest();
        request.buffType = buffType;

        networking.post(request);
    }

    /**
     * 公会战鼓舞反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarBuffResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        CGuildWarState.isInInspire = false;

        var response : GuildWarBuffResponse = message as GuildWarBuffResponse;

        if(response)
        {
            var obj:Object = {};
            obj.buffType = response.buffType;
            obj.success = response.success;
            _manager.updateBuffResponseInfo(obj);

            if(response.success)
            {
                _uiSystem.showMsgAlert("鼓舞成功",CMsgAlertHandler.NORMAL);
                system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateBuffResponseInfo, response.buffType));
            }
            else
            {
                _uiSystem.showMsgAlert("鼓舞失败",CMsgAlertHandler.WARNING);
            }
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>

    /**
     * 公会战领取每日空间站奖励请求
     * @param spaceId 空间站ID
     */
    public function guildWarReceiveDaySpaceRewardRequest(spaceId:int):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarReceiveDaySpaceRewardRequest = new GuildWarReceiveDaySpaceRewardRequest();
        request.spaceId = spaceId;

        networking.post(request);
    }

    /**
     * 公会战领取每日空间站奖励反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarReceiveDaySpaceRewardResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarReceiveDaySpaceRewardResponse = message as GuildWarReceiveDaySpaceRewardResponse;

        if(response)
        {
            var rewardListData:CRewardListData = CRewardUtil.createByList(system.stage, response.rewardList);
            if(rewardListData)
            {
                (system.stage.getSystem(CItemSystem) as CItemSystem).showRewardFull(rewardListData);

                system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateStationBoxRewardInfo, null));
            }
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>

    /**
     * 公会战礼包信息请求
     */
    public function guildWarRewardBagInfoRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarRewardBagInfoRequest = new GuildWarRewardBagInfoRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战礼包信息反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarRewardBagInfoResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarRewardBagInfoResponse = message as GuildWarRewardBagInfoResponse;

        if(response)
        {
            var data:Object = {};
            data.winnerSpacesAllocateDatas = response.winnerSpacesAllocateDatas;
            data.clubRankDatas = response.clubRankDatas;
            _manager.updateGiftBagInfo(data);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateGiftBagAllocateInfo, null));
        }
    }
//<<====================================================================================================================


//====================================================================================================================>>

    /**
     * 公会战分配礼包请求
     */
    public function guildWarAllocateRewardBagRequest(dataArr:Array):void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAllocateRewardBagRequest = new GuildWarAllocateRewardBagRequest();
        request.allocateRewardBagDatas = dataArr;

        networking.post(request);
    }

    /**
     * 公会战分配礼包反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarAllocateRewardBagResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAllocateRewardBagResponse = message as GuildWarAllocateRewardBagResponse;

        if(response)
        {
            if(response.success)
            {
                _uiSystem.showMsgAlert("分配成功！", CMsgAlertHandler.NORMAL);
                var view:CGuildWarGiftMethodViewHandler = system.getHandler(CGuildWarGiftMethodViewHandler) as
                        CGuildWarGiftMethodViewHandler;
                if(view.isViewShow)
                {
                    view.removeDisplay();
                }
            }
            else
            {
                _uiSystem.showMsgAlert("分配失败！", CMsgAlertHandler.NORMAL);
            }
        }
    }
//<<====================================================================================================================



//====================================================================================================================>>

    /**
     * 公会战分配礼包记录请求
     */
    public function guildWarAllocateRewardBagRecordRequest():void
    {
        if(!_helper.isJoinClub())
        {
            return;
        }

        var request:GuildWarAllocateRewardBagRecordRequest = new GuildWarAllocateRewardBagRecordRequest();
        request.flag = 1;

        networking.post(request);
    }

    /**
     * 公会战分配礼包记录反馈
     * @param net
     * @param message
     * @param isError
     */
    private final function _onGuildWarAllocateRewardBagRecordResponse( net : INetworking, message : CAbstractPackMessage, isError:Boolean ) : void
    {
        if (isError) return ;

        var response : GuildWarAllocateRewardBagRecordResponse = message as GuildWarAllocateRewardBagRecordResponse;

        if(response && response.allocateRewardBagRecordDatas)
        {
            _manager.updateGiftBagRecordInfo(response.allocateRewardBagRecordDatas);

            system.dispatchEvent(new CGuildWarEvent(CGuildWarEvent.UpdateGiftBagRecordInfo, null));
        }
    }
//<<====================================================================================================================
    private function get _manager():CGuildWarManager
    {
        return system.getHandler(CGuildWarManager) as CGuildWarManager;
    }

    private function get _uiSystem():CUISystem
    {
        return system.stage.getSystem(CUISystem) as CUISystem;
    }

    private function get _helper():CGuildWarHelpHandler
    {
        return system.getHandler(CGuildWarHelpHandler) as CGuildWarHelpHandler;
    }
}
}
