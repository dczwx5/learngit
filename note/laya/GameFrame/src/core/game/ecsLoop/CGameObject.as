package core.game.ecsLoop
{
    import laya.resource.IDispose;
    import core.framework.IDataHolder;
    import laya.events.EventDispatcher;
    import core.game.ecsLoop.IGameComponent;
    import core.game.ecsLoop.ITransform;
    import laya.ani.bone.Transform;

    public class CGameObject extends EventDispatcher implements IDispose, IDataHolder {
        internal static const COMPONENT_CLASS_IDS:Object = {};
        internal static var s_component_class_IDS_count:int = 0;

        protected var m_components:Vector.<IGameComponent>;

        internal var classToComponentMap:Object;
        internal var m_data:Object;
        internal var m_isDataDirty:Boolean;

        internal var m_pTransform:ITransform;
        internal var m_isRunning:Boolean;

        public function CGameObject() {
            super();

            m_isRunning = false;
            m_data = data;
            m_components = new Vector.<IGameComponent>();
            classToComponentMap = {};
        } 

        public function dispose() : void {
            onRemoved();

            m_isRunning = false;
            m_data = null;

            if (m_components) {
                m_components.length = 0;
                m_components = null;
            }

            classToComponentMap = null;

            if (m_pTransform) {
                m_pTransform.dispose();

                m_pTransform = null;
            }
        }

        public function get Transform() : ITransform {
            if (!m_pTransform) {
                m_pTransform = getComponentByClass(ITransform, m_isRunning) as ITransform;
            }

            return m_pTransform;
        }

        internal static function getClassIDByClass(clazz:Class) : int {
            var className:String = clazz["name"];
            var ID:int = COMPONENT_CLASS_IDS[className];
            if (!ID) {
                COMPONENT_CLASS_IDS[className] = ++s_component_class_IDS_count;
                ID = s_component_class_IDS_count;
            }

            return ID;
        }

        public function getComponentByClass(clazz:Class, cache:Boolean = true) : IGameComponent {
            if (!clazz) {
                return null;
            }

            var ID:int = getClassIDByClass(clazz);
            if (ID in classToComponentMap) {
                return classToComponentMap[ID];
            }
            var comp:IGameComponent = findComponentByClass(clazz);
            if (comp && cache) {
                classToComponentMap[ID] = comp;
            }

            return comp;
        }

        public function findComponentByClass(clazz:Class) : IGameComponent {
            if (null == clazz) {
                return null;
            }

            for each (var comp:IGameComponent in m_components) {
                if (comp is clazz) {
                    return comp;
                }
            }
            return null;
        }

        final public function get data() : Object {
            return m_data;
        }
        final public function set data(v:Object) : void {
            if (m_data == v) return ;

            m_data = v;
            m_isDataDirty = true;
        }

        final public function get isRunning() : Boolean {
            return m_isRunning;
        }

        internal function onAdded() : void {

        }
    }
    
}