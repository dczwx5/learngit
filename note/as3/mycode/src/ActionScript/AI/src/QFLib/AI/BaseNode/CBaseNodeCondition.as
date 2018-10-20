//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by @yili@guoyiligo@qq.com on 2016/5/6.
 * Time: 11:53
 */
package QFLib.AI.BaseNode {

    import QFLib.AI.CAIObject;
    import QFLib.Foundation;

    public class CBaseNodeCondition {
        public function CBaseNodeCondition() {

        }

        /**进入节点的条件*/
        public function enterCondition( input : Object ) : Boolean {
//			trace(getName());
            return externalCondition( input );
        }

        /**子类重写，具体条件逻辑*/
        protected function externalCondition( input : Object ) : Boolean {
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

        /**编辑器中元件模板的索引，用于区别*/
        public function setTemplateIndex( index : int ) : void {
            m_index = index;
        }

        public function getTemplateIndex() : int {
            return m_index;
        }

        public function set aiObj( value : CAIObject ) : void {
            _aiObj = value;
        }

        public function setTemplateName( name : String ) : void {
            m_templateName = name;
        }

        public function getTemplateName() : String{
            return m_templateName;
        }

        public function get aiObj() : CAIObject {
            return _aiObj;
        }

        protected var m_Name : String;
        protected var m_templateName : String;
        protected var m_index : int = -1;
        protected var _aiObj : CAIObject = null;
    }
}
