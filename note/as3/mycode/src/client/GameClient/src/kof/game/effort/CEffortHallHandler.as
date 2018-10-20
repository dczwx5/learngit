//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Leo.Li 2018/5/25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.effort {

import QFLib.Foundation.CMap;

import flash.system.System;

import kof.data.KOFTableConstants;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundleContext;
import kof.game.effort.data.CEffortConst;
import kof.game.effort.data.CEffortTargetData;
import kof.game.effort.view.CEffortHallViewHandler;
import kof.game.effort.view.CEffortPanelBase;
import kof.game.common.system.CNetHandlerImp;
import kof.game.welfarehall.CWelfareHallEvent;
import kof.message.ActivationCode.ActivationCodeResponse;
import kof.message.CAbstractPackMessage;
import kof.message.CardMonth.BuyCardMonthResponse;
import kof.message.CardMonth.CardMonthInfoResponse;
import kof.message.CardMonth.GetCardMonthRewardResponse;
import kof.message.Effort.EffortDataRequest;
import kof.message.Effort.EffortDataResponse;
import kof.message.Effort.EffortTargetChangeResponse;
import kof.message.Effort.EffortTargetRewardObtainRequest;
import kof.message.Effort.EffortTargetRewardObtainResponse;
import kof.message.Effort.EffortTypeRewardObtainRequest;
import kof.message.Effort.EffortTypeRewardObtainResponse;
import kof.message.ForeverRecharge.ForeverRechargeInfoResponse;
import kof.message.ForeverRecharge.ReceiveRechargeRewardResponse;
import kof.message.Invest.InvestDataRequest;
import kof.message.Invest.InvestDataResponse;
import kof.message.Notice.AdvertisementListResponse;
import kof.message.Notice.AnnouncementListResponse;
import kof.message.Notice.GetUpdateRewardResponse;
import kof.table.EffortConfig;
import kof.table.EffortConst;
import kof.table.EffortConst;
import kof.table.EffortTargetConfig;
import kof.table.EffortTypeRewardConfig;
import kof.table.EffortTypeRewardConfig;

/**
 * 成就系统大厅
 * @author Leo.Li
 * @date 2018/5/25
 */
public class CEffortHallHandler extends CNetHandlerImp {

    /**
     * 存储分类成就的当前点数，分类的总点数
     */
    public var m_pType_cur_point:CMap = new CMap();
    /**
     * 存储分类成就的总点数，分类的总点数
     */
    public var m_pType_sum_point:CMap = new CMap();

    /**
     * 按照EffortConfig.ID存储的当前成就点数
     */
    //public var m_pConfig_id_point:CMap = new CMap();

    /**
     * 所有已经达到可以领取的成就目标，EffortTargetConfig表
     */
//    public var m_pType_target_point:CMap = new CMap();

    /**
     * 服务器下发已经领取的typeReward 数据，对应EffortTypeRewardConfig表
     */
    public var m_vType_reward:Vector.<int> = new <int>[];

    /**
     * 服务器下发targetData数据，存储 CEffortTargetData,  EffortTargetConfig.ID
     */
    public var m_aTarget_config_obtained:Vector.<CEffortTargetData> = new Vector.<CEffortTargetData>();

    private var _m_pConfigTable:IDataTable;
    private var _m_pTargetTable:IDataTable;
    private var _m_pTypeRewardTable:IDataTable;
    private var _m_pConstTable:IDataTable;

    private var _m_pConstCfg:EffortConst;


    public var m_aLastObtainIds:Array = [];
    public var m_aTypeObtainedIds:Array;

    public var m_pHallViewHandler:CEffortHallViewHandler;

    public function CEffortHallHandler() {
        super();
    }

    override public function dispose():void
    {
        super.dispose();
        _m_pConfigTable = null;
        _m_pTargetTable = null;
        m_pType_cur_point = null;
        m_aTarget_config_obtained = null;
        m_vType_reward = null;
        _m_pTypeRewardTable = null;
    }

    override protected function onSetup():Boolean {
        var ret:Boolean = super.onSetup();

        var pDatabase:IDatabase = system.stage.getSystem(IDatabase) as IDatabase;
        _m_pTypeRewardTable = pDatabase.getTable(KOFTableConstants.EFFORT_TYPEREWARD_CONFIG);
        _m_pTargetTable = pDatabase.getTable(KOFTableConstants.EFFORT_TARGET_CONFIG);
        _m_pConfigTable = pDatabase.getTable(KOFTableConstants.EFFORT_CONFIG);
        _m_pConstTable = pDatabase.getTable(KOFTableConstants.EFFORT_CONST);
        _m_pConstCfg = _m_pConstTable.findByPrimaryKey(1);

//        this.bind(ActivationCodeResponse, _onActivationCodeResponseHandler);消息响应绑定
        this.bind(EffortDataResponse,effortDataResponse);
        this.bind(EffortTargetRewardObtainResponse,effortAchieveResponse);
        this.bind(EffortTypeRewardObtainResponse,typeRewardResponse);
        this.bind(EffortTargetChangeResponse,effortTargetChangeResponse);


        for(var i:int = 1; i <= CEffortConst.TYPES; i ++)
        {
            m_pType_cur_point.add(i,0);
            sumTypeCfgEffort(i);
        }
        //onCardMonthInfoRequest();消息请求
        effortInfoRequest();

        return ret;
    }

