
import { ui } from "../../ui/layaMaxUI";

export default class CLoginView extends ui.LoginUI {

    constructor() {
        super();
    }

    onDestroy() {

    }

    onEnable() {
        this.mouseEnabled = true;
    }

    onDisable() {

    }

    get startBtn() : Laya.Button { return this.getChildByName('start') as Laya.Button; }

}