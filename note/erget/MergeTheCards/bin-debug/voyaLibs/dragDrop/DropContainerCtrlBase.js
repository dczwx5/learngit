var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var DragDrop;
    (function (DragDrop) {
        var DropContainerCtrlBase = (function () {
            function DropContainerCtrlBase(container) {
                this._enableDrop = true;
                this._isMoveOver = false;
                this.dg_onDragIn = new VL.Delegate();
                this.dg_onDragOut = new VL.Delegate();
                this.container = container;
            }
            DropContainerCtrlBase.prototype.onDragBegin = function (dragItem) {
                this._targetDragItem = dragItem;
                if (this.enableDrop && this.checkEnableDrop(dragItem)) {
                    this.waitForDrop(dragItem);
                }
            };
            DropContainerCtrlBase.prototype.onDragEnd = function (dragItem) {
                if (!dragItem) {
                    return;
                }
                if (this.isWaitingForDrop && this.isMoveOver) {
                    // this.onDropIn(dragItem as TAR_DRAG_ITEM_CLASS);
                    this.container.dg_onDropIn.boardcast({ container: this.container, dragItem: dragItem });
                }
                this._isMoveOver = false;
                this.cancelWait();
                this._targetDragItem = null;
            };
            DropContainerCtrlBase.prototype.waitForDrop = function (dragItem) {
                if (dragItem && !this.isWaitingForDrop && this.isContainerOf(dragItem)) {
                    this._isWaitingForDrop = true;
                    StageUtils.getStage().addEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                }
            };
            DropContainerCtrlBase.prototype.cancelWait = function () {
                if (this.isWaitingForDrop) {
                    this._isWaitingForDrop = false;
                    StageUtils.getStage().removeEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                }
            };
            DropContainerCtrlBase.prototype.onTouchMove = function (e) {
                // if(!this.isMoveOver && e.target == this.container){
                if (!this.isMoveOver && this.container.checkHover(e.target)) {
                    this.onDragIn();
                    // }else if(this.isMoveOver && e.target != this.container){
                }
                else if (this.isMoveOver && !this.container.checkHover(e.target)) {
                    this.onDragOut();
                }
            };
            DropContainerCtrlBase.prototype.isContainerOf = function (dragItem) {
                return egret.is(dragItem, getClassName(this.tarDragItemClass));
            };
            DropContainerCtrlBase.prototype.onDragIn = function () {
                this._isMoveOver = true;
                this.dg_onDragIn.boardcast(this.container);
            };
            DropContainerCtrlBase.prototype.onDragOut = function () {
                this._isMoveOver = false;
                this.dg_onDragOut.boardcast(this.container);
            };
            Object.defineProperty(DropContainerCtrlBase.prototype, "container", {
                get: function () {
                    return this._container;
                },
                set: function (value) {
                    if (this._container == value) {
                        return;
                    }
                    this._container = value;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DropContainerCtrlBase.prototype, "isMoveOver", {
                get: function () {
                    return this._isMoveOver;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DropContainerCtrlBase.prototype, "isWaitingForDrop", {
                get: function () {
                    return this._isWaitingForDrop && this.enableDrop;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(DropContainerCtrlBase.prototype, "enableDrop", {
                get: function () {
                    return this._enableDrop;
                },
                set: function (value) {
                    if (this._enableDrop == value) {
                        return;
                    }
                    this._enableDrop = value;
                    if (value) {
                        this.waitForDrop(this._targetDragItem);
                    }
                    else {
                        this.cancelWait();
                    }
                },
                enumerable: true,
                configurable: true
            });
            return DropContainerCtrlBase;
        }());
        DragDrop.DropContainerCtrlBase = DropContainerCtrlBase;
        __reflect(DropContainerCtrlBase.prototype, "VL.DragDrop.DropContainerCtrlBase", ["VL.DragDrop.IDropContainerCtrl"]);
    })(DragDrop = VL.DragDrop || (VL.DragDrop = {}));
})(VL || (VL = {}));
//# sourceMappingURL=DropContainerCtrlBase.js.map