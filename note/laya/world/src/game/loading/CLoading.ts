import { ui } from "../../ui/layaMaxUI";
import Event = Laya.Event;
import SingletonError from "../../hbcore/error/SingletonError";

export default class CLoading extends ui.loading.LoadingUI {
    private static s_instance: CLoading;
    static get instance(): CLoading {
        if (null == this.s_instance) {
            this.s_instance = new CLoading();
        }
        return this.s_instance;
    }

    private constructor() {
        super();
    }


    show(tips:string = null) {
        this.m_tips = tips;
        Laya.stage.addChild(this);

        console.log('loading show');
    }

    hide() {
        this.removeSelf();
    }

    onDisable() {
       
        console.log('loading hide');
    }

    onEnable() {
        this.x = (Laya.stage.width-this.width)*0.5;
    }

    private m_tips:string;
}