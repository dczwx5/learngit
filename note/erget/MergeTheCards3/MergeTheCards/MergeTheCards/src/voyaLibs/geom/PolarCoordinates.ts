namespace VL {
    export namespace Geom {
        /**
         * 极坐标
         */
        export class PolarCoordinates extends VL.ObjectCache.CacheableClass {
            private _degree: number;
            private _r: number;

            public init(degree: number, r: number): PolarCoordinates {
                this._degree = degree;
                this._r = r;
                return this;
            }

            public clear() {
                this._degree = 0;
                this._r = 0;
            }

            public fromPoint(point: egret.Point): PolarCoordinates {
                this._r = Math.sqrt(point.x * point.x + point.y * point.y);
                this._degree = radian2Degree(Math.atan2(point.y, point.x));
                return this;
            }

            public toPoint(point: egret.Point = null): egret.Point {
                let x = this.r * Math.cos(degree2Radian(this._degree));
                let y = this.r * Math.sin(degree2Radian(this._degree));

                if (!point) {
                    return egret.Point.create(x, y);
                }
                return point.setTo(x, y);
            }

            public fromVector2D(vec: Vector2D): PolarCoordinates {
                this._r = Math.sqrt(vec.x * vec.x + vec.y * vec.y);
                this._degree = radian2Degree(Math.atan2(vec.y, vec.x));
                return this;
            }

            public toVector(vec: Vector2D = null): Vector2D {
                let x = this.r * Math.cos(degree2Radian(this._degree));
                let y = this.r * Math.sin(degree2Radian(this._degree));
                if (!vec) {
                    return create(Vector2D).init(x, y);
                }
                return vec.init(x, y);
            }

            /**
             * 根据弧长设置角度，半径用当前示例的r
             * @param L 弧长
             */
            public setDegreeByArcLength(L: number): PolarCoordinates {
                if (this.r != 0) {
                    this._degree = 180 * L / (Math.PI * this.r);
                }
                return this;
            }

            /**
             * 增加弧长对应的角度，半径用当前示例的r
             * @param L 弧长
             */
            public addDegreeByArcLength(L: number):PolarCoordinates{
                if (this.r != 0) {
                    this._degree += 180 * L / (Math.PI * this.r);
                }
                return this;
            }

            public get degree(): number {
                return this._degree;
            }

            public set degree(value: number) {
                this._degree = value;
            }

            public get r(): number {
                return this._r;
            }

            public set r(value: number) {
                this._r = value;
            }
        }
    }
}
