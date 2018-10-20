//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/9.
 * Time: 20:21
 */
package kof.game.character.ai.conditions {

    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/10/9
     */
    public class CSkillExecuteIsSuccessCondition extends CBaseNodeCondition {
        private var m_pBT : CAIObject = null;

        public function CSkillExecuteIsSuccessCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super();
            this.m_pBT = pBt as CAIObject;
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
        }

        override protected final function externalCondition( inputData : Object ) : Boolean {
            var owner : CGameObject = inputData.owner as CGameObject;
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            if ( pAIComponent.bSkillExecuteSuccess ) {
                pAIComponent.bSkillExecuteSuccess = false;//重置技能执行成功的标志
                return true;
            }
            return false;
        }
    }
}
