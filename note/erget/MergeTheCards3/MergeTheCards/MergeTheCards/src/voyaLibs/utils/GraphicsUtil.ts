namespace Utils {
    export class GraphicsUtil {
        /**
         * 画扇形 3点钟方向为0度
         * @param graphics 画布
         * @param r
         * @param startFrom
         * @param angle
         * @param originX 圆心X
         * @param originY 圆心Y
         * @param color
         * @param alpha
         * @returns {egret.Shape}
         */
        public static drawSector(graphics: egret.Graphics, r: number = 100, startFrom: number = 0, angle: number = 360, originX: number = 0, originY: number = 0, color: number = 0xff0000, alpha: number = 1) {
            graphics.clear();
            graphics.beginFill(color, alpha);
            graphics.moveTo(originX, originY);
            angle = (Math.abs(angle) > 360) ? 360 : angle;
            let n: number = Math.ceil(Math.abs(angle) / 45);
            let angleA: number = angle / n;
            angleA = angleA * Math.PI / 180;
            startFrom = startFrom * Math.PI / 180;
            graphics.lineTo(originX + r * Math.cos(startFrom), originY + r * Math.sin(startFrom));
            for (let i = 1; i <= n; i++) {
                startFrom += angleA;
                let angleMid = startFrom - angleA >> 1;
                let bx = originX + r / Math.cos(angleA >> 1) * Math.cos(angleMid);
                let by = originY + r / Math.cos(angleA >> 1) * Math.sin(angleMid);
                let cx = originX + r * Math.cos(startFrom);
                let cy = originY + r * Math.sin(startFrom);
                graphics.curveTo(bx, by, cx, cy);
            }
            if (angle != 360) {
                graphics.lineTo(originX, originY);
            }
            graphics.endFill();
        }

    }
}