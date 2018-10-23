namespace VL {
    export namespace ScaleMode {
        class ScaleMode_Draw implements IScaleMode {

            public adapt(inner: egret.DisplayObject, outer: egret.DisplayObject) {
                inner.scaleX = outer.width / inner.width;
                inner.scaleY = outer.height / inner.height;
            }
        }
        /**
         * 内容器变形缩放，缩放内容器的宽高使其与外容器宽高相匹配
         */
        export const DRAW: ScaleMode_Draw = new ScaleMode_Draw();
    }
}