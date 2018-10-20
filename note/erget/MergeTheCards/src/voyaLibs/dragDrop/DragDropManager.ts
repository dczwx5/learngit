namespace VL {
    export namespace DragDrop {
        export class DragDropManager {

            private _containerList: IDropContainer[];

            private _currDragItem: IDragItem;

            private _currContainer: IDropContainer;

            constructor() {
                this._containerList = [];
            }

            public regDragItem(dragItem: IDragItem) {
                dragItem.dragItemCtrl.dg_DragBegin.register(this.onDragBegin, this);
                dragItem.dragItemCtrl.dg_DragEnd.register(this.onDragEnd, this);
                dragItem.dragItemCtrl.enableDrag = true;
            }

            public unregDragItem(dragItem: IDragItem) {
                dragItem.dragItemCtrl.dg_DragBegin.unregister(this.onDragBegin);
                dragItem.dragItemCtrl.dg_DragEnd.unregister(this.onDragEnd);
                dragItem.dragItemCtrl.enableDrag = false;
            }

            public regDropContainer(dropContainer: IDropContainer) {
                if (this._containerList.indexOf(dropContainer) < 0) {
                    this._containerList.push(dropContainer);
                    dropContainer.dropContainerCtrl.dg_onDragIn.register(this.onDragIn, this);
                    dropContainer.dropContainerCtrl.dg_onDragOut.register(this.onDragOut, this);
                    dropContainer.dropContainerCtrl.enableDrop = true;
                    if(this._currDragItem){
                        dropContainer.dropContainerCtrl.onDragBegin(this._currDragItem);
                    }
                }
            }

            public unregDropContainer(dropContainer: IDropContainer) {
                let idx = this._containerList.indexOf(dropContainer);
                if (idx >= 0) {
                    this._containerList.splice(idx, 1);
                    dropContainer.dropContainerCtrl.dg_onDragIn.unregister(this.onDragIn);
                    dropContainer.dropContainerCtrl.dg_onDragOut.unregister(this.onDragOut);

                    dropContainer.dropContainerCtrl.enableDrop = false;
                    dropContainer.dropContainerCtrl.onDragEnd(this._currDragItem);
                }
            }

            private onDragBegin(dragItem: IDragItem) {
                this._currDragItem = dragItem;
                for (let i = 0, l = this._containerList.length; i < l; i++) {
                    this._containerList[i].dropContainerCtrl.onDragBegin(dragItem);
                }
            }

            private onDragEnd(dragItem: IDragItem) {
                for (let i = 0; i < this._containerList.length; i++) {
                    this._containerList[i].dropContainerCtrl.onDragEnd(dragItem);
                }
                dragItem.dragItemCtrl.onDropTo(this._currContainer);
                this._currDragItem = null;
                this._currContainer = null;
            }

            private onDragIn(container: IDropContainer) {
                this._currContainer = container;
            }

            private onDragOut(container: IDropContainer) {
                if (this._currContainer == container) {
                    this._currContainer = null;
                }
            }

        }
    }
}