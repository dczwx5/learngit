namespace gameframework {
export namespace framework {


/**
 * ...
 1.update/fixUpdate : 继承IUpdate/IFixUpdate的system, 会自动调用update与fixUpdate, 并不会往下自动调用(避免调用太多无用的update)
2.在OnAwake中addBean的节点, 会自动启动, 其他的需要自行调用awake与start:
如 : (在awake之外添加)
	addBean(b);
	b.awake();
	b.start();
* @author auto
*/
export class CAppStage extends CContainerLifeCycle implements IUpdate, IFixUpdate {
public static DEBUG:boolean;

constructor(){
	super();
}

public update(deltaTime:number) : void {
	let b:CLifeCycle;
	let beans:Array<CLifeCycle> = this.getBeans();
	let iCount:number = beans.length;
	for (let i:number = 0; i < iCount; i++) {
		b = beans[i];
		if (b.isStarted) {
			let iupdate:Function = b['update'];
			if (iupdate) {
				b['update'](deltaTime);
			}
		}
	}
}
public fixUpdate(fixTime:number) : void {
	let b:CLifeCycle;
	let beans:Array<CLifeCycle> = this.getBeans();
	let iCount:number = beans.length;
	for (let i:number = 0; i < iCount; i++) {
		b = beans[i];
		if (b.isStarted) {
			let iupdate:Function = b['fixUpdate'];
			if (iupdate) {
				b['fixUpdate'](fixTime);
			}
		}
	}
}

protected onAwake() : void {
	super.onAwake();
}
protected onStart() : boolean {
	return super.onStart();
}

protected onDestroy() : void {
	super.onDestroy();
}

public getSystem(clazz:new()=>CAppSystem) : CAppSystem {
	return this.getBean(clazz) as CAppSystem;
}
public addSystem(sys:CAppSystem) : boolean {
	if (this.addBean(sys)) {
		sys.stage = this;
	}
	return false;
}
public removeSystem(sys:CAppSystem) : boolean {
	return this.removeBean(sys);
}
/** 先不支持
public getAllViewBean() : Array<CViewBean> {
	let ret:Array<CViewBean> = new Array<CViewBean>();
	let allBeans:Array<CLifeCycle>  = this.getBeans();
	for each (let b:CLifeCycle in allBeans) {
		if (b is CAppSystem) {
			let sys:CAppSystem = b as CAppSystem;
			let viewsInSys:Array<CViewBean> = sys.getAllViewBean();
			for each (let view:CViewBean in viewsInSys) {
				ret.push(view);
			}
		}
	}

	return ret;
}
*/
}
}
}