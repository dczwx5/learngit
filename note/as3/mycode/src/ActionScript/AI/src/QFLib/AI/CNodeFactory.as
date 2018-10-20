//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/7.
 * Time: 11:42
 */
package QFLib.AI {

    import QFLib.AI.BaseNode.CBaseNode;
    import QFLib.AI.BaseNode.CBaseNodeAction;
    import QFLib.AI.BaseNode.CBaseNodeCondition;
    import QFLib.AI.Composites.CNodeLoop;
    import QFLib.AI.Composites.CNodeParallel;
    import QFLib.AI.Composites.CNodePrioritySelector;
    import QFLib.AI.Composites.CNodeSelector;
    import QFLib.AI.Composites.CNodeSequence;

    import flash.net.getClassByAlias;
    import flash.utils.getDefinitionByName;

    internal class CNodeFactory {
        private static var _nodeConditionVec : Vector.<CBaseNodeCondition> = new Vector.<CBaseNodeCondition>();

        public function CNodeFactory() {
        }

        public static var pBT : CAIObject = null;
        private static var _index : int = -1;
        private static var _templateName : String;

        /**
         *
         * @param jsonData 行为树的json数据
         * @param bt AIObject 对象
         * @param index 组合模板中子模板的索引
         * @param tName 组合模板中子模板名字
         **/
        public static function createBehaviorTree( jsonData : Object, bt : CAIObject, index : int = -1 ,tName : String = '') : CBaseNode {
            var rootNode : CBaseNode;
            pBT = bt;
            _index = index;
            _templateName = tName;
            rootNode = _createRootNode( jsonData );
            if( _templateName != null || _templateName != "")
                    rootNode.setTemplateName( _templateName );

            if ( jsonData.children.length > 0 ) {
                _createChildeNode( jsonData.children, rootNode );
            }
            return rootNode;
        }

        private static function _createRootNode( jsonData : Object ) : CBaseNode {
            var type : String = jsonData.objectType;
            switch ( type ) {
                case "PrioritySelector":
                {
                    return _createPrioritySelectorNode( null, jsonData.name );
                }
                case "Selector":
                {
                    return _createSelectorNode( null, jsonData.name );
                }
                case "Parallel":
                {
                    return _createParalleNode( null, jsonData.name );
                }
                case "Sequence":
                {
                    return _createSequenceNode( null, jsonData.name );
                }
                case "Loop":
                {
                    return _createLoopNode( null, jsonData.name );
                }
            }
            return null;
        }

        private static function _createChildeNode( childNodeArr : Array, parentNode : CBaseNode ) : void {
            var len : int = childNodeArr.length;
            for ( var i : int = 0; i < len; i++ ) {
                var nodeData : Object = new Object();
                for ( var key : String in childNodeArr[ i ] ) {
                    nodeData[ key ] = childNodeArr[ i ][ key ];
                }
                _createNode( nodeData, parentNode );
            }
        }

        private static function _createNode( nodeData : Object, parentNode : CBaseNode ) : void {
            var type : String = nodeData.objectType;
            var sName : String = nodeData.name;
            var node : CBaseNode;
            var str : String = "";
            if ( type.length >= 6 ) {
                str = type.substr( -6, 6 );
            }
            try {
                if ( str == "Action" ) {
                    pBT.setCacheNodeParams( nodeData, _index );
                    node = _createActionNode( getClassByAlias( "aiSystem.actions." + type ), parentNode, sName );
                } else if ( str == "dition" ) {
                    pBT.setCacheNodeParams( nodeData, _index );

                    var nodeCondtion : CBaseNodeCondition = _createCondtionNode( getClassByAlias( "aiSystem.conditions." + type ), sName );
                    _nodeConditionVec.push( nodeCondtion );
                } else {
                    switch ( type ) {
                        case "PrioritySelector":
                        {
                            node = _createPrioritySelectorNode( parentNode, sName );
                            break;
                        }
                        case "Selector":
                        {
                            node = _createSelectorNode( parentNode, sName );
                            break;
                        }
                        case "Parallel":
                        {
                            node = _createParalleNode( parentNode, sName );
                            break;
                        }
                        case "Sequence":
                        {
                            node = _createSequenceNode( parentNode, sName );
                            break;
                        }
                        case "Loop":
                        {
                            pBT.setCacheNodeParams( nodeData );
                            node = _createLoopNode( parentNode, sName );
                            break;
                        }
                    }
                }
            } catch ( e : Error ) {
                throw e.message;
            }

            if ( nodeData.children && nodeData.children.length > 0 ) {
                _createChildeNode( nodeData.children, node )
            }
        }

        private static function _createParalleNode( parent : CBaseNode, sName : String = "" ) : CBaseNode {
            var node : CNodeParallel = new CNodeParallel( parent ,sName);
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createPrioritySelectorNode( parent : CBaseNode, sName : String = "" ) : CBaseNode {
            var node : CNodePrioritySelector = new CNodePrioritySelector( parent ,sName);
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createSelectorNode( parent : CBaseNode, sName : String = "" ) : CBaseNode {
            var node : CNodeSelector = new CNodeSelector( parent ,sName,_index);
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createSequenceNode( parent : CBaseNode, sName : String = "" ) : CBaseNode {
            var node : CNodeSequence = new CNodeSequence( parent ,sName,_index);
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createLoopNode( parent : CBaseNode, sName : String ) : CBaseNode {
            var node : CNodeLoop = new CNodeLoop( parent, pBT, sName );
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createCondtionNode( c : Class, sName : String ) : CBaseNodeCondition {
            var node : CBaseNodeCondition = new c( pBT, sName, _index );
            node.aiObj = pBT;
            node.setTemplateName(_templateName);
            return node;
        }

        /*创建执行节点的模板方法*/
        private static function _createActionNode( cls : Class, parent : CBaseNode, sName : String ) : CBaseNode {
            var node : CBaseNodeAction = new cls( parent, pBT, sName, _index );
            _createNodeCommon( node, parent, sName );
            return node;
        }

        private static function _createNodeCommon( me : CBaseNode, parent : CBaseNode, sName : String ) : void {
            me.aiObj = pBT;
            me.setTemplateName( _templateName );
            if ( parent ) {
                me.parentNode = parent;
                parent.addChildNode( me );
            }
            if ( _nodeConditionVec.length > 0 ) {
                var len : int = _nodeConditionVec.length;
                for ( var i : int = 0; i < _nodeConditionVec.length; i++ ) {
                    me.setNodeCondition( _nodeConditionVec[ i ] );
                }
                _nodeConditionVec.splice( 0, _nodeConditionVec.length );
            }
        }
    }
}

