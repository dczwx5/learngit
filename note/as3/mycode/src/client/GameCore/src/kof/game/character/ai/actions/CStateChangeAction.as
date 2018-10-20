//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/5/16.
 * Time: 16:40
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.property.interfaces.ICharacterProperty;

    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/5/16
     *
     * 物件动作状态改变
     */
    public class CStateChangeAction extends CBaseNodeAction {
        private var m_pBT : CAIObject = null;
        private var stateChangeFlag : String = "";//状态标签
        private var actionChangeFlag : String = "";//动作标签
        private var hurtChangeFlag : String = "";//受击标签
        private var stateChangeHpValue : String = "50";
        private var _hpValueVec : Vector.<Number> = new <Number>[];
        private var _actionValueVec : Vector.<String> = new <String>[];
        private var _stateValueVec : Vector.<String> = new <String>[];
        private var _hurtValueVec : Vector.<String> = new <String>[];
        private var _count : int = 0;
        private var _maxCount : int = 0;
        private var _currentNu : Number = 0;

        public function CStateChangeAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
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
            if ( m_pBT.cacheParamsDic[ name + ".stateChangeFlag" ] ) {
                stateChangeFlag = m_pBT.cacheParamsDic[ name + ".stateChangeFlag" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".actionChangeFlag" ] ) {
                actionChangeFlag = m_pBT.cacheParamsDic[ name + ".actionChangeFlag" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".stateChangeHpValue" ] ) {
                stateChangeHpValue = m_pBT.cacheParamsDic[ name + ".stateChangeHpValue" ];
            }
            if ( m_pBT.cacheParamsDic[ name + ".hurtChangeFlag" ] ) {
                hurtChangeFlag = m_pBT.cacheParamsDic[ name + ".hurtChangeFlag" ];
            }

            var arr : Array = stateChangeHpValue.split( "-" );
            var i : int = 0;
            for ( i = 0; i < arr.length; i++ ) {
                _hpValueVec.push( Number(arr[ i ]) );
            }
            _maxCount = _hpValueVec.length;
            arr = actionChangeFlag.split( "-" );
            for ( i = 0; i < arr.length; i++ ) {
                _actionValueVec.push( arr[ i ] );
            }
            arr = stateChangeFlag.split( "-" );
            for ( i = 0; i < arr.length; i++ ) {
                _stateValueVec.push( arr[ i ] );
            }
            arr = hurtChangeFlag.split( "-" );
            for ( i = 0; i < arr.length; i++ ) {
                _hurtValueVec.push( arr[ i ] );
            }
        }

        override public final function _doExecute( inputData : Object ) : int {
            var owner : CGameObject = inputData.owner as CGameObject;
            var dataIO : IAIHandler = inputData.handler as IAIHandler;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logEnterInfo(getName() , pAIComponent.objId ,"");
            var pFacadeProperty : ICharacterProperty = owner.getComponentByClass( ICharacterProperty, true ) as ICharacterProperty;
            _currentNu = pFacadeProperty.HP / Number( pFacadeProperty.MaxHP );
            if ( _count < _maxCount ) {
                var compareNu : Number = -1;
                for ( var i : int = _count; i < _hpValueVec.length; i++ ) {
                    compareNu = _hpValueVec[ i ] / 100;
                    if ( _currentNu < compareNu ) {
                        _count++;
                        if ( actionChangeFlag != "" ) {
                            dataIO.stateChange( owner, _stateValueVec[ _count-1 ], _actionValueVec[ _count-1 ], _hurtValueVec[ _count-1 ] );
                        }
                        else {
                            dataIO.stateChange( owner, null, null );
                        }
                        CAILog.traceMsg( "当前生命值百分比:" + _currentNu + "，大于目标生命值百分比:" + compareNu + "，返回成功，退出" + getName(), pAIComponent.objId );
                        break;//一次一次执行
                    }
                    else {
                        CAILog.logMsg( "当前生命值百分比:" + _currentNu + "，大于目标生命值百分比:" + compareNu + "，返回失败，退出" + getName(), pAIComponent.objId );
                        return CNodeRunningStatusEnum.FAIL;
                    }
                }
            }
            else {
                CAILog.logMsg( "执行次数:" + _count + "超过生命值数组长度:" + _maxCount + "，返回失败，退出" + getName(), pAIComponent.objId );
                return CNodeRunningStatusEnum.FAIL;
            }
            return CNodeRunningStatusEnum.SUCCESS;
        }
    }
}
