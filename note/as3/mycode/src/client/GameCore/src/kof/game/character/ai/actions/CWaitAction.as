//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/7/31.
 * Time: 18:12
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/7/31
     *
     * 等待记时节点，时间到返回成功，否则返回失败
     */
    public class CWaitAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;
        private var m_elapsedTime : Number = 0;

        private var waitTime : Number = 0;

        public function CWaitAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( m_pBT.cacheParamsDic[ name + ".waitTime" ] ) {
                waitTime = m_pBT.cacheParamsDic[ name + ".waitTime" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            m_elapsedTime += inputData.deltaTime;
            if ( executable && pAIComponent.useSkillEnd ) {
                m_elapsedTime -= waitTime;
                CAILog.logMsg( "没处于技能释放中，等待时间达到" + waitTime + "返回成功", pAIComponent.objId );
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logMsg( "技能是否完成" + pAIComponent.useSkillEnd + "，等待时间达到" + m_elapsedTime + "没有达到" + waitTime + ",返回失败", pAIComponent.objId );
            return CNodeRunningStatusEnum.FAIL;
        }

        private function get executable() : Boolean {
            return m_elapsedTime - waitTime >= 0;
        }
    }
}
