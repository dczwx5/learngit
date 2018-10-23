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
         * 线段类
         */
        var Segment = (function (_super) {
            __extends(Segment, _super);
            function Segment() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            Segment.prototype.init = function (x1, y1, x2, y2) {
                this._x1 = x1;
                this._y1 = y1;
                this._x2 = x2;
                this._y2 = y2;
                return this;
            };
            Segment.prototype.initByPoint = function (pt1, pt2) {
                this._x1 = pt1.x;
                this._y1 = pt1.y;
                this._x2 = pt2.x;
                this._y2 = pt2.y;
                return this;
            };
            Segment.prototype.setPoint1 = function (x, y) {
                this._x1 = x;
                this._y1 = y;
                return this;
            };
            Segment.prototype.setPoint1ByPoint = function (pt) {
                this._x1 = pt.x;
                this._y1 = pt.y;
                return this;
            };
            Segment.prototype.setPoint2 = function (x, y) {
                this._x2 = x;
                this._y2 = y;
                return this;
            };
            Segment.prototype.setPoint2ByPoint = function (pt) {
                this._x2 = pt.x;
                this._y2 = pt.y;
                return this;
            };
            Segment.prototype.clear = function () {
                this._x1 = 0;
                this._y1 = 0;
                this._x2 = 0;
                this._y2 = 0;
            };
            /**
             * 与某个点的最近距离
             * @param pt
             * @returns {number}
             */
            Segment.prototype.dist2Point = function (pt) {
                var ptX = pt.x, ptY = pt.y, segX1 = this.x1, segY1 = this.y1, segX2 = this.x2, segY2 = this.y2;
                var cross = (segX2 - segX1) * (ptX - segX1) + (segY2 - segY1) * (ptY - segY1);
                if (cross <= 0) {
                    return Math.sqrt((ptX - segX1) * (ptX - segX1) + (ptY - segY1) * (ptY - segY1));
                }
                var d2 = (segX2 - segX1) * (segX2 - segX1) + (segY2 - segY1) * (segY2 - segY1);
                if (cross >= d2) {
                    return Math.sqrt((ptX - segX2) * (ptX - segX2) + (ptY - segY2) * (ptY - segY2));
                }
                var r = cross / d2;
                var px = segX1 + (segX2 - segX1) * r;
                var py = segY1 + (segY2 - segY1) * r;
                return Math.sqrt((ptX - px) * (ptX - px) + (py - segY1) * (py - segY1));
            };
            /**
             * 判断与目标线段是否相交
             * @param segment
             * @returns {boolean}
             */
            Segment.prototype.checkCross = function (segment) {
                // let delta = this.determinant(bb.x-aa.x, cc.x-dd.x, bb.y-aa.y, cc.y-dd.y);
                var delta = this.determinant(this.x2 - this.x1, segment.x1 - segment.x2, this.y2 - this.y1, segment.y1 - segment.y2);
                // if ( delta<=(1e-6) && delta>=-(1e-6) )  // delta=0，表示两线段重合或平行
                if (delta == 0) {
                    return false;
                }
                // let namenda = this.determinant(cc.x-aa.x, cc.x-dd.x, cc.y-aa.y, cc.y-dd.y) / delta;
                var namenda = this.determinant(segment.x1 - this.x1, segment.x1 - segment.x2, segment.y1 - this.y1, segment.y1 - segment.y2) / delta;
                if (namenda > 1 || namenda < 0) {
                    return false;
                }
                // let miu = this.determinant(bb.x-aa.x, cc.x-aa.x, bb.y-aa.y, cc.y-aa.y) / delta;
                var miu = this.determinant(this.x2 - this.x1, segment.x1 - this.x1, this.y2 - this.y1, segment.y1 - this.y1) / delta;
                if (miu > 1 || miu < 0) {
                    return false;
                }
                return true;
            };
            Segment.prototype.determinant = function (v1, v2, v3, v4) {
                return v1 * v4 - v2 * v3;
            };
            Segment.prototype.move = function (deltaX, deltaY) {
                this._x1 += deltaX;
                this._x2 += deltaX;
                this._y1 += deltaY;
                this._y2 += deltaY;
            };
            Object.defineProperty(Segment.prototype, "x1", {
                get: function () {
                    return this._x1;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Segment.prototype, "y1", {
                get: function () {
                    return this._y1;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Segment.prototype, "x2", {
                get: function () {
                    return this._x2;
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(Segment.prototype, "y2", {
                get: function () {
                    return this._y2;
                },
                enumerable: true,
                configurable: true
            });
            return Segment;
        }(VL.ObjectCache.CacheableClass));
        Geom.Segment = Segment;
        __reflect(Segment.prototype, "VL.Geom.Segment");
    })(Geom = VL.Geom || (VL.Geom = {}));
})(VL || (VL = {}));
//# sourceMappingURL=Segment.js.map