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

        export function isPointInRect(ptX:number, ptY:number, rectX:number, rectY:number, rectW:number, rectH:number):boolean{
            return ptX >= rectX && ptX <= rectW && ptY >= rectY && ptY <= rectH
        }
    }
}