    public function updateRedPoint() : void {
        m_pHallViewHandler.updateRedPoint();
        var pSystemBundleContext : ISystemBundleContext;
        pSystemBundleContext = system.stage.getBean( ISystemBundleContext ) as ISystemBundleContext;
        if ( pSystemBundleContext ) {
            for each( var targetCurData : CEffortTargetData in m_aTarget_config_obtained ) {
                if ( targetCurData.isComplete && targetCurData.obtainTick < 1 ) {
                    pSystemBundleContext.setUserData( system as CEffortSystem, CBundleSystem.NOTIFICATION, true );
                    return;
                }
            }
            for(var i:int = 1; i <= CEffortConst.TYPES; i ++)
            {
                var sum:int = sumTypeEffort(i);
                var curShowTypeCfg:EffortTypeRewardConfig = calculateCurShowTypeReward(sum,i);
                if(curShowTypeCfg)
                {
                    if(curShowTypeCfg.needPointNum <= sum)
                    {
                        pSystemBundleContext.setUserData( system as CEffortSystem, CBundleSystem.NOTIFICATION, true );
                        return ;
                    }
                }
            }
            pSystemBundleContext.setUserData( system as CEffortSystem, CBundleSystem.NOTIFICATION, false );
        }
    }


    public function sumTypeEffort(type:int):int
    {
        var sum:int = 0;
        for each(var cfg:EffortConfig in _m_pConfigTable.toArray()) {
            if ( cfg.type == type ) {
                for each(var targetCfgId:int in  cfg.effortTargetId)
                {
                    for each(var data:CEffortTargetData in m_aTarget_config_obtained)
                    {
                        if(data.obtainTick > 0&&data.targetConfigId == targetCfgId)
                        {
                            sum += (_m_pTargetTable.findByPrimaryKey(data.targetConfigId) as EffortTargetConfig).effortPointNum;
                        }
                    }
                }
            }
        }
        m_pType_cur_point.add(type,sum,true);
        return sum;
    }

    public function sumTypeCfgEffort(type:int) : int {
        var sum:int = 0;
        for each(var cfg:EffortConfig in _m_pConfigTable.toArray())
        {
            if(cfg.type == type)
            {
                for each(var targetId:int in cfg.effortTargetId)
                {
                    var targetCfg : EffortTargetConfig = _m_pTargetTable.findByPrimaryKey(targetId);
                    sum += targetCfg.effortPointNum;
                }
            }
        }
        m_pType_sum_point.add(type,sum,true);
        return sum
    }

    public function calculateCurShowTypeReward( currentPoint:int, type:int):EffortTypeRewardConfig
    {
        for each(var typeCfg:EffortTypeRewardConfig in _m_pTypeRewardTable.toArray())
        {
            if(typeCfg.type == type)
            {
                if(m_aTypeObtainedIds.indexOf(typeCfg.ID) == -1&&currentPoint >= typeCfg.needPointNum)
                {
                    return typeCfg;
                }
                if(typeCfg.needPointNum > currentPoint)
                {
                    return typeCfg;
                }
            }
        }
        return null;
    }

    public function updateTypeReward(id:int):void
    {
        if(m_aTypeObtainedIds.indexOf(id) == -1)
        {
            m_aTypeObtainedIds.push(id);
        }
    }

    /**
     * 是否领取过TypeReward
     * @param typeRewardId
     * @return
     */
    public function isTypeRewardObtained(typeRewardId:int):Boolean
    {
        if(m_aTypeObtainedIds.indexOf(typeRewardId) == -1)
        {
            return false;
        }
        return true;
    }

    public function updateRecentObtained(targetId:int):void
    {
        if(m_aLastObtainIds.indexOf(targetId) == -1)
        {
            if(m_aLastObtainIds.length >= _m_pConstCfg.lastFinishedShowNum)
            {
                m_aLastObtainIds.shift();
            }
            m_aLastObtainIds.push(targetId);
        }
    }

