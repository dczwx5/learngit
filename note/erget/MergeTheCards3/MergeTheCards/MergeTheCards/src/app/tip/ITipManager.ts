namespace App {
    export interface ITipManager {
        /**
         * 显示一条tip
         */
        showTip(tipItem: BaseTipItem): void;
    }
}