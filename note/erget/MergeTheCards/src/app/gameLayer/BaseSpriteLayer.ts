/**
 * 游戏层级
 */
namespace App {
    /**
     * 普通容器层
     */
    export class BaseSpriteLayer extends egret.DisplayObjectContainer implements IGameLayer {

        public constructor() {
            super();
            this.touchEnabled = false;
            this.scrollRect = egret.Rectangle.create();
            this.addEventListener(egret.Event.ADDED_TO_STAGE, this.onAdd, this);
            this.addEventListener(egret.Event.REMOVED_FROM_STAGE, this.onRemove, this);
        }

        private onAdd(){
            StageUtils.getStage().addEventListener(egret.Event.RESIZE, this.updateLayout, this);
        }
        private onRemove(){
            StageUtils.getStage().removeEventListener(egret.Event.RESIZE, this.updateLayout, this);
        }

        private updateLayout(e:egret.Event) {
            let stage = e.target;
            this.width = stage.width;
            this.height = stage.height;
            this.scrollRect.setTo(0, 0, this.width, this.height);
        }
    }
}