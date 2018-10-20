namespace App {
    export abstract class BaseAutoSizeView extends BaseEuiView {

        //皮肤里的组件
        /**
         * UI缩放区域， 采用全显示适配策略
         */
        public grp_content: eui.Group;
        /**
         * 底图，采用图片最窄配屏幕最宽缩放策略
         */
        public img_bg: egret.DisplayObject;

        protected contentScaleMode: VL.ScaleMode.IScaleMode;
        protected bgScaleMode: VL.ScaleMode.IScaleMode;

        constructor(skinName:string, $parent: egret.DisplayObjectContainer = GameLayers.UI_Main) {
            super(skinName, $parent);
        }

        protected onInit(){
            this.initScaleMode();
        }

        protected initScaleMode() {
            this.contentScaleMode = VL.ScaleMode.SHOW_ALL_FILL;
            this.bgScaleMode = VL.ScaleMode.NO_BORDER;
        }

        protected updateLayout() {
            super.updateLayout();
            if (this.grp_content && this.contentScaleMode) {
                this.contentScaleMode.adapt(this.grp_content, this);
            }
            if (this.bgScaleMode && this.img_bg) {
                this.bgScaleMode.adapt(this.img_bg, this);
            }
            // app.log(`w:${this.width}  h:${this.height}`);
            // if(this.grp_content){
            //     app.log(`contentW:${this.grp_content.width}  contentH:${this.grp_content.height}`);
            // }
            // if(this.img_bg){
            //     app.log(`bgW:${this.img_bg.width}  bgH:${this.img_bg.height}`);
            // }
        }

    }
}