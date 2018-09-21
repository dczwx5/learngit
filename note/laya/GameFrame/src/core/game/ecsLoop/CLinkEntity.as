package core.game.ecsLoop
{
    import laya.resource.IDispose;

    public class CLinkEntity implements IDispose {
        public var prev:CLinkEntity;
        public var next:CLinkEntity;

        public var obj:*;

        public function dispose() : void {
            next = null;
            prev = null;
            obj = null;
        }

        public function CLinkEntity(obj:* = null) {
            this.obj = obj;
        }

        final public function remove() : void {
            if (next) {
                next.prev = prev;
            }

            if (prev) {
                prev.next = next;
            }
            obj = null;
        }
    }   
}