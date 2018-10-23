var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var VL;
(function (VL) {
    var Geom;
    (function (Geom) {
        /**
         * 2D向量
         */
        var Vector2D = (function (_super) {
            __extends(Vector2D, _super);
            function Vector2D() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            Vector2D.prototype.init = function (x, y) {
                if (x === void 0) { x = 0; }
                if (y === void 0) { y = 0; }
                this._x = x;
                this._y = y;
                return this;
            };
            Vector2D.prototype.clear = function () {
                this._x = 0;
                this._y = 0;
            };
            /**
             * 绘制一条线段
             * @param graphics
             * @param color
             */
            Vector2D.prototype.draw = function (graphics, color) {
                if (color === void 0) { color = 0; }
                graphics.lineStyle(0, color);
                graphics.moveTo(0, 0);
                graphics.lineTo(this._x, this._y);
            };
            /**
             * 复制向量
             * @returns {Vector2D}
             */
            Vector2D.prototype.clone = function () {
                return create(Vector2D).init(this.x, this.y);
            };
            /**
             * 将当前向量变成0向量
             * @returns {VL.Geom.Vector2D}
             */
            Vector2D.prototype.zero = function () {
                this._x = 0;
                this._y = 0;
                return this;
            };
            /**
             * 判断是否是0向量
             * @returns {boolean}
             */
            Vector2D.prototype.isZero = function () {
                return this._x == 0 && this._y == 0;
            };
            Object.defineProperty(Vector2D.prototype, "length", {
                get: function () {
                    return Math.sqrt(this.lengthSQ);
                },
                /**
                 * 设置向量的大小
                 * @param value
                 */
                set: function (value) {
                    var a = this.angle;
                    this._x = Math.cos(a) * value;
                    this._y = Math.sin(a) * value;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Vector2D.prototype, "lengthSQ", {
                /**
                 * 获取当前向量大小的平方
                 * @returns {number}
                 */
                get: function () {
                    return this._x * this._x + this._y * this._y;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Vector2D.prototype, "angle", {
                get: function () {
                    return Math.atan2(this._y, this._x);
                },
                /**
                 * 设置向量的弧度角
                 * @param value
                 */
                set: function (value) {
                    var len = this.length;
                    this._x = Math.cos(value) * len;
                    this._y = Math.sin(value) * len;
                },
                enumerable: true,
                configurable: true
            });
            /**
             * 将当前向量转化成单位向量
             * @returns {VL.Geom.Vector2D}
             */
            Vector2D.prototype.normalize = function () {
                if (this.length == 0) {
                    this._x = 1;
                    return this;
                }
                var len = this.length;
                this._x /= len;
                this._y /= len;
                return this;
            };
            /**
             * 截取当前向量
             * @param max
             * @returns {VL.Geom.Vector2D}
             */
            Vector2D.prototype.truncate = function (max) {
                this.length = Math.min(max, this.length);
                return this;
            };
            /**
             * 反转向量
             * @returns {VL.Geom.Vector2D}
             */
            Vector2D.prototype.reverse = function () {
                this._x = -this._x;
                this._y = -this._y;
                return this;
            };
            /**
             * 判断当前向量是否是单位向量
             * @returns {boolean}
             */
            Vector2D.prototype.isNormalized = function () {
                return this.length == 1;
            };
            /**
             * 向量点积
             * @param v2
             * @returns {number}
             */
            Vector2D.prototype.dotProd = function (v2) {
                return this._x * v2.x + this._y * v2.y;
            };
            /**
             * 向量叉积
             * @param v2
             * @returns {number}
             */
            Vector2D.prototype.crossProd = function (v2) {
                return this._x * v2.y - this._y * v2.x;
            };
            /**
             * 返回两向量夹角的弧度值
             * @param v1
             * @param v2
             * @returns {number}
             */
            Vector2D.angleBetween = function (v1, v2) {
                var restore1 = false;
                var restore2 = false;
                if (!v1.isNormalized()) {
                    v1 = v1.clone().normalize();
                    restore1 = true;
                }
                if (!v2.isNormalized()) {
                    v2 = v2.clone().normalize();
                    restore2 = true;
                }
                var result = Math.acos(v1.dotProd(v2));
                if (restore1) {
                    v1.restore();
                }
                if (restore2) {
                    v2.restore();
                }
                return result;
            };
            /**
             * 返回当前向量与V2的距离
             * @param v2
             * @returns {number}
             */
            Vector2D.prototype.dist = function (v2) {
                return Math.sqrt(this.distSQ(v2));
            };
            /**
             * 返回当前向量与V2的距离的平方
             * @param v2
             * @returns {number}
             */
            Vector2D.prototype.distSQ = function (v2) {
                var dx = v2.x - this.x;
                var dy = v2.y - this.y;
                return dx * dx + dy * dy;
            };
            /**
             * 两向量相加
             * @param v2
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            Vector2D.prototype.add = function (v2, onThis) {
                if (onThis === void 0) { onThis = true; }
                var vec = onThis ? this : create(Vector2D);
                return vec.init(this._x + v2.x, this._y + v2.y);
            };
            /**
             * 两向量相减
             * @param v2
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            Vector2D.prototype.subtract = function (v2, onThis) {
                if (onThis === void 0) { onThis = true; }
                var vec = onThis ? this : create(Vector2D);
                return vec.init(this._x - v2.x, this.y - v2.y);
            };
            /**
             * 数与向量的乘积
             * @param value
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            Vector2D.prototype.multiply = function (value, onThis) {
                if (onThis === void 0) { onThis = true; }
                var vec = onThis ? this : create(Vector2D);
                return vec.init(this._x * value, this._y * value);
            };
            /**
             * 向量与数的商
             * @param value
             * @param onThis 是否是改变当前向量的值，false的话则返回一个新的向量对象
             * @returns {Vector2D}
             */
            Vector2D.prototype.divide = function (value, onThis) {
                if (onThis === void 0) { onThis = true; }
                var vec = onThis ? this : create(Vector2D);
                return vec.init(this._x / value, this._y / value);
            };
            /**
             * 判断两向量是否相等
             * @param v2
             * @returns {boolean}
             */
            Vector2D.prototype.equals = function (v2) {
                return this._x == v2.x && this._y == v2.y;
            };
            Vector2D.prototype.fromPoint = function (point) {
                this.x = point.x;
                this.y = point.y;
                return this;
            };
            /**
             * 转换成egret.Point对象
             * @param point 如果传入此对象则将当前向量值赋予它并返回，否则创建个新的返回
             * @returns {Point}
             */
            Vector2D.prototype.toPoint = function (point) {
                if (point === void 0) { point = null; }
                if (point) {
                    return point.setTo(this.x, this.y);
                }
                return egret.Point.create(this.x, this.y);
            };
            /**
             * 根据一个极坐标对象的值设置自己的值
             * @param p
             * @returns {Vector2D}
             */
            Vector2D.prototype.fromPolarCoordinates = function (p) {
                var x = p.r * Geom.radian2Degree(Math.cos(Geom.degree2Radian(p.degree)));
                var y = p.r * Geom.radian2Degree(Math.sin(Geom.degree2Radian(p.degree)));
                return this.init(x, y);
            };
            /**
             * 转换成极坐标对象
             * @param p 如果传入此对象则将当前向量值赋予它并返回，否则创建个新的返回
             * @returns {Point}
             */
            Vector2D.prototype.toPolarCoordinates = function (p) {
                if (p === void 0) { p = null; }
                var r = Math.sqrt(this.x * this.x + this.y * this.y);
                var degree = Geom.radian2Degree(Math.atan2(this.y, this.x));
                if (!p) {
                    return create(Geom.PolarCoordinates).init(degree, r);
                }
                return p.init(degree, r);
            };
            Object.defineProperty(Vector2D.prototype, "x", {
                get: function () {
                    return this._x;
                },
                //设置X坐标
                set: function (value) {
                    this._x = value;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Vector2D.prototype, "y", {
                get: function () {
                    return this._y;
                },
                //设置Y坐标
                set: function (value) {
                    this._y = value;
                },
                enumerable: true,
                configurable: true
            });
            //返回对象的字符形式
            Vector2D.prototype.toString = function () {
                return "[Vector2D(X:" + this._x + ",y:" + this._y + ")]";
            };
            return Vector2D;
        }(VL.ObjectCache.CacheableClass));
        Geom.Vector2D = Vector2D;
        __reflect(Vector2D.prototype, "VL.Geom.Vector2D");
    })(Geom = VL.Geom || (VL.Geom = {}));
})(VL || (VL = {}));
//# sourceMappingURL=Vector2D.js.map