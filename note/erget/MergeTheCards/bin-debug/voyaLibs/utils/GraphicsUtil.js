var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    var GraphicsUtil = (function () {
        function GraphicsUtil() {
        }
        /**
         * 画扇形 3点钟方向为0度
         * @param graphics 画布
         * @param r
         * @param startFrom
         * @param angle
         * @param originX 圆心X
         * @param originY 圆心Y
         * @param color
         * @param alpha
         * @returns {egret.Shape}
         */
        GraphicsUtil.drawSector = function (graphics, r, startFrom, angle, originX, originY, color, alpha) {
            if (r === void 0) { r = 100; }
            if (startFrom === void 0) { startFrom = 0; }
            if (angle === void 0) { angle = 360; }
            if (originX === void 0) { originX = 0; }
            if (originY === void 0) { originY = 0; }
            if (color === void 0) { color = 0xff0000; }
            if (alpha === void 0) { alpha = 1; }
            graphics.clear();
            graphics.beginFill(color, alpha);
            graphics.moveTo(originX, originY);
            angle = (Math.abs(angle) > 360) ? 360 : angle;
            var n = Math.ceil(Math.abs(angle) / 45);
            var angleA = angle / n;
            angleA = angleA * Math.PI / 180;
            startFrom = startFrom * Math.PI / 180;
            graphics.lineTo(originX + r * Math.cos(startFrom), originY + r * Math.sin(startFrom));
            for (var i = 1; i <= n; i++) {
                startFrom += angleA;
                var angleMid = startFrom - angleA >> 1;
                var bx = originX + r / Math.cos(angleA >> 1) * Math.cos(angleMid);
                var by = originY + r / Math.cos(angleA >> 1) * Math.sin(angleMid);
                var cx = originX + r * Math.cos(startFrom);
                var cy = originY + r * Math.sin(startFrom);
                graphics.curveTo(bx, by, cx, cy);
            }
            if (angle != 360) {
                graphics.lineTo(originX, originY);
            }
            graphics.endFill();
        };
        return GraphicsUtil;
    }());
    Utils.GraphicsUtil = GraphicsUtil;
    __reflect(GraphicsUtil.prototype, "Utils.GraphicsUtil");
})(Utils || (Utils = {}));
//# sourceMappingURL=GraphicsUtil.js.map