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
         * 极坐标
         */
        var PolarCoordinates = (function (_super) {
            __extends(PolarCoordinates, _super);
            function PolarCoordinates() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            PolarCoordinates.prototype.init = function (degree, r) {
                this._degree = degree;
                this._r = r;
                return this;
            };
            PolarCoordinates.prototype.clear = function () {
                this._degree = 0;
                this._r = 0;
            };
            PolarCoordinates.prototype.fromPoint = function (point) {
                this._r = Math.sqrt(point.x * point.x + point.y * point.y);
                this._degree = Geom.radian2Degree(Math.atan2(point.y, point.x));
                return this;
            };
            PolarCoordinates.prototype.toPoint = function (point) {
                if (point === void 0) { point = null; }
                var x = this.r * Math.cos(Geom.degree2Radian(this._degree));
                var y = this.r * Math.sin(Geom.degree2Radian(this._degree));
                if (!point) {
                    return egret.Point.create(x, y);
                }
                return point.setTo(x, y);
            };
            PolarCoordinates.prototype.fromVector2D = function (vec) {
                this._r = Math.sqrt(vec.x * vec.x + vec.y * vec.y);
                this._degree = Geom.radian2Degree(Math.atan2(vec.y, vec.x));
                return this;
            };
            PolarCoordinates.prototype.toVector = function (vec) {
                if (vec === void 0) { vec = null; }
                var x = this.r * Math.cos(Geom.degree2Radian(this._degree));
                var y = this.r * Math.sin(Geom.degree2Radian(this._degree));
                if (!vec) {
                    return create(Geom.Vector2D).init(x, y);
                }
                return vec.init(x, y);
            };
            /**
             * 根据弧长设置角度，半径用当前示例的r
             * @param L 弧长
             */
            PolarCoordinates.prototype.setDegreeByArcLength = function (L) {
                if (this.r != 0) {
                    this._degree = 180 * L / (Math.PI * this.r);
                }
                return this;
            };
            /**
             * 增加弧长对应的角度，半径用当前示例的r
             * @param L 弧长
             */
            PolarCoordinates.prototype.addDegreeByArcLength = function (L) {
                if (this.r != 0) {
                    this._degree += 180 * L / (Math.PI * this.r);
                }
                return this;
            };
            Object.defineProperty(PolarCoordinates.prototype, "degree", {
                get: function () {
                    return this._degree;
                },
                set: function (value) {
                    this._degree = value;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(PolarCoordinates.prototype, "r", {
                get: function () {
                    return this._r;
                },
                set: function (value) {
                    this._r = value;
                },
                enumerable: true,
                configurable: true
            });
            return PolarCoordinates;
        }(VL.ObjectCache.CacheableClass));
        Geom.PolarCoordinates = PolarCoordinates;
        __reflect(PolarCoordinates.prototype, "VL.Geom.PolarCoordinates");
    })(Geom = VL.Geom || (VL.Geom = {}));
})(VL || (VL = {}));
//# sourceMappingURL=PolarCoordinates.js.map