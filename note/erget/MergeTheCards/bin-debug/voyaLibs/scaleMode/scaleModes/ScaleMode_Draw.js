var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ScaleMode;
    (function (ScaleMode) {
        var ScaleMode_Draw = (function () {
            function ScaleMode_Draw() {
            }
            ScaleMode_Draw.prototype.adapt = function (inner, outer) {
                inner.scaleX = outer.width / inner.width;
                inner.scaleY = outer.height / inner.height;
            };
            return ScaleMode_Draw;
        }());
        __reflect(ScaleMode_Draw.prototype, "ScaleMode_Draw", ["VL.ScaleMode.IScaleMode"]);
        /**
         * 内容器变形缩放，缩放内容器的宽高使其与外容器宽高相匹配
         */
        ScaleMode.DRAW = new ScaleMode_Draw();
    })(ScaleMode = VL.ScaleMode || (VL.ScaleMode = {}));
})(VL || (VL = {}));
//# sourceMappingURL=ScaleMode_Draw.js.map