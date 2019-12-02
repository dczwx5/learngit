
import { ui } from "../../ui/layaMaxUI";

export default class CGamingView extends ui.Level1UI {

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

    get returnBtn() : Laya.Button { return this.getChildByName('return') as Laya.Button; }

}