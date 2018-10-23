namespace VL{
    export namespace DragDrop{
        export interface IDragItemCtrl{
            /**
             * 是否启用拖拽机制
             */
            enableDrag:boolean;

            dragItem:IDragItem;

            dg_DragBegin:VL.Delegate<IDragItem & egret.DisplayObject>;
            dg_DragEnd:VL.Delegate<IDragItem & egret.DisplayObject>;

            onDropTo(container:IDropContainer);
        }
    }
}