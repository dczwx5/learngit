//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/12.
 * Time: 15:55
 */
package kof.game.character.ai.actions {

import QFLib.AI.BaseNode.CBaseNode;
import QFLib.AI.BaseNode.CBaseNodeAction;
import QFLib.AI.CAIObject;
import QFLib.AI.Enum.CNodeRunningStatusEnum;

public class CInteractAction extends CBaseNodeAction {
    /**物件id*/
    private var articleId:int = 0;

    private var m_pBT:CAIObject=null;

    public function CInteractAction( parentNode : CBaseNode ,pBt:CAIObject=null,nodeName:String=null,nodeIndex:int=-1 ) {
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
        if(m_pBT.cacheParamsDic[name+".articleId"])
        {
            articleId = m_pBT.cacheParamsDic[name+".articleId"];
        }
    }

    override public final function _doExecute(inputData:Object):int
    {

        return CNodeRunningStatusEnum.EXECUTING;
    }

}
}
