var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ScaleMode;
    (function (ScaleMode) {
        /**
         * 小对象最大不会大过原始尺寸的SHOW_ALL
         */
        var ScaleMode_ShowAll = (function () {
            function ScaleMode_ShowAll() {
            }
            ScaleMode_ShowAll.prototype.adapt = function (inner, outer) {
                inner.scaleX = inner.scaleY = 1;
                var innerW = inner.width;
                var innerH = inner.height;
                var outerW = outer.width;
                var outerH = outer.height;
                var scale = Math.min(1, Math.min(outerW / innerW, outerH / innerH));
                inner.scaleY = inner.scaleX = scale;
            };
            return ScaleMode_ShowAll;
        }());
        __reflect(ScaleMode_ShowAll.prototype, "ScaleMode_ShowAll", ["VL.ScaleMode.IScaleMode"]);
        ScaleMode.SHOW_ALL = new ScaleMode_ShowAll();
    })(ScaleMode = VL.ScaleMode || (VL.ScaleMode = {}));
})(VL || (VL = {}));
//# sourceMappingURL=ScaleMode_ShowAll.js.map