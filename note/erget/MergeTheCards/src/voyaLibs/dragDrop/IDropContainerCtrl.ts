namespace VL{
    export namespace DragDrop{
        export interface IDropContainerCtrl{

            container:IDropContainer;

            dg_onDragIn:VL.Delegate<IDropContainer>;
            dg_onDragOut:VL.Delegate<IDropContainer>;

            onDragBegin(dragItem:IDragItem);
            onDragEnd(dragItem: IDragItem);

            enableDrop:boolean;
            isContainerOf(dragItem: IDragItem):boolean;

        }
    }
}