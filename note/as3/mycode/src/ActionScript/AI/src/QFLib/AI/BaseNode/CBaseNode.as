//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili(guoyiligo@qq.com) on 2016/5/6.
 * Time: 11:27
 */
package QFLib.AI.BaseNode {

    import QFLib.AI.CAIObject;
    import QFLib.AI.Enum.CNodeRunningStatusEnum;
    import QFLib.Foundation;

    public class CBaseNode {
        public function CBaseNode( parent : CBaseNode ) {
        }

        /*进入此节点的动态条件*/
        public function evaluate( input : Object ) : Boolean {
            return judgementCondtion( input ) && _doEvaluate( input );
        }

        /*进入此节点的固定条件*/
        protected function _doEvaluate( input : Object ) : Boolean {
            return true;
        }

        /*节点转移，比如在优先选择节点下，子节点A的优先级大于B，当正在运行B时，发现A可以运用了，此时就调用此方法转移到A节点去运行*/
        public function transition( input : Object ) : void {
            _doTransition( input );
        }

        protected function _doTransition( input : Object ) : void {

        }

        /*更新节点的方法*/
        public function tick( input : Object ) : int {
            return _doTick( input );
        }

        protected function _doTick( input : Object ) : int {
            return CNodeRunningStatusEnum.SUCCESS;
        }

        /*设置父节点*/
        public function set parentNode( pNode : CBaseNode ) : void {
            m_parentNode = pNode;
        }

        public function get parentNode() : CBaseNode {
            return m_parentNode;
        }

        /*设置节点要满足的条件*/
        public function setNodeCondition( nodeCondition : CBaseNodeCondition ) : void {
            if ( m_nodeCondtionVec == null ) {
                m_nodeCondtionVec = new Vector.<CBaseNodeCondition>();
            }
            m_nodeCondtionVec.push( nodeCondition );
        }

        private function judgementCondtion( input : Object ) : Boolean {
            if ( m_nodeCondtionVec == null ) {
                return true;
            }
            var bool : Boolean = false;
            for each ( var conditionNode : CBaseNodeCondition in m_nodeCondtionVec ) {
                bool = conditionNode.enterCondition( input );
                if ( !bool ) {
                    return false;
                }
            }
            return true;
        }

        /*设置节点名称*/
        public function setName( sName : String ) : void {
            m_Name = sName;
        }

        /*获取节点名称*/
        public function getName() : String {
            return m_Name;
        }

        /*获取上一个活动节点*/
        public function getLastActiveNode() : CBaseNode {
            return m_lastActiveNode;
        }

        /*设置活动节点*/
        public function setActiveNode( newNode : CBaseNode ) : void {
            m_lastActiveNode = m_activeNode;
            m_activeNode = newNode;
            if ( m_parentNode != null ) {
                m_parentNode.setActiveNode( newNode );
            }
        }

        /*检查索引是否超出子节点范围*/
        protected function _checkIndex( index : int ) : Boolean {
            return index >= 0 && index < m_childNodeCount;
        }

        /*添加子节点*/
        public function addChildNode( childNode : CBaseNode ) : void {
            m_childNodeVec.push( childNode );
            m_childNodeCount++;
        }

        /**编辑器中元件模板的索引，用于区别*/
        public function setTemplateIndex( index : int ) : void {
            m_index = index;
        }

        public function setTemplateName( name : String ) : void{
            m_templateName = name;
        }

        public function getTemplateName() : String{
            return m_templateName;
        }

        public function getTemplateIndex() : int {
            return m_index;
        }

        public function set aiObj(value:CAIObject) : void {
            _aiObj = value;
        }

        public function get aiObj():CAIObject
        {
            return _aiObj;
        }

        /*当前节点的子节点集合*/
        protected var m_childNodeVec : Vector.<CBaseNode> = new Vector.<CBaseNode>();
        /*子节点的个数*/
        protected var m_childNodeCount : int;
        /*当前节点的父节点*/
        protected var m_parentNode : CBaseNode;
        /**进此节点的条件集合*/
        protected var m_nodeCondtionVec : Vector.<CBaseNodeCondition>;
        /*上一个活动节点*/
        protected var m_lastActiveNode : CBaseNode;
        /*活动节点*/
        protected var m_activeNode : CBaseNode;
        /*节点名称*/
        protected var m_Name : String;
        /**模板索引*/
        protected var m_index : int = -1;
        protected var _aiObj : CAIObject = null;

        protected var m_templateName : String;
    }
}
