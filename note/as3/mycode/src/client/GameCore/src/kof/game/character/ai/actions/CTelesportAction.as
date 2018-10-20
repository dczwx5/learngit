//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/1.
 * Time: 10:11
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Math.CVector2;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/1
     */
    public class CTelesportAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;
        private var btelesportComplete : Boolean = false;

        private var telesportLoop : Boolean = false;
        private var teleLevelTags : int = 0;

        public function CTelesportAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            this.m_pBT = pBt;
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( m_pBT.cacheParamsDic[ name + ".telesportLoop" ] ) {
                telesportLoop = m_pBT.cacheParamsDic[ name + ".telesportLoop" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".teleLevelTags" ] ) {
                teleLevelTags = m_pBT.cacheParamsDic[ name + ".teleLevelTags" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            var localtion : Object = dataIO.getLevelPosTag( teleLevelTags );
            if( null == localtion ) {
                CAILog.logExistUnSatisfyInfo(getName() , "没有配置传送或找不到传送点坐标数据", pAIComponent.objId );
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if ( !btelesportComplete ) {
                CAILog.logMsg( "传送到" + localtion.x + "," + localtion.y, pAIComponent.objId );
                dataIO.teleportToPosition( owner, new CVector2( localtion.x, localtion.y ), callBack );
            } else {
                CAILog.logMsg( "传送成功，退出" + getName(), pAIComponent.objId );
                btelesportComplete = false;
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logMsg( "正在传送中", pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }

        private function callBack() : void {
            btelesportComplete = true;
        }
    }
}
