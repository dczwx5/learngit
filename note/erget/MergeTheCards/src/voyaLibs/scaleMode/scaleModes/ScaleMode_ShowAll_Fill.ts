namespace VL {
    export namespace ScaleMode {
        /**
         * 小对象最长边会撑满大对象最短边的SHOW_ALL
         */
        class ScaleMode_ShowAll_Fill implements IScaleMode {

            public adapt(inner: egret.DisplayObject, outer: egret.DisplayObject) {
                inner.scaleX = inner.scaleY = 1;
                let innerW = inner.width;
                let innerH = inner.height;

                let outerW = outer.width;
                let outerH = outer.height;

                let scale = Math.min(outerW / innerW, outerH / innerH);
                inner.scaleY = inner.scaleX = scale;
            }
        }
        /**
         * 内容器等比缩放，内容器长边会撑满外容器短边的SHOW_ALL
         */
        export const SHOW_ALL_FILL = new ScaleMode_ShowAll_Fill();
    }
}