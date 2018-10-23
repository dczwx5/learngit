namespace VL {
    export namespace Geom {
        /**
         * 2D向量
         */
        export class Vector2D extends VL.ObjectCache.CacheableClass {
            private _x: number;
            private _y: number;


            public init(x: number = 0, y: number = 0): Vector2D {
                this._x = x;
                this._y = y;
                return this;
            }

            public clear() {
                this._x = 0;
                this._y = 0;
            }

            /**
             * 绘制一条线段
             * @param graphics
             * @param color
             */
            public draw(graphics: egret.Graphics, color: number = 0): void {
                graphics.lineStyle(0, color);
                graphics.moveTo(0, 0);
                graphics.lineTo(this._x, this._y);
            }

            /**
             * 复制向量
             * @returns {Vector2D}
             */
            public clone(): Vector2D {
                return create(Vector2D).init(this.x, this.y);
            }

            /**
             * 将当前向量变成0向量
             * @returns {VL.Geom.Vector2D}
             */
            public zero(): Vector2D {
                this._x = 0;
                this._y = 0;
                return this;
            }

            /**
             * 判断是否是0向量
             * @returns {boolean}
             */
            public isZero(): Boolean {
                return this._x == 0 && this._y == 0;
            }

            /**
             * 设置向量的大小
             * @param value
             */
            public set length(value: number) {
                let a = this.angle;
                this._x = Math.cos(a) * value;
                this._y = Math.sin(a) * value;
            }

            public get length(): number {
                return Math.sqrt(this.lengthSQ);
            }

            /**
             * 获取当前向量大小的平方
             * @returns {number}
             */
            public get lengthSQ(): number {
                return this._x * this._x + this._y * this._y;
            }

            /**
             * 设置向量的弧度角
             * @param value
             */
            public set angle(value: number) {
                let len: number = this.length;
                this._x = Math.cos(value) * len;
                this._y = Math.sin(value) * len;
            }

            public get angle(): number {
                return Math.atan2(this._y, this._x);
            }

            /**
             * 将当前向量转化成单位向量
             * @returns {VL.Geom.Vector2D}
             */
            public normalize(): Vector2D {
                if (this.length == 0) {
                    this._x = 1;
                    return this;
                }
                let len: number = this.length;
                this._x /= len;
                this._y /= len;
                return this;
            }

            /**
             * 截取当前向量
             * @param max
             * @returns {VL.Geom.Vector2D}
             */
            public truncate(max: number): Vector2D {
                this.length = Math.min(max, this.length);
                return this;
            }

            /**
             * 反转向量
             * @returns {VL.Geom.Vector2D}
             */
            public reverse(): Vector2D {
                this._x = -this._x;
                this._y = -this._y;
                return this;
            }

            /**
             * 判断当前向量是否是单位向量
             * @returns {boolean}
             */
            public isNormalized(): boolean {
                return this.length == 1;
            }

            /**
             * 向量点积
             * @param v2
             * @returns {number}
             */
            public dotProd(v2: Vector2D): number {
                return this._x * v2.x + this._y * v2.y;
            }

            /**
             * 向量叉积
             * @param v2
             * @returns {number}
             */
            public crossProd(v2: Vector2D): number {
                return this._x * v2.y - this._y * v2.x;
            }

            /**
             * 返回两向量夹角的弧度值
             * @param v1
             * @param v2
             * @returns {number}
             */
            public static angleBetween(v1: Vector2D, v2: Vector2D): number {
                let restore1: boolean = false;
                let restore2: boolean = false;
                if (!v1.isNormalized()) {
                    v1 = v1.clone().normalize();
                    restore1 = true;
                }
                if (!v2.isNormalized()) {
                    v2 = v2.clone().normalize();
                    restore2 = true;
                }
                let result = Math.acos(v1.dotProd(v2));
                if (restore1) {
                    v1.restore();
                }
                if (restore2) {
                    v2.restore();
                }
                return result;
            }

            /**
             * 返回当前向量与V2的距离
             * @param v2
             * @returns {number}
             */
            public dist(v2: Vector2D): number {
                return Math.sqrt(this.distSQ(v2));
            }

            /**
             * 返回当前向量与V2的距离的平方
             * @param v2
             * @returns {number}
             */
            public distSQ(v2: Vector2D): number {
                let dx: number = v2.x - this.x;
                let dy: number = v2.y - this.y;
                return dx * dx + dy * dy;
            }

            /**
             * 两向量相加
             * @param v2
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            public add(v2: Vector2D, onThis: boolean = true): Vector2D {
                let vec = onThis ? this : create(Vector2D);
                return vec.init(this._x + v2.x, this._y + v2.y);
            }

            /**
             * 两向量相减
             * @param v2
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            public subtract(v2: Vector2D, onThis: boolean = true): Vector2D {
                let vec = onThis ? this : create(Vector2D);
                return vec.init(this._x - v2.x, this.y - v2.y);
            }

            /**
             * 数与向量的乘积
             * @param value
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            public multiply(value: number, onThis: boolean = true): Vector2D {
                let vec = onThis ? this : create(Vector2D);
                return vec.init(this._x * value, this._y * value);
            }

            /**
             * 向量与数的商
             * @param value
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            public divide(value: number, onThis: boolean = true): Vector2D {
                let vec = onThis ? this : create(Vector2D);
                return vec.init(this._x / value, this._y / value);
            }

            /**
             * 判断两向量是否相等
             * @param v2
             * @returns {boolean}
             */
            public equals(v2: Vector2D): boolean {
                return this._x == v2.x && this._y == v2.y;
            }

            public fromPoint(point: egret.Point): Vector2D {
                this.x = point.x;
                this.y = point.y;
                return this;
            }

            /**
             * 转换成egret.Point对象
             * @param point 如果传入此对象则将当前向量值赋予它并返回，否则创建个新的返回
             * @returns {Point}
             */
            public toPoint(point: egret.Point = null): egret.Point {
                if (point) {
                    return point.setTo(this.x, this.y);
                }
                return egret.Point.create(this.x, this.y);
            }

            /**
             * 根据一个极坐标对象的值设置自己的值
             * @param p
             * @returns {Vector2D}
             */
            public fromPolarCoordinates(p: PolarCoordinates) {
                let x = p.r * radian2Degree(Math.cos(degree2Radian(p.degree)));
                let y = p.r * radian2Degree(Math.sin(degree2Radian(p.degree)));
                return this.init(x, y);
            }

            /**
             * 转换成极坐标对象
             * @param p 如果传入此对象则将当前向量值赋予它并返回，否则创建个新的返回
             * @returns {Point}
             */
            public toPolarCoordinates(p: PolarCoordinates = null): PolarCoordinates {
                let r = Math.sqrt(this.x * this.x + this.y * this.y);
                let degree = radian2Degree(Math.atan2(this.y, this.x));
                if (!p) {
                    return create(PolarCoordinates).init(degree, r);
                }
                return p.init(degree, r);
            }

            //设置X坐标
            public set x(value: number) {
                this._x = value;
            }

            public get x(): number {
                return this._x;
            }

            //设置Y坐标
            public set y(value: number) {
                this._y = value;
            }

            public get y(): number {
                return this._y;
            }

            //返回对象的字符形式
            public toString(): string {
                return "[Vector2D(X:" + this._x + ",y:" + this._y + ")]";
            }
        }
    }
}
