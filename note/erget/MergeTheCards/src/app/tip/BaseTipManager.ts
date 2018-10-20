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

        public abstract showTip(tipItem: BaseTipItem): void;

        protected onTipItemRestore(tipItem: BaseTipItem) {
            this.tipItemList.splice(this.tipItemList.indexOf(tipItem), 1);
            tipItem.dg_onRestore.unregister(this.onTipItemRestore);
        }

        protected get gap(): number {
            return 3;
        }
    }
}