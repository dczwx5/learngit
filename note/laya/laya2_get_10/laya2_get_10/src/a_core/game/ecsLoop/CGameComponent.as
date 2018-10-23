package a_core.game.ecsLoop
{
    import a_core.CObjectUtils;
    import a_core.CCommon;
    import laya.events.EventDispatcher;

    public class CGameComponent extends EventDispatcher implements IGameComponent {

        public static const STATE_CREATED:int = 0;
        public static const STATE_ENTERED:int = 1;
        public static const STATE_EXITED:int = 2;

        private var m_pOwner:CGameObject;
        private var m_pData:Object;
        private var m_name:String;
        private var m_isBranchData:Boolean;
        private var m_enable:Boolean;

        private var m_runningState:int;

        public function CGameComponent(name:String = null, branchData:Boolean = false) {
            super();

            m_name = name;
            if (null == name) {
                m_name = CCommon.getQualifiedClassName(this);
            }

            m_isBranchData = branchData;
            m_enable = true;
            m_runningState = STATE_CREATED;

        }

        public function get Name() : String {
            return m_name;
        }

        public function set Name(v:String) : void {
            m_name =v;
        }

        public function get owner() : CGameObject {
            return m_pOwner;
        }

        public function get enable() : Boolean {
            return m_enable;
        }
        public function set enable(v:Boolean) : void {
            m_enable = v;

            onEnable(v);
        }
        protected function onEnable(v:Boolean) : void {

        }

        public function get runningState() : int {
            return m_runningState;
        }
        internal function setOwner(v:CGameObject) : void {
            if (m_pOwner == v) {
                return ;
            }

            if (v) {
                m_pData = null;
                m_pOwner = v;
                if (m_pOwner.isRunning) {
                    setEnter();
                }
            } else {
                if (m_pOwner && m_pOwner.isRunning) {
                    setExit();
                }

                m_pOwner = null;
                m_pData = null;
            }
            
        }

        public function get transform() : ITransform {
            return owner.transform;
        }

        final internal function setEnter() : void {
            if (this.runningState != STATE_ENTERED) {
                if (m_pOwner.data) {
                    if (m_isBranchData) {
                        var temp:Object = {};
                        temp[Name] = {};
                        CObjectUtils.extend(true, m_pOwner.data, temp);
                        m_pData = m_pOwner.data[Name];
                    }
                }

                m_enable = true;
                onEnter();
                m_runningState = STATE_ENTERED;
            }
        }

        final internal function setExit() : void {
            if (runningState == STATE_ENTERED) {
                onExit();
                m_enable = false;
                m_runningState = STATE_EXITED;
            }
        }

        final internal function setDataUpdated() : void {
            onDataUpdated();
        }

        protected virtual function onEnter() : void {
            
        }
        protected virtual function onDataUpdated() : void {
            
        }
        protected virtual function onExit() : void {
            
        }
    
        public function get data() : Object {
            return m_pData;
        }

        protected function extendData(data:Object) : void {
            if (m_pData && data) {
                CObjectUtils.extend(true, m_pData, data);
            }
        }
 
        public function getComponent(clazz:Class, cache:Boolean = true) : IGameComponent {
            if (owner) {
                return owner.getComponentByClass(clazz, cache);
            }
            return null;
        }

        public function dispose() : void {
            m_runningState = STATE_CREATED;
            m_pOwner = null;
            m_pData = null;
        }
    }   
 }