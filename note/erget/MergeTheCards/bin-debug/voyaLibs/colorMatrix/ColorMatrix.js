var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var ColorMatrix = (function () {
        function ColorMatrix() {
            this.reset();
        }
        ColorMatrix.prototype.reset = function () {
            if (!this._matrix) {
                this._matrix = [];
            }
            var arr = this._matrix;
            for (var i = 0, l = arr.length; i < l; i++) {
                arr[i] = 0;
            }
            arr[0] = arr[6] = arr[12] = arr[18] = 1;
        };
        ColorMatrix.prototype.getMatrix = function () {
            if (this._isChanged) {
                this.reset();
                this.setRGB();
                this.setSaturation();
                this.setContrastRatio();
                this.setBrightness();
                this.setAlpha();
                this._isChanged = false;
            }
            return this._matrix.concat();
        };
        ColorMatrix.prototype.setRGB = function () {
            var r = this.r;
            var g = this.g;
            var b = this.b;
            var mx = Math.max(r, g, b);
            var mn = Math.min(r, g, b);
            var avg = (mx + mn) >> 1;
            var arr = this._matrix;
            arr[0] += (r - avg) / avg; //r
            arr[6] += (g - avg) / avg; //g
            arr[12] += (b - avg) / avg; //b
        };
        /** 设置饱和度 */
        ColorMatrix.prototype.setSaturation = function () {
            // 4、色彩饱和度
            // N取值为0到2，当然也可以更高。
            // 0.3086*(1-N) + N, 0.6094*(1-N)    , 0.0820*(1-N)    , 0, 0,
            // 0.3086*(1-N)   , 0.6094*(1-N) + N, 0.0820*(1-N)    , 0, 0,
            // 0.3086*(1-N)   , 0.6094*(1-N)    , 0.0820*(1-N) + N 0, 0,
            //     0        , 0        , 0        , 1, 0
            var arr = this._matrix;
            var s = this.saturation;
            arr[0] = 0.3086 * (arr[0] - s) + s;
            arr[1] = 0.6094 * (arr[1] - s);
            arr[2] = 0.0820 * (arr[2] - s);
            arr[5] = 0.3086 * (arr[5] - s);
            arr[6] = 0.6094 * (arr[6] - s) + s;
            arr[7] = 0.0820 * (arr[7] - s);
            arr[10] = 0.3086 * (arr[10] - s);
            arr[11] = 0.6094 * (arr[11] - s);
            arr[12] = 0.0820 * (arr[12] - s) + s;
        };
        /** 设置亮度 */
        ColorMatrix.prototype.setBrightness = function () {
            // 1、调整亮度：
            // 亮度(N取值为-255到255)
            // 1,0,0,0,N
            // 0,1,0,0,N
            // 0,0,1,0,N
            // 0,0,0,1,0
            var brightness = this.brightness;
            var arr = this._matrix;
            arr[4] += brightness;
            arr[9] += brightness;
            arr[14] += brightness;
        };
        /** 设置透明度 */
        ColorMatrix.prototype.setAlpha = function () {
            this._matrix[18] = this.a;
        };
        /** 设置对比度 */
        ColorMatrix.prototype.setContrastRatio = function () {
            // N取值为0到10
            // N,0,0,0,128*(1-N)
            // 0,N,0,0,128*(1-N)
            // 0,0,N,0,128*(1-N)
            // 0,0,0,1,0
            var contrastRatio = this.contrastRatio;
            var arr = this._matrix;
            arr[0] *= contrastRatio;
            arr[4] += 128 * (arr[4] - contrastRatio);
            arr[6] *= contrastRatio;
            arr[9] += 128 * (arr[9] - contrastRatio);
            arr[12] *= contrastRatio;
            arr[14] += 128 * (arr[14] - contrastRatio);
        };
        Object.defineProperty(ColorMatrix.prototype, "r", {
            get: function () {
                return this._r;
            },
            set: function (value) {
                if (this._r == value) {
                    return;
                }
                this._r = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "g", {
            get: function () {
                return this._g;
            },
            set: function (value) {
                if (this._g == value) {
                    return;
                }
                this._g = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "b", {
            get: function () {
                return this._b;
            },
            set: function (value) {
                if (this._b == value) {
                    return;
                }
                this._b = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "a", {
            get: function () {
                return this._a;
            },
            set: function (value) {
                if (this._a == value) {
                    return;
                }
                this._a = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "saturation", {
            get: function () {
                return this._saturation;
            },
            set: function (value) {
                if (this._saturation == value) {
                    return;
                }
                this._saturation = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "brightness", {
            get: function () {
                return this._brightness;
            },
            set: function (value) {
                if (this._brightness == value) {
                    return;
                }
                this._brightness = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "contrastRatio", {
            get: function () {
                return this._contrastRatio;
            },
            set: function (value) {
                if (this._contrastRatio == value) {
                    return;
                }
                this._contrastRatio = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        Object.defineProperty(ColorMatrix.prototype, "matrix", {
            get: function () {
                return this._matrix;
            },
            set: function (value) {
                if (this._matrix == value) {
                    return;
                }
                this._matrix = value;
                this._isChanged = true;
            },
            enumerable: true,
            configurable: true
        });
        return ColorMatrix;
    }());
    VL.ColorMatrix = ColorMatrix;
    __reflect(ColorMatrix.prototype, "VL.ColorMatrix");
})(VL || (VL = {}));
//# sourceMappingURL=ColorMatrix.js.map