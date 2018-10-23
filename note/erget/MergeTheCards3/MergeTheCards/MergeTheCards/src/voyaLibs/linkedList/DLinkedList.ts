namespace VL {
    export namespace LinkedList {

        class DLNode<T> implements INode<T>, VL.ObjectCache.ICacheable {
            data: T;
            preNode: DLNode<T>;
            nextNode: DLNode<T>;

            clear() {
                this.data
                    = this.preNode
                    = this.nextNode
                    = null;
            }

            init(data: T, preNode: DLNode<T> = null, nextNode: DLNode<T> = null): DLNode<T> {
                this.data = data;
                this.preNode = preNode;
                this.nextNode = nextNode;
                return this;
            }

            restore(maxCacheCount?: number) {
                restore(this);
            }
        }

        export class DLinkedList<T> implements ILinkedList<T> {

            private _head: DLNode<T>;
            private _tail: DLNode<T>;
            private _length: number;

            constructor() {
                this._length = 0;
                this._head = new DLNode<T>();
                this._tail = new DLNode<T>();
                this._head.nextNode = this._tail;
                this._tail.preNode = this._head;
            }

            get first(): VL.LinkedList.INode<T> {
                if (this.isEmpty) {
                    return null;
                }
                return this._head.nextNode;
            }

            get last(): VL.LinkedList.INode<T> {
                if (this.isEmpty) {
                    return null;
                }
                return this._tail.preNode;
            }

            get isEmpty(): boolean {
                return this._length == 0;
            }

            get length(): number {
                return this._length;
            }

            protected checkNode(node: INode<T>): DLNode<T> {
                switch (node) {
                    case this._head:
                        throw new Error(`node 不能是 tail 哑元节点`);
                    case this._tail:
                        throw new Error(`node 不能是 tail 哑元节点`);
                    case null:
                        throw new Error(`node 不能为 null`);
                    default:
                        if (egret.is(node, egret.getQualifiedClassName(DLNode))) {
                            return node as DLNode<T>;
                        } else {
                            throw new Error(`node 不是 VL.LinkedList.DLNode`);
                        }
                }
            }

            addAfter(node: VL.LinkedList.INode<T>, data: T): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let nextNode = dlNode.nextNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, dlNode, nextNode);
                dlNode.nextNode = newNode;
                nextNode.preNode = newNode;
                this._length++;
                return newNode;
            }

            addBefore(node: VL.LinkedList.INode<T>, data: T): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let preNode = dlNode.preNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, preNode, dlNode);
                dlNode.preNode = newNode;
                preNode.nextNode = newNode;
                this._length++;
                return newNode;
            }

            push(data: T): VL.LinkedList.INode<T> {
                let lastNode = this._tail.preNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, lastNode, this._tail);
                this._tail.preNode = newNode;
                lastNode.nextNode = newNode;
                this._length++;
                return newNode;
            }

            unshift(data: T): VL.LinkedList.INode<T> {
                let firstNode = this._head.nextNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, this._head, firstNode);
                this._head.nextNode = newNode;
                firstNode.preNode = newNode;
                this._length++;
                return newNode;
            }

            getNext(node: VL.LinkedList.INode<T>): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.nextNode == this._tail) {
                    return null;
                }
                return dlNode.nextNode;
            }

            getPre(node: VL.LinkedList.INode<T>): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.preNode == this._head) {
                    return null;
                }
                return dlNode.nextNode;
            }

            pop(): T {
                if(this.isEmpty){
                    throw new Error(`链表成员数量为0，不能使用pop`);
                }
                let dlNode = this._tail.preNode;
                let preNode = dlNode.preNode;
                this._tail.preNode = preNode;
                preNode.nextNode = this._tail;
                let data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            }

            remove(node: VL.LinkedList.INode<T>): T {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let preNode = dlNode.preNode;
                let nextNode = dlNode.nextNode;
                preNode.nextNode = nextNode;
                nextNode.preNode = preNode;
                let data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            }

            shift(): T {
                if(this.isEmpty){
                    throw new Error(`链表成员数量为0，不能使用shift`);
                }
                let dlNode = this._head.nextNode;
                let nextNode = dlNode.nextNode;
                this._head.nextNode = nextNode;
                nextNode.preNode = this._head;
                let data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            }

            replace(node: VL.LinkedList.INode<T>, data: T): T {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let oldData = node.data;
                node.data = data;
                return oldData;
            }
        }

        export class CircleList<T> implements ILinkedList<T>{
            private _entry: DLNode<T>;//入口哑元节点
            private _length: number;

            constructor() {
                this._length = 0;
                this._entry = new DLNode<T>();
            }

            get isEmpty(): boolean {
                return this._length == 0;
            }

            get length(): number {
                return this._length;
            }

            protected checkNode(node: INode<T>): DLNode<T> {
                switch (node) {
                    case this._entry:
                        throw new Error(`node 不能是 entry 哑元节点`);
                    case null:
                        throw new Error(`node 不能为 null`);
                    default:
                        if (egret.is(node, egret.getQualifiedClassName(DLNode))) {
                            return node as DLNode<T>;
                        } else {
                            throw new Error(`node 不是 VL.LinkedList.DLNode`);
                        }
                }
            }

            get first(): VL.LinkedList.INode<T> {
                if (this.isEmpty) {
                    return null;
                }
                return this._entry.nextNode;
            }

            get last(): VL.LinkedList.INode<T> {
                if (this.isEmpty) {
                    return null;
                }
                return this._entry.preNode;
            }
            getNext(node: VL.LinkedList.INode<T>): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.nextNode == dlNode) {
                    return null;
                }
                return dlNode.nextNode;
            }

            getPre(node: VL.LinkedList.INode<T>): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.preNode == dlNode) {
                    return null;
                }
                return dlNode.nextNode;
            }


            addAfter(node: VL.LinkedList.INode<T>, data: T): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let nextNode = dlNode.nextNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, dlNode, nextNode);
                dlNode.nextNode = newNode;
                nextNode.preNode = newNode;
                if(this._entry.preNode == dlNode){
                    this._entry.preNode = newNode;
                }
                this._length++;
                return newNode;
            }

            addBefore(node: VL.LinkedList.INode<T>, data: T): VL.LinkedList.INode<T> {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let preNode = dlNode.preNode;
                let newNode = create<DLNode<T>>(DLNode).init(data, preNode, dlNode);
                dlNode.preNode = newNode;
                preNode.nextNode = newNode;
                if(this._entry.nextNode == dlNode){
                    this._entry.nextNode = newNode;
                }
                this._length++;
                return newNode;
            }

            push(data: T): VL.LinkedList.INode<T> {
                let newNode = create<DLNode<T>>(DLNode).init(data);
                if(this.isEmpty){
                    this._entry.preNode = this._entry.nextNode = newNode.preNode = newNode.nextNode = newNode;
                }else{
                    let lastNode = this._entry.preNode;
                    this._entry.preNode = newNode;
                    lastNode.nextNode = newNode;
                    newNode.preNode = lastNode;
                    newNode.nextNode = this.first as DLNode<T>;
                }
                this._length++;
                return newNode;
            }

            unshift(data: T): VL.LinkedList.INode<T> {
                let newNode = create<DLNode<T>>(DLNode).init(data);
                if(this.isEmpty){
                    this._entry.preNode = this._entry.nextNode = newNode.preNode = newNode.nextNode = newNode;
                }else{
                    let firstNode = this._entry.nextNode;
                    this._entry.nextNode = newNode;
                    firstNode.preNode = newNode;
                    newNode.preNode = this.last as DLNode<T>;
                    newNode.nextNode = firstNode;
                }
                this._length++;
                return newNode;
            }


            pop(): T {
                if(this.isEmpty){
                    throw new Error(`链表成员数量为0，不能使用pop`);
                }
                let dlNode = this._entry.preNode;
                let data = dlNode.data;
                if(this.length == 1){
                    this._entry.preNode = this._entry.nextNode = null;
                }else{
                    let preNode = dlNode.preNode;
                    this._entry.preNode = preNode;
                    preNode.nextNode = dlNode.nextNode;
                }
                dlNode.restore();
                this._length--;
                return data;
            }

            remove(node: VL.LinkedList.INode<T>): T {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if(this.length == 1){
                    this._entry.preNode = this._entry.nextNode = null;
                }else{
                    let preNode = dlNode.preNode;
                    let nextNode = dlNode.nextNode;
                    preNode.nextNode = nextNode;
                    nextNode.preNode = preNode;
                }
                let data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            }

            shift(): T {
                if(this.isEmpty){
                    throw new Error(`链表成员数量为0，不能使用shift`);
                }
                let dlNode = this._entry.preNode;
                let data = dlNode.data;
                if(this.length == 1){
                    this._entry.preNode = this._entry.nextNode = null;
                }else{
                    let nextNode = dlNode.nextNode;
                    this._entry.nextNode = nextNode;
                    nextNode.preNode = dlNode.preNode;
                }
                dlNode.restore();
                this._length--;
                return data;

            }

            replace(node: VL.LinkedList.INode<T>, data: T): T {
                let dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                let oldData = node.data;
                node.data = data;
                return oldData;
            }
        }
    }
}