    /**
     * 是否已经领取过 TargetConfig 奖励
     */
    public function hasReward(targetConfigId:int):Boolean
    {
        for each(var data:CEffortTargetData in m_aTarget_config_obtained)
        {
            if(data.targetConfigId == targetConfigId&&data.obtainTick > 0)
            {
                return true;
            }
        }
        return false;
    }

    /**
     * 获取指定id的获得的成就数据
     * @param targetConfigId
     * @return
     */
    public function currentTargetData( targetConfigId:int):CEffortTargetData
    {
        for each(var data:CEffortTargetData in m_aTarget_config_obtained)
        {
            if(data.targetConfigId == targetConfigId)
            {
                return data;
            }
        }
        return null;
    }


    public function getConfigByTargetConfigId(targetId:int):EffortConfig
    {
        for each(var config:EffortConfig in _m_pConfigTable.toArray())
        {
            for each(var id:int in config.effortTargetId)
            {
                if(id == targetId)
                {
                    return config;
                }
            }
        }
        return null;
    }

    //======================request start==============================

    public function effortInfoRequest():void
    {
        var request:EffortDataRequest = new EffortDataRequest();
        request.decode([1]);
        networking.post(request);
    }

    /**
     * 分类成就奖励
     */
    public function typeRewardRequest(typeId:int):void
    {
        var request:EffortTypeRewardObtainRequest = new EffortTypeRewardObtainRequest();
        request.decode([typeId]);
        networking.post(request);
    }


    /**
     * 领取成就
     * @param targetId 子阶段配置id
     */
    public function effortAchieveRequest(targetId:int):void
    {
        var request:EffortTargetRewardObtainRequest = new EffortTargetRewardObtainRequest();
        request.decode([targetId]);
        networking.post(request);
    }

    //======================request end================================

    //======================response start==============================


    public function effortDataResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        //成就目标数据格式
        //targetId    目标id、配表id
        //curVal      当前值、以及达到了多少
        //targetVal   目标值、要达到多少
        //isComplete  是否已完成
        //obtainTick  领取时间（未领取时为0)
        if ( isError ) return;
        var response : EffortDataResponse = message as EffortDataResponse;

        m_aLastObtainIds = response.lastObtainedIds;
        m_aTypeObtainedIds = response.typeObtainedIds;

        var tempData:CEffortTargetData;

        for each(var data:Object in response.targetInfos)
        {
            tempData = new CEffortTargetData();
            tempData.targetConfigId = data.targetId;
            tempData.current = data.curVal;
            tempData.max = data.targetVal;
            tempData.isComplete = data.isComplete;
            tempData.obtainTick = data.obtainTick;
            m_aTarget_config_obtained.push(tempData);
        }
        updateRedPoint();
    }

    /**
     * 分类成就奖励
     */
    public function typeRewardResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if ( isError ) return;
        var response : EffortTypeRewardObtainResponse = message as EffortTypeRewardObtainResponse;

        updateTypeReward(response.id);

        system.dispatchEvent( new CEffortEvent( CEffortEvent.TYPE_ACHIEVE_REWARD ,response.id ) );
        updateRedPoint();
    }

    /**
     * 领取成就
     * @param net
     * @param message
     * @param isError
     */
    public function effortAchieveResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if ( isError ) return;
        var response : EffortTargetRewardObtainResponse = message as EffortTargetRewardObtainResponse;

        var tempData : CEffortTargetData;
        tempData =currentTargetData(response.targetInfo.targetId);
        tempData.current = response.targetInfo.curVal;
        tempData.max = response.targetInfo.targetVal;
        tempData.isComplete = response.targetInfo.isComplete;
        tempData.obtainTick = response.targetInfo.obtainTick;

        updateRecentObtained(tempData.targetConfigId);

        system.dispatchEvent( new CEffortEvent( CEffortEvent.ACHIEVE_EFFORT ,tempData ) );
        updateRedPoint();
    }

    /**
     * 目标数据变动(当前值、完成状态变动时发送）
     */
    public function effortTargetChangeResponse(net:INetworking, message:CAbstractPackMessage, isError:Boolean):void
    {
        if ( isError ) return;
        var response : EffortTargetChangeResponse = message as EffortTargetChangeResponse;
        var targetData:CEffortTargetData = currentTargetData(response.targetInfo.targetId);
        targetData.current = response.targetInfo.curVal;
        targetData.max = response.targetInfo.targetVal;
        targetData.isComplete = response.targetInfo.isComplete;
        targetData.obtainTick = response.targetInfo.obtainTick;
        system.dispatchEvent( new CEffortEvent( CEffortEvent.TARGET_POINT_CHANGE, targetData ) );
        updateRedPoint();
    }

    //======================response end================================

}
}
