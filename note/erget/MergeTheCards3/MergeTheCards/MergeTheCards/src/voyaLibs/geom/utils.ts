namespace VL {
    export namespace Geom {

        /**
         * 角度转弧度
         * @param degree
         * @returns {number}
         */
        export function degree2Radian(degree: number): number {
            return Math.PI / 180 * degree;
        }

        /**
         * 弧度转角度
         * @param radian
         * @returns {number}
         */
        export function radian2Degree(radian: number): number {
            return 180 / Math.PI * radian;
        }

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
        export function isPointInRect(ptX: number, ptY: number, rectX: number, rectY: number, rectW: number, rectH: number): boolean {
            return ptX >= rectX && ptX <= rectW && ptY >= rectY && ptY <= rectH;
        }

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
        export function isPolygonContainsPoint(points: egret.Point[], test: egret.Point) {
            let res: boolean = false;
            for (let i = 0, l = points.length, j = l - 1; i < l; j = i++) {
                if ((points[i].y > test.y) != (points[j].y > test.y) &&
                    (test.x < (points[j].x - points[i].x) * (test.y - points[i].y) / (points[j].y - points[i].y) + points[i].x)) {
                    res = !res;
                }
            }
            return res;
        }
    }
}