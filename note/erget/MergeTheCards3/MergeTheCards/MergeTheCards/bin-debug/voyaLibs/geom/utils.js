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
        /**
         * 判断某点是否在某矩形内
         * @param ptX
         * @param ptY
         * @param rectX
         * @param rectY
         * @param rectW
         * @param rectH
         * @returns {boolean}
         */
        function isPointInRect(ptX, ptY, rectX, rectY, rectW, rectH) {
            return ptX >= rectX && ptX <= rectW && ptY >= rectY && ptY <= rectH;
        }
        Geom.isPointInRect = isPointInRect;
        // public boolean contains(Point test) {
        //     int i;
        //     int j;
        //     boolean result = false;
        //     for (i = 0, j = points.length - 1; i < points.length; j = i++) {
        //         if ((points[i].y > test.y) != (points[j].y > test.y) &&
        //             (test.x < (points[j].x - points[i].x) * (test.y - points[i].y) / (points[j].y-points[i].y) + points[i].x)) {
        //             result = !result;
        //         }
        //     }
        //     return result;
        // }
        function isPolygonContainsPoint(points, test) {
            var res = false;
            for (var i = 0, l = points.length, j = l - 1; i < l; j = i++) {
                if ((points[i].y > test.y) != (points[j].y > test.y) &&
                    (test.x < (points[j].x - points[i].x) * (test.y - points[i].y) / (points[j].y - points[i].y) + points[i].x)) {
                    res = !res;
                }
            }
            return res;
        }
        Geom.isPolygonContainsPoint = isPolygonContainsPoint;
    })(Geom = VL.Geom || (VL.Geom = {}));
})(VL || (VL = {}));
//# sourceMappingURL=utils.js.map