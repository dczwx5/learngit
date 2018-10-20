//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/8.
 * Time: 20:11
 */
package kof.game.character.ai.actions {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;

    import kof.game.character.ai.CAIComponent;
    import kof.game.character.ai.CAILog;

    import kof.game.character.ai.aiDataIO.IAIHandler;
    import kof.game.character.state.CCharacterStateBoard;
    import kof.game.core.CGameObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/8
     */
    public class CReviveAction extends CBaseNodeAction {
        private var _pBT : CAIObject = null;
        private var reviveMinTime : Number = 0;
        private var reviveMaxTime : Number = 10;

        private var _elapsedTime : Number = 0;
        private var _targetTime : Number = 0;

        public function CReviveAction( parentNode : CBaseNode, pBt : CAIObject = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super( parentNode, pBt );
            if ( nodeIndex > -1 ) {
                setTemplateIndex( nodeIndex );
                setName( nodeIndex + "_" + nodeName );
            }
            else {
                setName( nodeName );
            }
            this._pBT = pBt;
            _initNodeData();
        }

        private function _initNodeData() : void {
            var name : String = getName();
            if ( name == null )return;
            if ( _pBT.cacheParamsDic[ name + ".reviveMinTime" ] ) {
                reviveMinTime = _pBT.cacheParamsDic[ name + ".reviveMinTime" ];
            }
            if ( _pBT.cacheParamsDic[ name + ".reviveMaxTime" ] ) {
                reviveMaxTime = _pBT.cacheParamsDic[ name + ".reviveMaxTime" ];
            }
            _targetTime = Math.random() * reviveMaxTime + reviveMinTime;
        }

        override final public function _doExecute( data : Object ) : int {
            var dataIO : IAIHandler = data.handler as IAIHandler;
            var owner : CGameObject = data.owner as CGameObject;
            var pAIComponent : CAIComponent = owner.getComponentByClass( CAIComponent, true ) as CAIComponent;
            CAILog.logMsg( "进入" + getName(), pAIComponent.objId );
            var characterState : CCharacterStateBoard = owner.getComponentByClass( CCharacterStateBoard, true ) as CCharacterStateBoard;
            if ( characterState.getValue( CCharacterStateBoard.DEAD ) ) {
                _elapsedTime += data.deltaTime;
                if ( executabel ) {
                    dataIO.revive( owner );
                    _elapsedTime = 0;
                    _targetTime = Math.random() * reviveMaxTime + reviveMinTime;
                    return CNodeRunningStatusEnum.SUCCESS;
                }
                return CNodeRunningStatusEnum.EXECUTING;
            }
            return CNodeRunningStatusEnum.FAIL;
        }

        private function executabel() : Boolean {
            return _elapsedTime - _targetTime >= 0;
        }
    }
}
