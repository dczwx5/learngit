//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/6/15.
 * Time: 15:40
 */
package actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import aiDataIO.IAIDataIO;

    public class CFollowAction extends CBaseNodeAction {
    private var _isArrive : Boolean = false;
    //节点参数，可在怪物表里边配置
    public var followDistance:Number=150;

    private var pBT:CAIObject=null;

    public function CFollowAction(parentNode : CBaseNode , pBt:CAIObject=null, nodeName:String=null) {
        super( parentNode , pBt,nodeName);
        setName(nodeName);
        this.pBT=pBt;
        _initNodeData();
    }

    private function _initNodeData():void
    {
        var name:String = getName();
        if(name==null)return;
        if(pBT.cacheParamsDic[name+".followDistance"])
        {
            followDistance = pBT.cacheParamsDic[name+".followDistance"];
        }
    }

    override final public function _doEnter(data:Object):void
    {

    }

    override final public function _doExit(data:Object):void
    {

    }

    override final public function _doExecute(data:Object):int
    {
        var dataIO:IAIDataIO=data.handler as IAIDataIO;
        dataIO.followPlayer(movetoEndCallBack,followDistance);
        if ( _isArrive ) {
            _isArrive = false;
            return CNodeRunningStatusEnum.SUCCESS;
        }
        return CNodeRunningStatusEnum.EXECUTING;
    }

    private function movetoEndCallBack() : void {
        _isArrive = true;
    }
}
}
