namespace VL {
    export namespace DragDrop {
        export abstract class DropContainerCtrlBase<TAR_DRAG_ITEM_CLASS extends IDragItem> implements IDropContainerCtrl {

            readonly dg_onDragIn: VL.Delegate<IDropContainer>;
            readonly dg_onDragOut: VL.Delegate<IDropContainer>;

            private _enableDrop: boolean = true;

            protected _container: IDropContainer;

            /**正在拖动的的IDragItem*/
            protected _targetDragItem: IDragItem;

            /**是否符合放入条件并正在等待被放入*/
            protected _isWaitingForDrop: boolean;

            private _isMoveOver: boolean = false;

            constructor(container: IDropContainer) {
                this.dg_onDragIn = new VL.Delegate<IDropContainer>();
                this.dg_onDragOut = new VL.Delegate<IDropContainer>();
                this.container = container;
            }

            onDragBegin(dragItem: IDragItem) {
                this._targetDragItem = dragItem;
                if (this.enableDrop && this.checkEnableDrop(dragItem)) {
                    this.waitForDrop(dragItem);
                }
            }

            onDragEnd(dragItem: IDragItem) {
                if (!dragItem) {
                    return;
                }
                if (this.isWaitingForDrop && this.isMoveOver) {
                    // this.onDropIn(dragItem as TAR_DRAG_ITEM_CLASS);
                    this.container.dg_onDropIn.boardcast({container:this.container, dragItem:dragItem});
                }
                this._isMoveOver = false;
                this.cancelWait();
                this._targetDragItem = null;
            }

            protected waitForDrop(dragItem: IDragItem) {
                if (dragItem && !this.isWaitingForDrop && this.isContainerOf(dragItem)) {
                    this._isWaitingForDrop = true;
                    StageUtils.getStage().addEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                }
            }

            protected cancelWait() {
                if (this.isWaitingForDrop) {
                    this._isWaitingForDrop = false;
                    StageUtils.getStage().removeEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                }
            }

            protected onTouchMove(e: egret.TouchEvent) {
                // if(!this.isMoveOver && e.target == this.container){
                if (!this.isMoveOver && this.container.checkHover(e.target)) {
                    this.onDragIn();
                    // }else if(this.isMoveOver && e.target != this.container){
                } else if (this.isMoveOver && !this.container.checkHover(e.target)) {
                    this.onDragOut();
                }
            }

            public isContainerOf(dragItem: IDragItem): boolean {
                return egret.is(dragItem, getClassName(this.tarDragItemClass));
            }

            protected onDragIn() {
                this._isMoveOver = true;
                this.dg_onDragIn.boardcast(this.container);
            }

            protected onDragOut() {
                this._isMoveOver = false;
                this.dg_onDragOut.boardcast(this.container);
            }


            get container(): IDropContainer {
                return this._container;
            }

            set container(value: IDropContainer) {
                if (this._container == value) {
                    return;
                }
                this._container = value;
            }

            get isMoveOver(): boolean {
                return this._isMoveOver;
            }

            get isWaitingForDrop(): boolean {
                return this._isWaitingForDrop && this.enableDrop;
            }

            get enableDrop(): boolean {
                return this._enableDrop;
            }

            set enableDrop(value: boolean) {
                if (this._enableDrop == value) {
                    return;
                }
                this._enableDrop = value;
                if (value) {
                    this.waitForDrop(this._targetDragItem);
                } else {
                    this.cancelWait();
                }
            }

            protected abstract get tarDragItemClass(): new() => TAR_DRAG_ITEM_CLASS;

            /**
             * 检测拖动的对象是否可放入容器
             * @param dragItem
             */
            protected abstract checkEnableDrop(dragItem:IDragItem):boolean;
        }
    }
}
