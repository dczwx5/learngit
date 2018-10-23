var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ScaleMode;
    (function (ScaleMode) {
        var ScaleMode_NoBorder = (function () {
            function ScaleMode_NoBorder() {
            }
            ScaleMode_NoBorder.prototype.adapt = function (inner, outer) {
                inner.scaleX = inner.scaleY = 1;
                var innerW = inner.width;
                var innerH = inner.height;
                var outerW = outer.width;
                var outerH = outer.height;
                var scale = Math.max(outerW / innerW, outerH / innerH);
                inner.scaleY = inner.scaleX = scale;
            };
            return ScaleMode_NoBorder;
        }());
        __reflect(ScaleMode_NoBorder.prototype, "ScaleMode_NoBorder", ["VL.ScaleMode.IScaleMode"]);
        /**
         * 内容器等比缩放，内容器窄边贴合外容器宽边，会使内容器宽边内容超出
         */
        ScaleMode.NO_BORDER = new ScaleMode_NoBorder();
    })(ScaleMode = VL.ScaleMode || (VL.ScaleMode = {}));
})(VL || (VL = {}));
//# sourceMappingURL=ScaleMode_NoBorder.js.map