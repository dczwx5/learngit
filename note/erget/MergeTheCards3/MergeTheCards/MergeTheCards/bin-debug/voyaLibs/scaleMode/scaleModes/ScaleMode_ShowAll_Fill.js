var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ScaleMode;
    (function (ScaleMode) {
        /**
         * 小对象最长边会撑满大对象最短边的SHOW_ALL
         */
        var ScaleMode_ShowAll_Fill = (function () {
            function ScaleMode_ShowAll_Fill() {
            }
            ScaleMode_ShowAll_Fill.prototype.adapt = function (inner, outer) {
                inner.scaleX = inner.scaleY = 1;
                var innerW = inner.width;
                var innerH = inner.height;
                var outerW = outer.width;
                var outerH = outer.height;
                var scale = Math.min(outerW / innerW, outerH / innerH);
                inner.scaleY = inner.scaleX = scale;
            };
            return ScaleMode_ShowAll_Fill;
        }());
        __reflect(ScaleMode_ShowAll_Fill.prototype, "ScaleMode_ShowAll_Fill", ["VL.ScaleMode.IScaleMode"]);
        /**
         * 内容器等比缩放，内容器长边会撑满外容器短边的SHOW_ALL
         */
        ScaleMode.SHOW_ALL_FILL = new ScaleMode_ShowAll_Fill();
    })(ScaleMode = VL.ScaleMode || (VL.ScaleMode = {}));
})(VL || (VL = {}));
//# sourceMappingURL=ScaleMode_ShowAll_Fill.js.map