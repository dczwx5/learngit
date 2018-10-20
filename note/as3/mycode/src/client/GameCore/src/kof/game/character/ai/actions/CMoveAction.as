//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/8.
 * Time: 12:02
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;
import QFLib.Foundation;

import flash.geom.Point;

import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.aiDataIO.IAIHandler;
import kof.game.core.CGameObject;

public class CMoveAction extends CBaseNodeAction {
    private var moveType:String =TO_OFFSET;
    private var moveOffsetX:Number = 20;
    private var moveOffsetY:Number = 20;
    private var levelPosTag:int = -1;

    public static const TO_OFFSET:String = "ToOffset";
    public static const TO_LEVEL_POS:String = "ToLevelPos";

    private var m_pBT:CAIObject = null;
    private var isArrive : Boolean = false;
    private var m_pAIComponent:CAIComponent = null;
//    private var _isMoving:Boolean=false;

    public function CMoveAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null ,nodeIndex:int=-1) {
        super( parentNode, pBt );
        if(nodeIndex>-1)
        {
            setTemplateIndex(nodeIndex);
            setName(nodeIndex+"_"+nodeName);
        }
        else
        {
            setName(nodeName);
        }
        this.m_pBT = pBt;
        _initNodeData();
    }

    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
        try
        {
            if(m_pBT.cacheParamsDic[name+".moveType"])
            {
                moveType = m_pBT.cacheParamsDic[name+".moveType"];
            }
            if(m_pBT.cacheParamsDic[name+".moveOffsetX"])
            {
                moveOffsetX = m_pBT.cacheParamsDic[name+".moveOffsetX"];
            }
            if(m_pBT.cacheParamsDic[name+".moveOffsetY"])
            {
                moveOffsetY = m_pBT.cacheParamsDic[name+".moveOffsetY"];
            }
            if(m_pBT.cacheParamsDic[name+".levelPosTag"]!=undefined)
            {
                levelPosTag = m_pBT.cacheParamsDic[name+".levelPosTag"];
            }
        }
        catch (e:Error)
        {
            throw e.message;
        }
    }

    override public final function _doExecute( inputData : Object ) : int
    {
        var handler : IAIHandler = inputData.handler;
        if(handler==null)return CNodeRunningStatusEnum.FAIL;
        var owner : CGameObject = inputData.owner;
        var pAIComponent:CAIComponent = owner.getComponentByClass(CAIComponent,true) as CAIComponent;
        CAILog.logMsg("进入"+getName(),pAIComponent.objId);
        if (handler.isDefensing(owner)) {
            CAILog.logMsg("角色处于防御状态，返回失败，退出"+getName(),pAIComponent.objId);
            moveEndCallBack();
            return CNodeRunningStatusEnum.FAIL;
        } else if ( isArrive ) {
            CAILog.logMsg("到达目标位置，返回成功，退出"+getName(),pAIComponent.objId);
            isArrive = false;
            return CNodeRunningStatusEnum.SUCCESS;
        } else {
            var bool:Boolean;
            if ( moveType == TO_OFFSET ) {
                CAILog.logMsg("调用move方法，移动类型为"+moveType,pAIComponent.objId);
                bool=handler.move( owner,[], moveOffsetX, moveOffsetY, moveEndCallBack );
            }
            else if ( moveType == TO_LEVEL_POS ) {
                moveOffsetX = 0.0; //Math.random()*400-200;//保证工会boss七家社触发区域触发器
                moveOffsetY = 0.0; //Math.random()*40-20;
                var pt : Object = handler.getLevelPosTag( levelPosTag );
                if(pt)
                {
                    CAILog.logMsg("移动到关卡指定位置:"+pt.x+"，"+pt.y+"偏移量:"+moveOffsetX+","+moveOffsetY,pAIComponent.objId);
                    bool=handler.move( owner,[pt], moveOffsetX, moveOffsetY, moveEndCallBack );
                }
                else
                {
                    CAILog.warningMsg("关卡指定位置不存在，标签名："+levelPosTag,pAIComponent.objId);
                }

            }
            if(bool==false)
            {
                CAILog.logMsg("移动结束，返回成功，退出"+getName(),pAIComponent.objId);
                pAIComponent.resetMoveCallBakcFunc=null;
                moveEndCallBack();
                return CNodeRunningStatusEnum.SUCCESS;
            }
            pAIComponent.resetMoveCallBakcFunc=moveEndCallBack;
        }
        pAIComponent.isBeAttacked = false;
        CAILog.logMsg("正在移动，返回正在执行，退出"+getName(),pAIComponent.objId);
        return CNodeRunningStatusEnum.EXECUTING;
    }

    //重置移动状态
    private function moveEndCallBack() : void {

        isArrive = true;
        if(m_pAIComponent)
        {
            m_pAIComponent.useSkillEnd = false;
        }
    }
}
}
