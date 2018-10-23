namespace VL {
    export namespace LinkedList {
        export interface ILinkedList<T> {
            readonly length:number;
            /**判断链表是否为空*/
            readonly isEmpty:boolean;
            /**返回第一个结点*/
            readonly first:INode<T>;
            /**返回最后一个结点*/
            readonly last:INode<T>;
            /**
             * 返回 node 之后的结点
             * @param {VL.LinkedList.INode<T>} node
             * @returns {VL.LinkedList.INode<T>}
             */
            getNext(node:INode<T>):INode<T>;
            /**
             * 返回 node 之前的结点
             * @param {VL.LinkedList.INode<T>} node
             * @returns {VL.LinkedList.INode<T>}
             */
            getPre(node:INode<T>) :INode<T>;
            /**
             * 将 data 作为第一个元素插入链接表,并返回 data 所在结点
             * @param {T} data
             * @returns {VL.LinkedList.INode<T>}
             */
            unshift(data:T):INode<T>;
            /**
             * 将 data 作为后一个元素插入列表,并返回 data 所在结点
             * @param {T} data
             * @returns {VL.LinkedList.INode<T>}
             */
            push(data:T):INode<T>;
            /**
             * 将 data 插入至 node 之后的位置,并返回 data 所在结点
             * @param {VL.LinkedList.INode<T>} node
             * @param {T} data
             * @returns {VL.LinkedList.INode<T>}
             */
            addAfter(node:INode<T>, data:T):INode<T>;
            /**
             * 将 data 插入至 node 之前的位置,并返回 data 所在结点
             * @param {VL.LinkedList.INode<T>} node
             * @param {T} data
             * @returns {VL.LinkedList.INode<T>}
             */
            addBefore(node:INode<T>, data:T):INode<T>;
            /**
             * 删除给定位置处的元素，并返回之
             * @param {VL.LinkedList.INode<T>} node
             * @returns {T}
             */
            remove(node:INode<T>):T;
            /**
             * 删除首元素，并返回之
             * @returns {T}
             */
            shift():T;
            /**
             * 删除末元素，并返回之
             * @returns {T}
             */
            pop():T;
            /**
             * 将处于给定位置的元素替换为新元素，并返回被替换的元素
             * @param {VL.LinkedList.INode<T>} node
             * @param {T} data
             * @returns {T}
             */
            replace(node:INode<T>, data:T):T;
        }
    }
}
