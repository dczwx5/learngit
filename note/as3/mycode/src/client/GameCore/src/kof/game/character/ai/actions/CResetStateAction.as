//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/5.
 * Time: 16:14
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAILog;
import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/5
     */
    public class CResetStateAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        public function CResetStateAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            this.m_pBT = pBt;
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_ATTACK) || !dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL)/*||!dataIO.getCharacterState( owner, CCharacterStateBoard.ON_GROUND)*/)
            {
                //AI逻辑上技能节点已经结束了，但是可能技能的动作还没播完，所以要判断
//                trace("处于攻击状态!");
                return CNodeRunningStatusEnum.EXECUTING;
            }

            if ( pAIComponent.bCanResetState_GANGTI ) {
                pAIComponent.bCanResetState_GANGTI = false;
                dataIO.resetGANGTI( owner );
                CAILog.logMsg( "是否需要重置：" + pAIComponent.bCanResetState_GANGTI + "返回成功，退出" + getName(), pAIComponent.objId );
            }
            if ( pAIComponent.bCanResetState_WUDI ) {
                pAIComponent.bCanResetState_WUDI = false;
                dataIO.resetWUDI( owner );
                CAILog.logMsg( "是否需要重置：" + pAIComponent.bCanResetState_WUDI + "返回成功，退出" + getName(), pAIComponent.objId );
            }
            if ( pAIComponent.bCanResetState_PATI ) {
                pAIComponent.bCanResetState_PATI = false;
                dataIO.resetPATI( owner );
                CAILog.logMsg( "是否需要重置：" + pAIComponent.bCanResetState_PATI + "返回成功，退出" + getName(), pAIComponent.objId );
            }

            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
