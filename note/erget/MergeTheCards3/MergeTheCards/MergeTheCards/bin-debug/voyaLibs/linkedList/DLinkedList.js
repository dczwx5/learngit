var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var LinkedList;
    (function (LinkedList) {
        var DLNode = (function () {
            function DLNode() {
            }
            DLNode.prototype.clear = function () {
                this.data
                    = this.preNode
                        = this.nextNode
                            = null;
            };
            DLNode.prototype.init = function (data, preNode, nextNode) {
                if (preNode === void 0) { preNode = null; }
                if (nextNode === void 0) { nextNode = null; }
                this.data = data;
                this.preNode = preNode;
                this.nextNode = nextNode;
                return this;
            };
            DLNode.prototype.restore = function (maxCacheCount) {
                restore(this);
            };
            return DLNode;
        }());
        __reflect(DLNode.prototype, "DLNode", ["VL.LinkedList.INode", "VL.ObjectCache.ICacheable"]);
        var DLinkedList = (function () {
            function DLinkedList() {
                this._length = 0;
                this._head = new DLNode();
                this._tail = new DLNode();
                this._head.nextNode = this._tail;
                this._tail.preNode = this._head;
            }
            Object.defineProperty(DLinkedList.prototype, "first", {
                get: function () {
                    if (this.isEmpty) {
                        return null;
                    }
                    return this._head.nextNode;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DLinkedList.prototype, "last", {
                get: function () {
                    if (this.isEmpty) {
                        return null;
                    }
                    return this._tail.preNode;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DLinkedList.prototype, "isEmpty", {
                get: function () {
                    return this._length == 0;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DLinkedList.prototype, "length", {
                get: function () {
                    return this._length;
                },
                enumerable: true,
                configurable: true
            });
            DLinkedList.prototype.checkNode = function (node) {
                switch (node) {
                    case this._head:
                        throw new Error("node \u4E0D\u80FD\u662F tail \u54D1\u5143\u8282\u70B9");
                    case this._tail:
                        throw new Error("node \u4E0D\u80FD\u662F tail \u54D1\u5143\u8282\u70B9");
                    case null:
                        throw new Error("node \u4E0D\u80FD\u4E3A null");
                    default:
                        if (egret.is(node, egret.getQualifiedClassName(DLNode))) {
                            return node;
                        }
                        else {
                            throw new Error("node \u4E0D\u662F VL.LinkedList.DLNode");
                        }
                }
            };
            DLinkedList.prototype.addAfter = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var nextNode = dlNode.nextNode;
                var newNode = create(DLNode).init(data, dlNode, nextNode);
                dlNode.nextNode = newNode;
                nextNode.preNode = newNode;
                this._length++;
                return newNode;
            };
            DLinkedList.prototype.addBefore = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var preNode = dlNode.preNode;
                var newNode = create(DLNode).init(data, preNode, dlNode);
                dlNode.preNode = newNode;
                preNode.nextNode = newNode;
                this._length++;
                return newNode;
            };
            DLinkedList.prototype.push = function (data) {
                var lastNode = this._tail.preNode;
                var newNode = create(DLNode).init(data, lastNode, this._tail);
                this._tail.preNode = newNode;
                lastNode.nextNode = newNode;
                this._length++;
                return newNode;
            };
            DLinkedList.prototype.unshift = function (data) {
                var firstNode = this._head.nextNode;
                var newNode = create(DLNode).init(data, this._head, firstNode);
                this._head.nextNode = newNode;
                firstNode.preNode = newNode;
                this._length++;
                return newNode;
            };
            DLinkedList.prototype.getNext = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.nextNode == this._tail) {
                    return null;
                }
                return dlNode.nextNode;
            };
            DLinkedList.prototype.getPre = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.preNode == this._head) {
                    return null;
                }
                return dlNode.nextNode;
            };
            DLinkedList.prototype.pop = function () {
                if (this.isEmpty) {
                    throw new Error("\u94FE\u8868\u6210\u5458\u6570\u91CF\u4E3A0\uFF0C\u4E0D\u80FD\u4F7F\u7528pop");
                }
                var dlNode = this._tail.preNode;
                var preNode = dlNode.preNode;
                this._tail.preNode = preNode;
                preNode.nextNode = this._tail;
                var data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            };
            DLinkedList.prototype.remove = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var preNode = dlNode.preNode;
                var nextNode = dlNode.nextNode;
                preNode.nextNode = nextNode;
                nextNode.preNode = preNode;
                var data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            };
            DLinkedList.prototype.shift = function () {
                if (this.isEmpty) {
                    throw new Error("\u94FE\u8868\u6210\u5458\u6570\u91CF\u4E3A0\uFF0C\u4E0D\u80FD\u4F7F\u7528shift");
                }
                var dlNode = this._head.nextNode;
                var nextNode = dlNode.nextNode;
                this._head.nextNode = nextNode;
                nextNode.preNode = this._head;
                var data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            };
            DLinkedList.prototype.replace = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var oldData = node.data;
                node.data = data;
                return oldData;
            };
            return DLinkedList;
        }());
        LinkedList.DLinkedList = DLinkedList;
        __reflect(DLinkedList.prototype, "VL.LinkedList.DLinkedList", ["VL.LinkedList.ILinkedList"]);
        var CircleList = (function () {
            function CircleList() {
                this._length = 0;
                this._entry = new DLNode();
            }
            Object.defineProperty(CircleList.prototype, "isEmpty", {
                get: function () {
                    return this._length == 0;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(CircleList.prototype, "length", {
                get: function () {
                    return this._length;
                },
                enumerable: true,
                configurable: true
            });
            CircleList.prototype.checkNode = function (node) {
                switch (node) {
                    case this._entry:
                        throw new Error("node \u4E0D\u80FD\u662F entry \u54D1\u5143\u8282\u70B9");
                    case null:
                        throw new Error("node \u4E0D\u80FD\u4E3A null");
                    default:
                        if (egret.is(node, egret.getQualifiedClassName(DLNode))) {
                            return node;
                        }
                        else {
                            throw new Error("node \u4E0D\u662F VL.LinkedList.DLNode");
                        }
                }
            };
            Object.defineProperty(CircleList.prototype, "first", {
                get: function () {
                    if (this.isEmpty) {
                        return null;
                    }
                    return this._entry.nextNode;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(CircleList.prototype, "last", {
                get: function () {
                    if (this.isEmpty) {
                        return null;
                    }
                    return this._entry.preNode;
                },
                enumerable: true,
                configurable: true
            });
            CircleList.prototype.getNext = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.nextNode == dlNode) {
                    return null;
                }
                return dlNode.nextNode;
            };
            CircleList.prototype.getPre = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (dlNode.preNode == dlNode) {
                    return null;
                }
                return dlNode.nextNode;
            };
            CircleList.prototype.addAfter = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var nextNode = dlNode.nextNode;
                var newNode = create(DLNode).init(data, dlNode, nextNode);
                dlNode.nextNode = newNode;
                nextNode.preNode = newNode;
                if (this._entry.preNode == dlNode) {
                    this._entry.preNode = newNode;
                }
                this._length++;
                return newNode;
            };
            CircleList.prototype.addBefore = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var preNode = dlNode.preNode;
                var newNode = create(DLNode).init(data, preNode, dlNode);
                dlNode.preNode = newNode;
                preNode.nextNode = newNode;
                if (this._entry.nextNode == dlNode) {
                    this._entry.nextNode = newNode;
                }
                this._length++;
                return newNode;
            };
            CircleList.prototype.push = function (data) {
                var newNode = create(DLNode).init(data);
                if (this.isEmpty) {
                    this._entry.preNode = this._entry.nextNode = newNode.preNode = newNode.nextNode = newNode;
                }
                else {
                    var lastNode = this._entry.preNode;
                    this._entry.preNode = newNode;
                    lastNode.nextNode = newNode;
                    newNode.preNode = lastNode;
                    newNode.nextNode = this.first;
                }
                this._length++;
                return newNode;
            };
            CircleList.prototype.unshift = function (data) {
                var newNode = create(DLNode).init(data);
                if (this.isEmpty) {
                    this._entry.preNode = this._entry.nextNode = newNode.preNode = newNode.nextNode = newNode;
                }
                else {
                    var firstNode = this._entry.nextNode;
                    this._entry.nextNode = newNode;
                    firstNode.preNode = newNode;
                    newNode.preNode = this.last;
                    newNode.nextNode = firstNode;
                }
                this._length++;
                return newNode;
            };
            CircleList.prototype.pop = function () {
                if (this.isEmpty) {
                    throw new Error("\u94FE\u8868\u6210\u5458\u6570\u91CF\u4E3A0\uFF0C\u4E0D\u80FD\u4F7F\u7528pop");
                }
                var dlNode = this._entry.preNode;
                var data = dlNode.data;
                if (this.length == 1) {
                    this._entry.preNode = this._entry.nextNode = null;
                }
                else {
                    var preNode = dlNode.preNode;
                    this._entry.preNode = preNode;
                    preNode.nextNode = dlNode.nextNode;
                }
                dlNode.restore();
                this._length--;
                return data;
            };
            CircleList.prototype.remove = function (node) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                if (this.length == 1) {
                    this._entry.preNode = this._entry.nextNode = null;
                }
                else {
                    var preNode = dlNode.preNode;
                    var nextNode = dlNode.nextNode;
                    preNode.nextNode = nextNode;
                    nextNode.preNode = preNode;
                }
                var data = dlNode.data;
                dlNode.restore();
                this._length--;
                return data;
            };
            CircleList.prototype.shift = function () {
                if (this.isEmpty) {
                    throw new Error("\u94FE\u8868\u6210\u5458\u6570\u91CF\u4E3A0\uFF0C\u4E0D\u80FD\u4F7F\u7528shift");
                }
                var dlNode = this._entry.preNode;
                var data = dlNode.data;
                if (this.length == 1) {
                    this._entry.preNode = this._entry.nextNode = null;
                }
                else {
                    var nextNode = dlNode.nextNode;
                    this._entry.nextNode = nextNode;
                    nextNode.preNode = dlNode.preNode;
                }
                dlNode.restore();
                this._length--;
                return data;
            };
            CircleList.prototype.replace = function (node, data) {
                var dlNode = this.checkNode(node);
                if (!dlNode) {
                    return null;
                }
                var oldData = node.data;
                node.data = data;
                return oldData;
            };
            return CircleList;
        }());
        LinkedList.CircleList = CircleList;
        __reflect(CircleList.prototype, "VL.LinkedList.CircleList", ["VL.LinkedList.ILinkedList"]);
    })(LinkedList = VL.LinkedList || (VL.LinkedList = {}));
})(VL || (VL = {}));
//# sourceMappingURL=DLinkedList.js.map