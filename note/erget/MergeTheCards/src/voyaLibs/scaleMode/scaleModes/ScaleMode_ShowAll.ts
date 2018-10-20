namespace VL {
    export namespace ScaleMode {
        /**
         * 小对象最大不会大过原始尺寸的SHOW_ALL
         */
        class ScaleMode_ShowAll implements IScaleMode {

            public adapt(inner: egret.DisplayObject, outer: egret.DisplayObject) {
                inner.scaleX = inner.scaleY = 1;
                let innerW = inner.width;
                let innerH = inner.height;

                let outerW = outer.width;
                let outerH = outer.height;

                let scale = Math.min(1, Math.min(outerW / innerW, outerH / innerH));
                inner.scaleY = inner.scaleX = scale;
            }
        }
        export const SHOW_ALL = new ScaleMode_ShowAll();
    }
}