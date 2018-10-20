//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/18.
 * Time: 17:56
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;

    import kof.game.character.ai.CAILog;
    import kof.game.character.ai.aiDataIO.IAIHandler;

    import kof.game.character.ai.paramsTypeEnum.ECampType;
    import kof.game.character.property.interfaces.ICharacterProperty;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/18
     */
    public class CSelectTargetForValueAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var stfvcampType : String = ECampType.ENEMY;
        private var stfvResPropertyType : String = PropertyType.LIFE;
        private var stfvResOperatorType : String = OperatorType.XIAO_YU;
        private var stfvValue : Number = 20;

        public function CSelectTargetForValueAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            this.m_pBT = pBt;
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( m_pBT.cacheParamsDic[ name + ".stfvcampType" ] ) {
                stfvcampType = m_pBT.cacheParamsDic[ name + ".stfvcampType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".stfvResPropertyType" ] ) {
                stfvResPropertyType = m_pBT.cacheParamsDic[ name + ".stfvResPropertyType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".stfvResOperatorType" ] ) {
                stfvResOperatorType = m_pBT.cacheParamsDic[ name + ".stfvResOperatorType" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".stfvValue" ] ) {
                stfvValue = m_pBT.cacheParamsDic[ name + ".stfvValue" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var handler : IAIHandler = inputData.handler;
            if ( handler == null )return CNodeRunningStatusEnum.FAIL;
            var owner : CGameObject = inputData.owner;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            var enemyObj : Vector.<CGameObject> = handler.findAllEnemyObj( owner );
            var pFacadeProperty : ICharacterProperty = null;
            var lCur : Number = 0;
            var ltarget : Number = 0;
            for each(var obj:CGameObject in enemyObj){
                pFacadeProperty = obj.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
                lCur = pFacadeProperty.HP / pFacadeProperty.MaxHP;
                ltarget = stfvValue / 100;
                if(lCur<ltarget){
                    pAIComponent.currentAttackable = obj;
                    return CNodeRunningStatusEnum.SUCCESS;
                }
            }
            return CNodeRunningStatusEnum.FAIL;
        }
    }
}
class PropertyType {
    public static const LIFE : String = "Life";
    public static const ATTACK : String = "Attack";
    public static const DEFENSE : String = "Defense";
    public static const ANGER : String = "Anger";
}
class OperatorType {
    public static const DENG_YU : String = "等于";
    public static const DA_YU : String = "大于";
    public static const XIAO_YU : String = "小于";
    public static const DAYU_DENGYU : String = "大于等于";
    public static const XIAOYU_DENGYU : String = "小于等于";
}