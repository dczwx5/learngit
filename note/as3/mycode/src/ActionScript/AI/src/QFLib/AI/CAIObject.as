//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 9:58
 */
package QFLib.AI {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.events.CAIEvent;

    import flash.events.Event;

    import flash.events.EventDispatcher;

    import flash.utils.Dictionary;

    import mx.utils.StringUtil;

    public class CAIObject {
        public var behaviorTree : CBaseNode;
        private var m_inputData : Object;
        private var m_cacheParamsDic : Dictionary = new Dictionary();
        private var m_elapsedTime : Number = 0;

        private var _eventDispather : EventDispatcher = null;

        public function CAIObject( jsonObj : Object, aiParams : String, data : Object = null ) {
            _eventDispather = new EventDispatcher();
            _parseAiParams( aiParams );
            m_inputData = data;
            behaviorTree = CNodeFactory.createBehaviorTree( jsonObj, this );
            if ( behaviorTree == null )throw new Error().message = "行为树创建失败";
        }

        public function dispose() : void {
            behaviorTree = null;
            for ( var key : * in m_inputData ) {
                m_inputData[ key ] = null;
                delete m_inputData[ key ];
            }
            m_inputData = null;
            for ( var i : * in m_cacheParamsDic ) {
                m_cacheParamsDic[ i ] = null;
                delete m_cacheParamsDic[ i ];
            }
            m_cacheParamsDic = null;
        }

        public function update( delayTime : Number, deltaTime : Number ) : void {
            //tick behavior tree
            m_elapsedTime += deltaTime;//每帧时间增量
            if ( m_elapsedTime - delayTime >= 0 ) {
                if ( m_inputData && behaviorTree && behaviorTree.evaluate( m_inputData ) ) {
                    m_inputData.deltaTime = delayTime;
                    behaviorTree.tick( m_inputData );
                }
                m_elapsedTime -= delayTime;
            }
        }

        //对行为树中各节点用到的参数进行映射，便于外部配置
        public function setCacheNodeParams( nodeData : Object, index : int = -1 ) : void {
            if ( nodeData.param == null )return;
            var param : Object = nodeData.param;
            var prefix : String = "";
            var suffix : String = "";
            if ( index != -1 ) {
                prefix = index + "_";
                //suffix = index + "";
            }
            for ( var key : String in param ) {
                var name : String = prefix + nodeData[ "name" ] + suffix + "." + key;
                var hasInDic : Boolean = false;
                for ( var obj : * in m_cacheParamsDic ) {
                    if ( name == obj ) {
                        hasInDic = true;
                        break;
                    }

                }
                if ( !hasInDic ) {
                    m_cacheParamsDic[ name ] = param[ key ];
                }
            }
        }

        public function get cacheParamsDic() : Dictionary {
            return m_cacheParamsDic;
        }

        public function _parseAiParams( aiParams : String ) : void {
            if ( aiParams == null || aiParams == "" )return;
            var arr : Array = aiParams.split( "," );
            var len : int = arr.length;
            var rex : RegExp = /'/g;
            var rex1 : RegExp = /\s+/g;
            for ( var i : int = 0; i < len; i++ ) {
                var valueArr : Array = arr[ i ].split( "=" );
                var str : String = valueArr[ 1 ];
                str = StringUtil.trim( str );
                str = str.replace( rex, "" );
                str = str.replace( rex1, "" );
                var str1 : String = valueArr[ 0 ];
                str1 = str1.replace( rex1, "" );
                configAiParams( str1, str );
            }
        }

        private function configAiParams( key : String, value : * ) : void {
            m_cacheParamsDic[ key ] = value;
        }

        /**返回根节点*/
        public function createBehaviorTree( jsonObj : Object, index : int = -1 ,tName : String = '' ) : CBaseNode {
            var rootNode : CBaseNode = CNodeFactory.createBehaviorTree( jsonObj, this, index , tName);
            return rootNode;
        }

        /**
         * 发送事件
         * @event 需要发送的事件
         * */
        public final function dispatchEvent( event : Event ) : void {
            _eventDispather.dispatchEvent( event );
        }

        /**
         * 侦听AI事件
         * @param eventType 事件类型
         * @param callBackFunc 要执行的回调函数
         *
         * */
        public final function addEventListener( eventType : String, callBackFunc : Function ) : void {
            _eventDispather.addEventListener( eventType, callBackFunc );
        }

        /**
         * 移除AI事件
         * @param eventType 事件类型
         * @param callBackFunc 要移除的回调函数
         *
         * */
        public final function removeEventListener( eventType : String, callBackFunc : Function ) : void {
            _eventDispather.removeEventListener( eventType, callBackFunc );
        }
    }
}
