var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var DragDrop;
    (function (DragDrop) {
        var DragDropManager = (function () {
            function DragDropManager() {
                this._containerList = [];
            }
            DragDropManager.prototype.regDragItem = function (dragItem) {
                dragItem.dragItemCtrl.dg_DragBegin.register(this.onDragBegin, this);
                dragItem.dragItemCtrl.dg_DragEnd.register(this.onDragEnd, this);
                dragItem.dragItemCtrl.enableDrag = true;
            };
            DragDropManager.prototype.unregDragItem = function (dragItem) {
                dragItem.dragItemCtrl.dg_DragBegin.unregister(this.onDragBegin);
                dragItem.dragItemCtrl.dg_DragEnd.unregister(this.onDragEnd);
                dragItem.dragItemCtrl.enableDrag = false;
            };
            DragDropManager.prototype.regDropContainer = function (dropContainer) {
                if (this._containerList.indexOf(dropContainer) < 0) {
                    this._containerList.push(dropContainer);
                    dropContainer.dropContainerCtrl.dg_onDragIn.register(this.onDragIn, this);
                    dropContainer.dropContainerCtrl.dg_onDragOut.register(this.onDragOut, this);
                    dropContainer.dropContainerCtrl.enableDrop = true;
                    if (this._currDragItem) {
                        dropContainer.dropContainerCtrl.onDragBegin(this._currDragItem);
                    }
                }
            };
            DragDropManager.prototype.unregDropContainer = function (dropContainer) {
                var idx = this._containerList.indexOf(dropContainer);
                if (idx >= 0) {
                    this._containerList.splice(idx, 1);
                    dropContainer.dropContainerCtrl.dg_onDragIn.unregister(this.onDragIn);
                    dropContainer.dropContainerCtrl.dg_onDragOut.unregister(this.onDragOut);
                    dropContainer.dropContainerCtrl.enableDrop = false;
                    dropContainer.dropContainerCtrl.onDragEnd(this._currDragItem);
                }
            };
            DragDropManager.prototype.onDragBegin = function (dragItem) {
                this._currDragItem = dragItem;
                for (var i = 0, l = this._containerList.length; i < l; i++) {
                    this._containerList[i].dropContainerCtrl.onDragBegin(dragItem);
                }
            };
            DragDropManager.prototype.onDragEnd = function (dragItem) {
                for (var i = 0; i < this._containerList.length; i++) {
                    this._containerList[i].dropContainerCtrl.onDragEnd(dragItem);
                }
                dragItem.dragItemCtrl.onDropTo(this._currContainer);
                this._currDragItem = null;
                this._currContainer = null;
            };
            DragDropManager.prototype.onDragIn = function (container) {
                this._currContainer = container;
            };
            DragDropManager.prototype.onDragOut = function (container) {
                if (this._currContainer == container) {
                    this._currContainer = null;
                }
            };
            return DragDropManager;
        }());
        DragDrop.DragDropManager = DragDropManager;
        __reflect(DragDropManager.prototype, "VL.DragDrop.DragDropManager");
    })(DragDrop = VL.DragDrop || (VL.DragDrop = {}));
})(VL || (VL = {}));
//# sourceMappingURL=DragDropManager.js.map