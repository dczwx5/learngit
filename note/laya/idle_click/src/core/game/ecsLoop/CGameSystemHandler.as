package core.game.ecsLoop
{
    import core.framework.CBean;
    import core.game.ecsLoop.IGameComponent;

    public class CGameSystemHandler extends CBean implements IGameSystemHandler {
        // gameSystemHandler需要GameObject拥有哪些组件
        private var m_supportedComponentClassList:Vector.<Class>;

        private var m_isEnable:Boolean;

        public function CGameSystemHandler(...comps) {
            super();

            m_supportedComponentClassList = new Vector.<Class>();
            for each (var cls:Class in comps) {
                if (cls) {
                    m_supportedComponentClassList.push(cls);
                }
            }

            m_isEnable = true;
        }

        public function isComponentSupported(obj:CGameObject) : Boolean {
            if (!m_supportedComponentClassList || m_supportedComponentClassList.length == 0) {
                return true;
            } else {
                var supported:Boolean = true;
                for each (var clz:Class in m_supportedComponentClassList) {
                    var comp:IGameComponent = obj.getComponentByClass(clz, true);
                    if (!comp) {
                        supported = false;
                        break;
                    }
                }

                return supported;
            }
        }

        final public function get enable() : Boolean {
            return m_isEnable;
        }

        final public function set enable(v:Boolean) : void {
            m_isEnable = v;
            onEnbaled(v);
        }

        protected function onEnbaled(v:Boolean) : void {

        }

        public virtual function beforeTick(delta:Number) : void {

        }
        public virtual function tickValidate(delta:Number, obj:CGameObject) : Boolean {
            return this.enable;
        }

        public virtual function tickUpdate(delta:Number, obj:CGameObject) : void {

        }

        public virtual function afterTick(delta:Number) : void {

        }
    }   
 }