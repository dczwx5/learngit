//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/12.
 * Time: 16:20
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.ai.CAILog;

import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CPlayAction extends CBaseNodeAction {

    /**播放类型*/
    private var playType:String = "";
    /**播放id*/
    private var playId:String = "";
    /**持续时间*/
    private var playDuration:Number = 2;//默认2秒
    /**执行概率*/
    private var playProbability:Number = 1;
    /**播放模式*/
    private var playMode:String = "Random";

    private var m_pBT:CAIObject=null;
    private var m_elapsedTime:Number = 0;
    private var m_idVec:Array = [];
    private var m_playIndex:int = 0;

    public function CPlayAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null ,nodeIndex:int=-1) {
        super( parentNode , pBt);
        this.m_pBT = pBt;
        if(nodeIndex>-1)
        {
            setTemplateIndex(nodeIndex);
            setName(nodeIndex+"_"+nodeName);
        }
        else
        {
            setName(nodeName);
        }
        _initNodeData();
    }

    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
        if(m_pBT.cacheParamsDic[name+".playType"])
        {
            playType = m_pBT.cacheParamsDic[name+".playType"];
        }
        if(m_pBT.cacheParamsDic[name+".playId"])
        {
            playId = m_pBT.cacheParamsDic[name+".playId"];
        }
        if(m_pBT.cacheParamsDic[name+".playDuration"])
        {
            playDuration = m_pBT.cacheParamsDic[name+".playDuration"];
        }
        if(m_pBT.cacheParamsDic[name+".playProbability"])
        {
            playProbability = m_pBT.cacheParamsDic[name+".playProbability"];
        }
        if(m_pBT.cacheParamsDic[name+".playMode"])
        {
            playMode = m_pBT.cacheParamsDic[name+".playMode"];
        }
        m_idVec = playId.split("-");
    }

    override public final function _doExecute(inputData:Object):int
    {
        var dataIO : IAIHandler = inputData.handler;
        if(dataIO==null)return CNodeRunningStatusEnum.FAIL;
        var owner : CGameObject = inputData.owner;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
            var rand:Number = Math.random();
            if(rand<=playProbability)
            {
                var len:int = m_idVec.length;
                var index:int = -1;
                if(playMode=="Random")
                {
                    index = int(Math.random()*len);
                    if(m_idVec[index]==0){
                        CAILog.logMsg("说话id为0，不用执行说话，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog);
                        m_elapsedTime=0;
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                    dataIO.play(owner,playType,m_idVec[index],playDuration,playMode);
                    CAILog.logMsg("播放类型"+playType+"，播放时间"+playDuration,pAIComponent.objId , CAILog.enabledFailLog );
                }
                else
                {
                    if(m_playIndex==m_idVec.length)
                    {
                        m_playIndex = 0;
                    }
                    index = m_playIndex;
                    if(m_idVec[index]==0){
                        CAILog.logMsg("说话id为0，不用执行说话，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
                        m_elapsedTime=0;
                        return CNodeRunningStatusEnum.SUCCESS;
                    }
                    dataIO.play(owner,playType,m_idVec[index],playDuration,playMode);
                    m_playIndex++;
                }
            }
            else
            {
                CAILog.logMsg("执行概率为"+playProbability+"，本次概率为"+rand+"，执行失败，退出"+getName(),pAIComponent.objId , CAILog.enabledFailLog );
                m_elapsedTime=0;
                return CNodeRunningStatusEnum.FAIL;
            }
        CAILog.logMsg("播放成功，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.SUCCESS;
    }
}
}

class PlayType
{
    public static const AUDIO:String = "Audio";
    public static const Dailogue:String = "Dailogue";
}
