namespace VL {
    export namespace ScaleMode {
        class ScaleMode_NoBorder implements IScaleMode {
            public adapt(inner: egret.DisplayObject, outer: egret.DisplayObject) {
                inner.scaleX = inner.scaleY = 1;
                let innerW = inner.width;
                let innerH = inner.height;

                let outerW = outer.width;
                let outerH = outer.height;

                let scale = Math.max(outerW / innerW, outerH / innerH);

                inner.scaleY = inner.scaleX = scale;
            }
        }
        /**
         * 内容器等比缩放，内容器窄边贴合外容器宽边，会使内容器宽边内容超出
         */
        export const NO_BORDER = new ScaleMode_NoBorder();
    }
}