package core.game.ecsLoop
{
import laya.resource.IDispose;
import core.framework.IDataHolder;
import laya.events.EventDispatcher;
import core.game.ecsLoop.IGameComponent;
import core.game.ecsLoop.ITransform;
import laya.ani.bone.Transform;
import core.game.ecsLoop.CGameComponent;

public class CGameObject extends EventDispatcher implements IDispose, IDataHolder {
    internal static const COMPONENT_CLASS_IDS:Object = {}; // 缓存所有组件ＩＤ：CLASS
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

    public function get transform() : ITransform {
        if (!m_pTransform) {
            m_pTransform = getComponentByClass(ITransform, m_isRunning) as ITransform;
        }

        return m_pTransform;
    }

    // ======================================================================
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

    // ====================================

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
        m_isRunning = true;
        if (m_components && m_components.length) {
            for each (var comp:IGameComponent in m_components) {
                if (comp is CGameComponent) {
                    (comp as CGameComponent).setEnter();
                }
            }
        }
    }

    final internal function onRemoved() : void {
        m_isRunning = false;
        
        var reversed:Vector.<IGameComponent> = m_components.slice().reverse();

        if (reversed && reversed.length) {
            for each (var comp:IGameComponent in reversed) {
                if (comp is CGameComponent) {
                    (comp as CGameComponent).setExit();
                }
            }
        }
    }

    // =================================
    final public function get components() : Vector.<IGameComponent> {
        return m_components;
    }

    final public function addComponents(...comps) : Vector.<IGameComponent> {
        const ret:Vector.<IGameComponent> = new Vector.<IGameComponent>();
        for each (var c:* in comps) {
            if (c is IGameComponent) {
                addComponent(c as IGameComponent);
                ret.push(c);
            }
        }
        return ret;
    }

    final public function addComponent(comp:IGameComponent) : void {
        if (!comp) {
            return ;
        }

        m_components.push(comp);
        if (comp is IGameComponent) {
            (comp as CGameComponent).setOwner(this);
        }
    }

    final public function removeComponents(dispose:Boolean, ...comps) : Vector.<IGameComponent> {
        const ret:Vector.<IGameComponent> = new Vecotr.<IGameComponent>();
        for each (var c:* in comps) {
            if (c is IGameComponent) {
                if (removeComponent(c as IGameComponent, dispose));
                ret.push(c);
            }
        }

        return ret;
    }

    final public function removeComponent(comp:IGameComponent, dispose:Boolean) : Boolean {
        const index:int = m_components.indexOf(comp);
        if (-1 != index) {
            m_components.splice(index, 1);
            if (comp is CGameComponent) {
                (comp as CGameComponent).setOwner(null);
            }

            if (dispose) {
                comp.dispose();
            }

            if (comp == m_pTransform) {
                m_pTransform = null;
            }

            for (var keyClassID:int in classToComponentMap) {
                if (classToComponentMap[keyClassID] == comp) {
                    delete classToComponentMap[keyClassID];
                    break;
                }
            }
            return true;
        }

        return false;
    }

    // final public function findComponent(comp:IGameComponent) : IGameComponent {
    //     if (!comp) {
    //         return null;
    //     }

    //     const index:int = m_components.indexOf(comp);
    //     if (-1 != index) {
    //         return m_components[index] as IGameComponent;
    //     }
    //     return null;
    // }

    final public function removeAllComponents(dispose:Boolean) : void {
        var reversed:Vector.<IGameComponent> = m_components.slice().reverse();
        var comp:IGameComponent;
        for each (comp in reversed) {
            removeComponent(comp, false);
        }

        if (dispose) {
            for each (comp in reversed) {
                comp.dispose();
            }
        }

        reversed.slice(0, reversed.length);

        for (var keyClassID:int in classToComponentMap) {
            delete classToComponentMap[keyClassID];
        }
    }

    final public function invalidateData() : void {
        m_isDataDirty = true;
    }

    final internal function updateData() : void {
        if (m_isDataDirty) {
            m_isDataDirty = false;

            if (m_components && m_components.length) {
                for each (var comp:IGameComponent in m_components) {
                    if (comp is CGameComponent) {
                        (comp as CGameComponent).setDataUpdated();
                    }
                }
            }
        }
    }

}
    
}