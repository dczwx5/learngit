class DragCardCtrl extends VL.DragDrop.DragItemCtrlBase{

    private origParent:egret.DisplayObjectContainer;
    private origX:number;
    private origY:number;

    protected onDropSecceed(container: VL.DragDrop.IDropContainer) {
    }


    protected startDrag(localX: number, localY: number, stageX: number, stageY: number) {
        super.startDrag(localX, localY, stageX, stageY);
        this.card.alpha = 0.5;
    }

    protected stopDrag() {
        super.stopDrag();
        this.card.alpha = 1;
    }

    protected backupBeforeDrag() {
        this.origParent = this.dragItem.parent;
        this.origX = this.dragItem.x;
        this.origY = this.dragItem.y;
    }

    protected rollBackBeforDrag() {
        this.dragItem.x = this.origX;
        this.dragItem.y = this.origY;
        this.origParent.addChild(this.dragItem);
    }

    private get card(){
        return this.dragItem as Card;
    }
}

