import { gameframework } from "../../../hbcore/gameframework";

export class CComponent extends gameframework.framework.CContainerLifeCycle {
    protected m_bProcessByParent:boolean = true;

    destroy() {
        super.destroy();
    }
    protected onDestroy() {
        super.onDestroy();
    }
    protected onAwake() {
        super.onAwake(); // 在onAwake中addComponent
    }
    reset() {
        
    }
    start() : boolean {
        super.awake();
        return super.start();
    }
    protected onStart() : boolean {
        return super.onStart();
    }
    
    getComponent(cls:new(...args) => CComponent) : CComponent{
        return super.getBean(cls) as CComponent;
    }
    addComponent(obj:CComponent) {
        super.addBean(obj);
    }
    removeComponent(obj:CComponent) {
        super.removeBean(obj);
    }
    // 执行子组件的process不会带参数
    process(...args) {
        let beans = this.getBeans();
        if (beans) {
			for (let i:number = 0; i <beans.length; i++) {
				let o:CComponent = beans[i] as CComponent;
				if (o.m_bProcessByParent) {
                    o.process();
                }
            }
		}
    }
}