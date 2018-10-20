//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/12/14.
 * Time: 17:32
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Foundation;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.core.CGameObject;

    public class CSetDirectionAction extends CBaseNodeAction {

        private var levelDirectionPosTag : int = -1;

        private var m_pBT : CAIObject = null;
        private var m_bCouldDirectionTo : Boolean = true;
        private var m_count : int = 0;//目前AI执行频率0.1秒一次，执行三次这个节点，正好0.3秒，保证转向成功，临时做法，正确做法应该是取游戏时间进行累加达到0.5秒

        public function CSetDirectionAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            try {
                if ( m_pBT.cacheParamsDic[ name + ".levelDirectionPosTag" ] > -1 ) {
                    levelDirectionPosTag = m_pBT.cacheParamsDic[ name + ".levelDirectionPosTag" ];
                }
            }
            catch ( e : Error ) {
                throw e.message;
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var handler : IAIHandler = inputData.handler;
            if ( handler == null )return CNodeRunningStatusEnum.FAIL;
            var owner : CGameObject = inputData.owner;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logEnterInfo(getName() , pAIComponent.objId , '');//( "进入" + getName(), pAIComponent.objId , CAILog.enabledFailLog);
            var pt : Object = handler.getLevelPosTag( levelDirectionPosTag );
            if ( m_bCouldDirectionTo ) {
                m_bCouldDirectionTo = false;
                if ( pt ) {
                    m_count++;
                    CAILog.logEnterSubNodeInfo( getName() + "-TurnDir" , " In turning " , pAIComponent.objId );//( "正在转向关卡指定点方向，返回正在执行，退出" + getName(), pAIComponent.objId );
                    handler.setDirectionToPoint( owner, pt.x, pt.y );
                    return CNodeRunningStatusEnum.EXECUTING;
                }
                else {
                    CAILog.traceMsg( "关卡指定位置不存在，标签名：" + levelDirectionPosTag, pAIComponent.objId );
                }
                if ( pAIComponent.currentAttackable ) {
                    m_count++;
                    CAILog.logEnterSubNodeInfo( getName() + "-TurnDir" , " In turning " , pAIComponent.objId );//( "正在转向关卡指定点方向，返回正在执行，退出" + getName(), pAIComponent.objId );
                    handler.setDirectionToGameObj( owner );
                    return CNodeRunningStatusEnum.EXECUTING;
                }
                else {
                    m_bCouldDirectionTo = true;
                    //小幅游走，没有目标，就已自身前方的范围为基准
                    CAILog.logExistInfo(getName() , "--has not target , may not do turning ",pAIComponent.objId );//( "攻击目标不存在，不用转向，返回成功，退出" + getName(), pAIComponent.objId );
                    return CNodeRunningStatusEnum.SUCCESS;
                }
            } else {
                m_count++;
            }

            if ( m_count >= 3 ) {
                m_count = 0;
                m_bCouldDirectionTo = true;
                CAILog.logExistInfo(getName() , "",pAIComponent.objId );//( "攻击目标不存在，不用转向，返回成功，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.SUCCESS;
            }
            CAILog.logEnterSubNodeInfo( getName() + "-TurnDir" , " In turning " , pAIComponent.objId );//( "正在转向关卡指定点方向，返回正在执行，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.EXECUTING;
        }
    }
}
