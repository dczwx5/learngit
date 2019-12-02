
class CLinkList {

    head:CLinkNode;
    tail:CLinkNode;

    private m_pCurNode:CLinkNode;
    public m_nSize:number;

    constructor() {

        this.head = new CLinkNode();
        this.tail = new CLinkNode();

        this.head.next = this.tail;
        this.tail.prev = this.head;

        this.m_pCurNode = this.head;
        
    }
    dispose() : void {
        this.head.next = null;
        this.head.prev = null;
        this.head = null;

        this.tail.next = null;
        this.tail.prev = null;
        this.tail = null;

        this.m_pCurNode.next = null;
        this.m_pCurNode.prev = null;
        this.m_pCurNode = null;

    }


    get size() : number {
        return this.m_nSize;
    }

     push(obj:any) : void {
        const prev:CLinkNode = this.tail.prev;
        const current:CLinkNode = new CLinkNode(obj);
        current.next = this.tail;
        current.prev = prev;

        prev.next = current;
        this.tail.prev = current;

        this.m_nSize++;
    }

    find(obj:any) : CLinkNode {
        const head:CLinkNode = this.head;
        let node:CLinkNode = this.tail.prev;
        while (true) {
            if (!node || node == head) {
                break;
            }
            if (node.obj == obj) {
                return node;
            }

            node = node.prev;
        }
        
        return null;
    }
    // remove(obj:any) {

    // }
}

class CLinkNode {

    prev:CLinkNode;
    next:CLinkNode;
    obj:any;

    constructor(obj:any = null) {
        this.obj = obj;
    }

    remove() : void {
        if (this.next) {
            this.next.prev = this.prev;
        }

        if ( this.prev ) {
            this.prev.next = this.next;
        }

        this.obj = null;
    }

}