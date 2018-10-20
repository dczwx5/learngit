//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/6/5.
 * Time: 15:24
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.ai.paramsTypeEnum.EFightStateType;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/6/5
     */
    public class CSetStateAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;

        private var setStateVal : String = EFightStateType.NULL;
        private var setStateAlways : Boolean = false;

        public function CSetStateAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( m_pBT.cacheParamsDic[ name + ".setStateVal" ] ) {
                setStateVal = m_pBT.cacheParamsDic[ name + ".setStateVal" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".setStateAlways" ] ) {
                setStateAlways = m_pBT.cacheParamsDic[ name + ".setStateAlways" ];
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var owner : CGameObject = inputData.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logEnterInfo(getName(),pAIComponent.objId , "");//( "进入" + getName(), pAIComponent.objId );
            if ( setStateVal == EFightStateType.NOT_BE_BREAK ) {//霸体
                pAIComponent.bSetStateAlways_PATI = setStateAlways;
                pAIComponent.bCanResetState_PATI = true;
                dataIO.setCharacterState( owner, setStateVal, false );
            }
            if ( setStateVal == EFightStateType.NOT_BE_BREAK_AND_CATCH ) {//刚体
                pAIComponent.bSetStateAlways_GANGTI = setStateAlways;
                pAIComponent.bCanResetState_GANGTI = true;
                dataIO.setCharacterState( owner, setStateVal, false );
            }
            if ( setStateVal == EFightStateType.NOT_BE_ATTACK ) {//无敌
                pAIComponent.bSetStateAlways_WUDI = setStateAlways;
                pAIComponent.bCanResetState_WUDI = true;
                dataIO.setCharacterState( owner, setStateVal, false );
            }
            CAILog.logExistInfo(getName() , " Set " + setStateVal , pAIComponent.objId );//( "状态值为：" + setStateVal + "返回成功，退出" + getName(), pAIComponent.objId );
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}