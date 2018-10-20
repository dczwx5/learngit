/**
 * 游戏层级
 */
namespace App {
    /**
     * EUI容器层
     */
    export class BaseEuiLayer extends eui.UILayer implements IGameLayer {
        public constructor(touchChildren: boolean = true, touchEnabled: boolean = false) {
            super();
            this.touchEnabled = touchEnabled;
            this.touchChildren = touchChildren;
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
        }
    }
}