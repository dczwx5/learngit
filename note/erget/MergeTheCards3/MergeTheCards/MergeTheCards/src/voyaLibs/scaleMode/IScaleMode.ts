namespace VL{
    export namespace ScaleMode{
        export interface IScaleMode{
            /**
             * 根据内外容器对象进行适配
             * @param inner
             * @param outer
             */
            adapt(inner:egret.DisplayObject, outer:egret.DisplayObject);
        }
    }
}