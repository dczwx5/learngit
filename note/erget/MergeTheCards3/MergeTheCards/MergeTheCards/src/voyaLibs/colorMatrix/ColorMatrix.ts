namespace VL {
    export class ColorMatrix {

        private _isChanged: boolean;

        private _r: number;
        private _g: number;
        private _b: number;

        /**
         * 透明度 0 ~ 1
         */
        private _a: number;

        /**
         * 饱和度 0 ~ 2
         */
        private _saturation: number;

        /**
         * 亮度 -255 ~ 255
         */
        private _brightness: number;

        /**
         * 对比度 0 ~ 10
         */
        private _contrastRatio: number;

        /**
         * 颜色矩阵
         */
        private _matrix: number[];

        constructor() {
            this.reset();
        }

        public reset() {
            if (!this._matrix) {
                this._matrix = [];
            }
            let arr = this._matrix;
            for (let i = 0, l = arr.length; i < l; i++) {
                arr[i] = 0;
            }
            arr[0] = arr[6] = arr[12] = arr[18] = 1;
        }

        public getMatrix(): number[] {
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
        }

        private setRGB() {
            let r = this.r;
            let g = this.g;
            let b = this.b;
            let mx = Math.max(r, g, b);
            let mn = Math.min(r, g, b);
            let avg = (mx + mn) >> 1;
            let arr = this._matrix;
            arr[0] += (r - avg) / avg;//r
            arr[6] += (g - avg) / avg;//g
            arr[12] += (b - avg) / avg;//b
        }

        /** 设置饱和度 */
        private setSaturation() {
            // 4、色彩饱和度
            // N取值为0到2，当然也可以更高。
            // 0.3086*(1-N) + N, 0.6094*(1-N)    , 0.0820*(1-N)    , 0, 0,
            // 0.3086*(1-N)   , 0.6094*(1-N) + N, 0.0820*(1-N)    , 0, 0,
            // 0.3086*(1-N)   , 0.6094*(1-N)    , 0.0820*(1-N) + N 0, 0,
            //     0        , 0        , 0        , 1, 0
            let arr = this._matrix;
            let s = this.saturation;
            arr[0] = 0.3086 * (arr[0] - s) + s;
            arr[1] = 0.6094 * (arr[1] - s);
            arr[2] = 0.0820 * (arr[2] - s);

            arr[5] = 0.3086 * (arr[5] - s);
            arr[6] = 0.6094 * (arr[6] - s) + s;
            arr[7] = 0.0820 * (arr[7] - s);

            arr[10] = 0.3086 * (arr[10] - s);
            arr[11] = 0.6094 * (arr[11] - s);
            arr[12] = 0.0820 * (arr[12] - s) + s;
        }

        /** 设置亮度 */
        private setBrightness() {
            // 1、调整亮度：
            // 亮度(N取值为-255到255)
            // 1,0,0,0,N
            // 0,1,0,0,N
            // 0,0,1,0,N
            // 0,0,0,1,0
            let brightness = this.brightness;
            let arr = this._matrix;
            arr[4] += brightness;
            arr[9] += brightness;
            arr[14] += brightness;
        }

        /** 设置透明度 */
        private setAlpha() {
            this._matrix[18] = this.a;
        }

        /** 设置对比度 */
        private setContrastRatio() {
            // N取值为0到10
            // N,0,0,0,128*(1-N)
            // 0,N,0,0,128*(1-N)
            // 0,0,N,0,128*(1-N)
            // 0,0,0,1,0
            let contrastRatio = this.contrastRatio;
            let arr = this._matrix;
            arr[0] *= contrastRatio;
            arr[4] += 128 * (arr[4] - contrastRatio);
            arr[6] *= contrastRatio;
            arr[9] += 128 * (arr[9] - contrastRatio);
            arr[12] *= contrastRatio;
            arr[14] += 128 * (arr[14] - contrastRatio);
        }

        get r(): number {
            return this._r;
        }

        set r(value: number) {
            if (this._r == value) {
                return;
            }
            this._r = value;
            this._isChanged = true;
        }

        get g(): number {
            return this._g;
        }

        set g(value: number) {
            if (this._g == value) {
                return;
            }
            this._g = value;
            this._isChanged = true;
        }

        get b(): number {
            return this._b;
        }

        set b(value: number) {
            if (this._b == value) {
                return;
            }
            this._b = value;
            this._isChanged = true;
        }

        get a(): number {
            return this._a;
        }

        set a(value: number) {
            if (this._a == value) {
                return;
            }
            this._a = value;
            this._isChanged = true;
        }

        get saturation(): number {
            return this._saturation;
        }

        set saturation(value: number) {
            if (this._saturation == value) {
                return;
            }
            this._saturation = value;
            this._isChanged = true;
        }

        get brightness(): number {
            return this._brightness;
        }

        set brightness(value: number) {
            if (this._brightness == value) {
                return;
            }
            this._brightness = value;
            this._isChanged = true;
        }

        get contrastRatio(): number {
            return this._contrastRatio;
        }

        set contrastRatio(value: number) {
            if (this._contrastRatio == value) {
                return;
            }
            this._contrastRatio = value;
            this._isChanged = true;
        }

        get matrix(): number[] {
            return this._matrix;
        }

        set matrix(value: number[]) {
            if (this._matrix == value) {
                return;
            }
            this._matrix = value;
            this._isChanged = true;
        }
    }
}