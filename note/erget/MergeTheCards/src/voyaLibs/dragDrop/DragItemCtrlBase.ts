namespace VL{
    export namespace DragDrop{
        export abstract class DragItemCtrlBase implements IDragItemCtrl{
            readonly dg_DragBegin: VL.Delegate<IDragItem & egret.DisplayObject>;
            readonly dg_DragEnd: VL.Delegate<IDragItem & egret.DisplayObject>;

            protected _enableDrag:boolean = false;

            protected _dragItem:IDragItem & egret.DisplayObject;

            protected _isDragging:boolean;

            // protected _origParent:egret.DisplayObjectContainer;
            // protected _origX:number;
            // protected _origY:number;

            protected _offsetX:number;
            protected _offsetY:number;

            constructor(dragItem:IDragItem & egret.DisplayObject){
                this.dg_DragBegin = new VL.Delegate<IDragItem & egret.DisplayObject>();
                this.dg_DragEnd = new VL.Delegate<IDragItem & egret.DisplayObject>();
                this.dragItem = dragItem;
            }

            protected addEvent(){
                this._dragItem.addEventListener(egret.TouchEvent.TOUCH_BEGIN, this.onTouchBegin, this);
            }
            protected removeEvent(){
                this._dragItem.removeEventListener(egret.TouchEvent.TOUCH_BEGIN, this.onTouchBegin, this);
            }

            protected onTouchBegin(e:egret.TouchEvent){
                this.startDrag(e.localX, e.localY, e.stageX, e.stageY);
            }

            protected startDrag(localX:number, localY:number, stageX:number, stageY:number){
                let comp = this._dragItem;
                this.backupBeforeDrag();
                this._offsetX = localX;
                this._offsetY = localY;
                let stage = StageUtils.getStage();
                stage.addChild(comp);
                comp.x = stageX - localX;
                comp.y = stageY - localY;
                comp.touchEnabled = false;
                stage.addEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                stage.addEventListener(egret.TouchEvent.TOUCH_END, this.onTouchCancel, this);
                stage.addEventListener(egret.TouchEvent.TOUCH_CANCEL, this.onTouchCancel, this);
                this._isDragging = true;
                this.dg_DragBegin.boardcast(this.dragItem);
            }

            protected stopDrag(){
                let comp = this._dragItem;
                this._offsetX = null;
                this._offsetY = null;
                let stage = StageUtils.getStage();
                stage.removeEventListener(egret.TouchEvent.TOUCH_MOVE, this.onTouchMove, this);
                stage.removeEventListener(egret.TouchEvent.TOUCH_END, this.onTouchCancel, this);
                stage.removeEventListener(egret.TouchEvent.TOUCH_CANCEL, this.onTouchCancel, this);
                this._isDragging = false;
                comp.touchEnabled = true;
                this.dg_DragEnd.boardcast(this.dragItem);
            }

            protected abstract backupBeforeDrag();
            // protected backupBeforeDrag(){
            //     let comp = this._dragItem;
            //     this._origX = comp.x;
            //     this._origY = comp.y;
            //     this._origParent = comp.parent;
            // }

            protected abstract rollBackBeforDrag();
            // protected rollBackBeforDrag(){
            //     let comp = this._dragItem;
            //     this._origParent.addChild(comp);
            //     comp.x = this._origX;
            //     comp.y = this._origY;
            //     this._origX = null;
            //     this._origY = null;
            //     this._origParent = null;
            // }

            protected onTouchMove(e:egret.TouchEvent){
                let comp = this._dragItem;
                comp.x = e.stageX - this._offsetX;
                comp.y = e.stageY - this._offsetY;
            }

            protected onTouchCancel(e:egret.TouchEvent){
                this.stopDrag();
            }

            onDropTo(container: IDropContainer) {
                container ? this.onDropSecceed(container) : this.onDropFaild();
            }

            protected abstract onDropSecceed(container: IDropContainer);
            protected onDropFaild(){
                this.rollBackBeforDrag();
            }

            get dragItem(): IDragItem & egret.DisplayObject {
                return this._dragItem;
            }

            set dragItem(value: IDragItem & egret.DisplayObject) {
                if(this._dragItem == value){
                    return;
                }
                if(this.isDragging){
                    this.stopDrag();
                }
                this._dragItem = value;
            }

            get isDragging():boolean{
                return this._isDragging;
            }

            public get enableDrag(): boolean {
                return this._enableDrag;
            }

            public set enableDrag(value: boolean) {
                if(this.enableDrag == value){
                    return;
                }
                this.removeEvent();
                this._enableDrag = value;
                if(value){
                    this.addEvent();
                }else{
                    this.stopDrag();
                }
            }
        }
    }
}
