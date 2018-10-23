namespace App {
    export abstract class BaseTipManager implements ITipManager {

        /**
         * tipItem们的容器
         */
        protected area: egret.DisplayObjectContainer;

        protected tipItemList: BaseTipItem[];

        constructor() {
            this.tipItemList = [];
        }

        public showTip(tipItem: BaseTipItem): void{
            if(!tipItem){
                return;
            }
            tipItem.dg_onRestore.register(this.onTipItemRestore, this);
            this.tipItemList.push(tipItem);
            this.onShowTip(tipItem);
            tipItem.onShow();
        }

        protected activate(tipArea: egret.DisplayObjectContainer){
            this.area = tipArea;
        }
        protected deactivate(){
            this.area = null;
        }

        protected abstract onShowTip(tipItem: BaseTipItem);

        protected onTipItemRestore(tipItem: BaseTipItem) {
            this.tipItemList.splice(this.tipItemList.indexOf(tipItem), 1);
            tipItem.dg_onRestore.unregister(this.onTipItemRestore);
        }

        protected get gap(): number {
            return 3;
        }
    }
}