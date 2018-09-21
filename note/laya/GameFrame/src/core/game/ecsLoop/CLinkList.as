package core.game.ecsLoop
{
    import laya.resource.IDispose;

    public class CLinkList implements IDispose {
        public var head:CLinkEntity;
        public var tail:CLinkEntity;

        private var m_pCurEntity:CLinkEntity;

        private var m_size:uint;

        private var m_mapObjToEntity:Object;

        public function CLinkList() {
            super();

            head = new CLinkEntity();
            tail = new CLinkEntity();

            head.next = tail;
            tail.prev = head;

            m_pCurEntity = head;
        }
        
        public function dispose() : void {
            head.dispose();
            head = null;

            tail.dispose();
            tail = null;

            m_pCurEntity.dispose();
            m_pCurEntity = null;

        }

        final public function get size() : uint {
            return m_size;
        }

        final public function push(obj:CGameObject) : void {
            const prev:CLinkEntity = tail.prev;
            const current:CLinkEntity = new CLinkEntity(obj);
            current.next = tail;
            current.prev = prev;

            prev.next = current;
            tail.prev = current;

            m_size++;
        }

        final public function find(obj:CGameObject) : CLinkEntity {
            var entity:CLinkEntity;
            entity = head;

            var findEntity:CLinkEntity;
            while (entity) {
                if (entity.obj == obj) {
                    findEntity = entity;
                    break;
                }

                entity = entity.next;
            }

            return findEntity;
        }

    }   
} 