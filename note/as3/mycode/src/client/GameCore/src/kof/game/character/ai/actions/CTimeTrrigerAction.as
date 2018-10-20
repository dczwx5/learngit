//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2017/4/22.
 * Time: 19:38
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

public class CTimeTrrigerAction extends CBaseNodeAction {
        public function CTimeTrrigerAction( parentNode : CBaseNode, data : CAIObject = null, nodeName : String = null,nodeIndex:int=-1 ) {
            super( parentNode, data, nodeName );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
        }

        override public final function _doExecute(inputData:Object):int
        {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
            if(pAIComponent.isOverrideAction){
                if ( dataIO.getCharacterState( owner, CCharacterStateBoard.IN_ATTACK) || !dataIO.getCharacterState( owner, CCharacterStateBoard.IN_CONTROL))
                {
                    return CNodeRunningStatusEnum.EXECUTING;
                }
                if ( pAIComponent.bCanResetState_GANGTI ) {
                    pAIComponent.bCanResetState_GANGTI = false;
                    dataIO.resetGANGTI( owner );
                    CAILog.logMsg("重置刚体成功，退出" + getName(), pAIComponent.objId );
                }
                if ( pAIComponent.bCanResetState_WUDI ) {
                    pAIComponent.bCanResetState_WUDI = false;
                    dataIO.resetWUDI( owner );
                    CAILog.logMsg( "重置无敌成功，退出" + getName(), pAIComponent.objId );
                }
                if ( pAIComponent.bCanResetState_PATI ) {
                    pAIComponent.bCanResetState_PATI = false;
                    dataIO.resetPATI( owner );
                    CAILog.logMsg( "重置霸体成功，退出" + getName(), pAIComponent.objId );
                }
                pAIComponent.excutingSkill = false;
                pAIComponent.useSkillEnd = true;
                pAIComponent.isOverrideAction = false;
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
