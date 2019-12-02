export module TweenUtil {
    // shakeV : 上下震
    // shakeH : 左右震
    // len : 震动强度
    // times : 震动次数
    // isResetPos : 是否恢复原来的坐标
    // isScalc : 是否缩放
    // scaleLen : 每次scaleLen大小
    export function shakeObject(sp:Laya.Sprite, shakeV:boolean, shakeH:boolean, len:number = 4, times:number = 5, 
        isResetPos:boolean = true, isScalc:boolean = false, scaleLen:number = 0.05) : void {
        let baseX:number = sp.x;
        let baseY:number = sp.y;
        let baseScale:number = sp.scaleX;
        let count:number = 0;
        let isUp:Boolean = Math.random()*10 > 4;
        let mCount:number = 0;
        let MAX_COUNT:number = times * len;
        let pThis = this;
        Laya.timer.frameLoop(1, sp, function () : void {
            if (isUp) {
                if (shakeV) {
                    sp.y++;
                }
                if (shakeH) {
                    sp.x++;
                }
                if (isScalc) {
                    sp.scaleX += scaleLen;
                    sp.scaleY = sp.scaleX;
                }
                if (mCount > len) {
                    isUp = false;
                    mCount = 0;
                }
                
            } else {
                if (shakeV) {
                    sp.y--;
                }
                if (shakeH) {
                    sp.x--;
                }
                if (isScalc) {
                    sp.scaleX -= scaleLen;
                    sp.scaleY = sp.scaleX;
                }
                if (mCount > len) {
                    isUp = true;
                    mCount = 0;						
                }
            }
            mCount++;
            count++;
            if (count > MAX_COUNT) {
                Laya.timer.clearAll(sp);
                if (isResetPos) {
                    if (shakeV) {
                        sp.y = baseY;
                    }
                    if (shakeH) {
                        sp.x = baseX;
                    }
                    if (isScalc) {
                        sp.scaleX = baseScale;
                        sp.scaleY = sp.scaleX;
                    }
                }
            }
        });		
    }
}