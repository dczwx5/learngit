interface PopupWindowData {
    content: string;
    showClose:boolean;
    title?: string;
    onClose?:()=>void;
    // onOk?:()=>void;
}
