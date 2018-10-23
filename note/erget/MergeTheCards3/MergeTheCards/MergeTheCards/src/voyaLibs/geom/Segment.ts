namespace VL {
    export namespace Geom {
        /**
         * 线段类
         */
        export class Segment extends VL.ObjectCache.CacheableClass {
            private _x1: number;
            private _y1: number;
            private _x2: number;
            private _y2: number;

            public init(x1: number, y1: number, x2: number, y2: number): Segment {
                this._x1 = x1;
                this._y1 = y1;
                this._x2 = x2;
                this._y2 = y2;
                return this;
            }

            public initByPoint(pt1: egret.Point, pt2: egret.Point): Segment {
                this._x1 = pt1.x;
                this._y1 = pt1.y;
                this._x2 = pt2.x;
                this._y2 = pt2.y;
                return this;
            }

            public setPoint1(x: number, y: number): Segment {
                this._x1 = x;
                this._y1 = y;
                return this;
            }

            public setPoint1ByPoint(pt: egret.Point): Segment {
                this._x1 = pt.x;
                this._y1 = pt.y;
                return this;
            }

            public setPoint2(x: number, y: number): Segment {
                this._x2 = x;
                this._y2 = y;
                return this;
            }

            public setPoint2ByPoint(pt: egret.Point): Segment {
                this._x2 = pt.x;
                this._y2 = pt.y;
                return this;
            }

            public clear() {
                this._x1 = 0;
                this._y1 = 0;
                this._x2 = 0;
                this._y2 = 0;
            }

            /**
             * 与某个点的最近距离
             * @param pt
             * @returns {number}
             */
            public dist2Point(pt: egret.Point): number {
                let ptX: number = pt.x,
                    ptY: number = pt.y,
                    segX1: number = this.x1,
                    segY1: number = this.y1,
                    segX2: number = this.x2,
                    segY2: number = this.y2;
                let cross = (segX2 - segX1) * (ptX - segX1) + (segY2 - segY1) * (ptY - segY1);
                if (cross <= 0) {
                    return Math.sqrt((ptX - segX1) * (ptX - segX1) + (ptY - segY1) * (ptY - segY1));
                }
                let d2 = (segX2 - segX1) * (segX2 - segX1) + (segY2 - segY1) * (segY2 - segY1);
                if (cross >= d2) {
                    return Math.sqrt((ptX - segX2) * (ptX - segX2) + (ptY - segY2) * (ptY - segY2));
                }
                let r = cross / d2;
                let px = segX1 + (segX2 - segX1) * r;
                let py = segY1 + (segY2 - segY1) * r;
                return Math.sqrt((ptX - px) * (ptX - px) + (py - segY1) * (py - segY1));
            }


            /**
             * 判断与目标线段是否相交
             * @param segment
             * @returns {boolean}
             */
            public checkCross(segment: Segment): boolean {
                // let delta = this.determinant(bb.x-aa.x, cc.x-dd.x, bb.y-aa.y, cc.y-dd.y);
                let delta = this.determinant(this.x2 - this.x1, segment.x1 - segment.x2, this.y2 - this.y1, segment.y1 - segment.y2);
                // if ( delta<=(1e-6) && delta>=-(1e-6) )  // delta=0，表示两线段重合或平行
                if (delta == 0)  // delta=0，表示两线段重合或平行
                {
                    return false;
                }
                // let namenda = this.determinant(cc.x-aa.x, cc.x-dd.x, cc.y-aa.y, cc.y-dd.y) / delta;
                let namenda = this.determinant(segment.x1 - this.x1, segment.x1 - segment.x2, segment.y1 - this.y1, segment.y1 - segment.y2) / delta;
                if (namenda > 1 || namenda < 0) {
                    return false;
                }
                // let miu = this.determinant(bb.x-aa.x, cc.x-aa.x, bb.y-aa.y, cc.y-aa.y) / delta;
                let miu = this.determinant(this.x2 - this.x1, segment.x1 - this.x1, this.y2 - this.y1, segment.y1 - this.y1) / delta;
                if (miu > 1 || miu < 0) {
                    return false;
                }
                return true;
            }

            private determinant(v1: number, v2: number, v3: number, v4: number)  // 行列式
            {
                return v1 * v4 - v2 * v3;
            }

            public move(deltaX:number, deltaY:number){
                this._x1 += deltaX;
                this._x2 += deltaX;
                this._y1 += deltaY;
                this._y2 += deltaY;
            }

            get x1(): number {
                return this._x1;
            }

            get y1(): number {
                return this._y1;
            }

            get x2(): number {
                return this._x2;
            }

            get y2(): number {
                return this._y2;
            }
        }
    }
}
