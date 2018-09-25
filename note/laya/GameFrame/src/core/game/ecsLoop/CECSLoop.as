package core.game.ecsLoop
{
    import core.game.ecsLoop.IPipeline;
    import laya.resource.IDispose;
    import core.framework.CAppSystem;
    import core.framework.IUpdate;
    import core.game.ecsLoop.CLinkList;
    import core.game.ecsLoop.IGameSystemHandler;
    import core.game.ecsLoop.CGameObject;
    import core.game.ecsLoop.CLinkEntity;

    public class CECSLoop extends CAppSystem implements IUpdate {
        private var m_pPipeline:CGameSystemPipeline;
        private var m_isInitialized:Boolean;
        private var m_objLink:CLinkList;

        public function CECSLoop() {
            super();
        }

        override protected function onDestroy() : void {
            super.onDestroy();
        
            if (m_pPipeline) {
                m_pPipeline.dispose();
            }
            m_pPipeline = null;

            if (m_objLink) {
                m_objLink.dispose();
            }
            m_objLink = null;
        }

        override protected function onAwake() : void {
            super.onAwake();

            if (!m_isInitialized) {
                m_isInitialized = true;

                m_pPipeline = new CGameSystemPipeline(this);
                m_objLink = new CLinkList();
            }
        }

        public function addHandler(handler:IGameSystemHandler) : void {
            m_pPipeline.add(handler);
        }
        public function removeHandler(handler:IGameSystemHandler) : void {
            m_pPipeline.remove(handler);
        }
        public function removeAllHandler() : void {
            var handlers:Vector.<IGameSystemHandler> = m_pPipeline.handlers.slice();
            for each (var handler:IGameSystemHandler in handlers) {
                if (handler) {
                    m_pPipeline.remove(handler);
                }
            }
        }

        public function addObject(obj:CGameObject) : void {
            if (!obj) {
                return ;
            }

            m_objLink.push(obj);
            obj.onAdded();
        }

        public function removeObject(obj:CGameObject) : void {
            if (!obj) {
                return ;
            }
            m_objLink.remove(obj);
            obj.onRemoved();
        }

        public function update(delta:Number) : void {
            if (m_isInitialized == false) {
                return ;
            }

            m_pPipeline.beforeTick(delta);

            var current:CLinkEntity = this.m_objLink.head;
            var curGameObj:CGameObject;

            for (; current != m_objLink.tail; ) {
                curGameObj = current.obj as CGameObject;
                if (curGameObj) {
                    curGameObj.updateData();

                    m_pPipeline.tickUpdate(delta, current.obj as CGameObject);
                }

                current = current.next;
            }

            m_pPipeline.afterTick(delta);
        }


    }
    
}

import core.game.ecsLoop.IPipeline;
import laya.resource.IDispose;
import core.game.ecsLoop.CECSLoop;
import core.game.ecsLoop.IGameSystemHandler;
import core.game.ecsLoop.CGameObject;

class CGameSystemPipeline implements IPipeline, IDispose {
    private var m_pGameSystem:CECSLoop;
    private var m_handlerList:Vector.<IGameSystemHandler>;
    private var m_updateHandlerList:Vector.<IGameSystemHandler>;


    function CGameSystemPipeline(gameSystem:CECSLoop) {
        super();
        m_pGameSystem = gameSystem;
        m_handlerList = new Vector.<IGameSystemHandler>();
        m_updateHandlerList = new Vector.<IGameSystemHandler>();
    }

    final public function get handlers() : Vector.<IGameSystemHandler> {
        return m_handlerList.slice();
    }

    final public function add(handler:IGameSystemHandler) : void {
        m_handlerList.push(handler);
    }

    final public function remove(handler:IGameSystemHandler) : void {
        const index:int = m_handlerList.indexOf(handler);
        if (-1 != index) {
            m_handlerList.splice(index, 1);
        }
    }

    final public function dispose() : void {
        m_pGameSystem = null;
    }

    public function tickUpdate(delta:Number, obj:CGameObject) : void {
        if (!obj) {
            return ;
        }

        const listUpdated:Vector.<IGameSystemHandler> = m_updateHandlerList;

        if (m_handlerList.length > m_updateHandlerList.length) {
            m_updateHandlerList.length = m_handlerList.length;
        }

        var handler:IGameSystemHandler;
        var idxPush:int = 0;

        for each (handler in m_handlerList) {
            if (handler && handler.isComponentSupported(obj)) {
                if (handler.tickValidate(delta, obj)) {
                    listUpdated[idxPush++] = handler;
                }
            }
        }

        if (obj.isRunning) {
            for (var i:int = 0; i < idxPush; ++i) {
                listUpdated[i].tickUpdate(delta, obj);
            }
        }
    }

    final public function beforeTick(delta:Number) : void {
        var handler:IGameSystemHandler;
        for each (handler in m_handlerList) {
            handler.beforeTick(delta);
        }
    }

    final public function afterTick(delta:Number) : void {
        var handler:IGameSystemHandler;
        for each (handler in m_handlerList) {
            handler.afterTick(delta);
        }
    }
}