//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/8/10.
 * Time: 19:48
 */
package kof.game.character.ai.conditions {

    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.CAIObject;

    /**
     * @author yili(guoyiligo@qq.com)
     * 2017/8/10
     */
    public class CRandomProbabilityCondition extends CBaseNodeCondition {
        private var randomProbability : Number = 0;//随机概率

        private var m_pBT : CAIObject = null;

        public function CRandomProbabilityCondition( pBt : Object = null, nodeName : String = null, nodeIndex : int = -1 ) {
            super();
            this.m_pBT = pBt as CAIObject;
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
            if ( m_pBT.cacheParamsDic[ name + ".randomProbability" ] ) {
                randomProbability = m_pBT.cacheParamsDic[ name + ".randomProbability" ];
            }
        }

        override protected function externalCondition( inputData : Object ) : Boolean {
            var rnd : Number = Math.random();
            if ( rnd <= randomProbability ) {
                return true;
            } else {
                return false;
            }
            return true;
        }

    }
}
