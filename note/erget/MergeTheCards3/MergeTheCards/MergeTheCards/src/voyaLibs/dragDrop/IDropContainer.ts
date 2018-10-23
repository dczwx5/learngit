namespace VL {
    export namespace DragDrop {
        export interface IDropContainer {
            dg_onDropIn: VL.Delegate<{ dragItem: IDragItem, container: IDropContainer }>
            dropContainerCtrl: IDropContainerCtrl;
            checkHover(touchTarget: egret.DisplayObject): boolean;
        }
    }
}
