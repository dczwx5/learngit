abstract class DropCardContainerCtrl extends VL.DragDrop.DropContainerCtrlBase<Card>{

    protected get tarDragItemClass():  new()=>Card  {
        return Card;
    }

    // protected abstract checkEnableDrop(dragItem: Card): boolean
}
