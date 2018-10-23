namespace App {
    /**
     * 模态VIEW
     */
    export abstract class BaseWindow extends BaseEuiView {

        /**是否遮罩*/
        private _isMask: boolean = false;
        protected _uiMask: egret.Sprite = null;
        protected _centerH: boolean;
        protected _centerV: boolean;
        /**遮罩透明度*/
        private _maskAlpha: number = 0.5;

        public readonly dg_onMaskTap: VL.Delegate = new VL.Delegate();


        constructor(skinName:string, layer: App.BaseEuiLayer = GameLayers.UI_Popup, isMask: boolean = true, isTouch: boolean = true, centerH: boolean = true, centerV: boolean = true) {
            super(skinName, layer);
            this._centerH = centerH;
            this._centerV = centerV;
            this._isMask = isMask;
            if (isMask) {//显示遮罩
                this.initMask(isTouch);
            }
        }

        protected updateLayout() {
            if (this._centerH) {
                this.x = StageUtils.getStageWidth() - this.width >> 1;
            }
            if (this._centerV) {
                this.y = StageUtils.getStageHeight() - this.height >> 1;
            }
            this.updateMask();
        }

        protected initMask(isTouch: boolean) {
            this.cleanUiMask();
            this._uiMask = new egret.Sprite();
            this._uiMask.touchEnabled = isTouch;
            this._uiMask.touchChildren = false;
        }

        protected updateMask() {
            if (!this._isMask) {
                return;
            }
            let g = this._uiMask.graphics;
            g.clear();
            g.beginFill(0x000000, 1);
            g.drawRect(0, 0, StageUtils.getStageWidth(), StageUtils.getStageHeight());
            g.endFill();
            this.setMaskAlpha(this._maskAlpha);
            if (this._uiMask.parent != this.myParent) {
                // this.myParent.addChildAt(this._uiMask, Math.max(0, this.myParent.getChildIndex(this)));
                this.myParent.addChildAt(this._uiMask, this.myParent.getChildIndex(this));
            }
        }

        protected setMaskAlpha(val: number): void {
            let self = this;
            if (self._uiMask == null) return;
            self._maskAlpha = val;
            self._uiMask.alpha = self._maskAlpha;
        }

        protected cleanUiMask() {
            let self = this;
            if (self._uiMask) {
                if (self._uiMask.parent){
                    self._uiMask.parent.removeChild(self._uiMask);
                }
                self._uiMask.graphics.clear();
                self._uiMask = null;
            }
        }

        public open(param:any = null): void {
            super.open();
            if (this._isMask && this._uiMask) {
                this._uiMask.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onMaskTap, this);
                this.updateMask();
            }
        }

        public close(param:any = null): void {
            super.close();
            if (this._isMask && this._uiMask.parent) {
                this._uiMask.parent.removeChild(this._uiMask);
                this._uiMask.removeEventListener(egret.TouchEvent.TOUCH_TAP, this.onMaskTap, this);
            }
        }

        private onMaskTap(e: egret.TouchEvent) {
            this.dg_onMaskTap.boardcast();
        }

        public destroy(): void {
            super.destroy();
            this.cleanUiMask();
        }
    }
}