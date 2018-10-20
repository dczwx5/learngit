//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/1.
 * Time: 11:24
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.CSkillList;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/1
     */
    public class CWorldBossSkillAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var m_bIsfirstInto : Boolean = false;

        private var wbSkillIndex : int = 0;
        private var m_vecSkills : Vector.<int>;

        public function CWorldBossSkillAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( m_pBT.cacheParamsDic[ name + ".wbSkillIndex" ] ) {
                wbSkillIndex = m_pBT.cacheParamsDic[ name + ".wbSkillIndex" ];
            }

            if( !m_vecSkills )
                    m_vecSkills = new Vector.<int>(1);
            m_vecSkills[0] = wbSkillIndex;
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            if ( pAIComponent.currentCastSkillNodeName == getName() ) {
                if ( pAIComponent.useSkillEnd && !m_bIsfirstInto ) {
                    CAILog.logMsg( "技能" + wbSkillIndex + "释放完毕，返回成功，退出" + getName(), pAIComponent.objId );
                    m_bIsfirstInto = true;
                    return CNodeRunningStatusEnum.SUCCESS;
                } else if ( pAIComponent.excutingSkill ) {
                    CAILog.logMsg( "技能" + wbSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId );
                    m_bIsfirstInto = false;
                    return CNodeRunningStatusEnum.EXECUTING;
                }
            }
            var skillId : Number = 0;
            skillId = (owner.getComponentByClass( CSkillList, true ) as CSkillList).getSkillIDByIndex( wbSkillIndex );
            if ( skillId == 0 ) {
                CAILog.logMsg( "技能" + pAIComponent.iSkillIndex + "正在释放中，返回正在执行，退出" + getName(), pAIComponent.objId );
                pAIComponent.skillFailed();
                return CNodeRunningStatusEnum.SUCCESS;
            }
            pAIComponent.currentCastSkillNodeName = getName();
            pAIComponent.skillBegin();
            dataIO.attackIgnoreWithSkillIdx( owner, wbSkillIndex );

            pAIComponent.piSkillIndexVec  = m_vecSkills;
            pAIComponent.iSkillCount = 1;
            pAIComponent.iSkillCount++;

            return CNodeRunningStatusEnum.EXECUTING;
        }

    }
}
