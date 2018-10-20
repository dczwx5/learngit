var VL;
(function (VL) {
    var Geom;
    (function (Geom) {
        /**
         * 角度转弧度
         * @param degree
         * @returns {number}
         */
        function degree2Radian(degree) {
            return Math.PI / 180 * degree;
        }
        Geom.degree2Radian = degree2Radian;
        /**
         * 弧度转角度
         * @param radian
         * @returns {number}
         */
        function radian2Degree(radian) {
            return 180 / Math.PI * radian;
        }
        Geom.radian2Degree = radian2Degree;
        function isPointInRect(ptX, ptY, rectX, rectY, rectW, rectH) {
            return ptX >= rectX && ptX <= rectW && ptY >= rectY && ptY <= rectH;
        }
        Geom.isPointInRect = isPointInRect;
    })(Geom = VL.Geom || (VL.Geom = {}));
})(VL || (VL = {}));
//# sourceMappingURL=utils.js.map