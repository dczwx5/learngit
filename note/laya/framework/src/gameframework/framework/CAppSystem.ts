namespace gameframework {
export namespace framework {

/**
 * ...
 * @author auto
 */
export class CAppSystem extends CContainerLifeCycle implements IUpdate {
constructor() {
	super();
}
protected onAwake() : void {
	super.onAwake();
}
protected onStart() : boolean {
	let ret:boolean = super.onStart();
	return ret;		
}

protected onDestroy() : void {
	this.m_stage = null;

	super.onDestroy();

	// this.m_viewList = null;
}

// view
// public getAllViewBean() : Array<CViewBean> {
// 	return m_viewList;
// }
public update(delta:number) : void {
	// if (m_viewList) {
	// 	for each (let view:CViewBean in m_viewList) {
	// 		if (view && view.isStarted) {
	// 			if (view.isDirty) {
	// 				view.updateData(delta);
	// 			}
	// 		}
	// 	}
	// }
}

public addBean(o:CLifeCycle) : boolean {
	let ret:boolean = super.addBean(o);
	if (ret) {
		(o as CBean).system = this;
	}

	// if (o is CViewBean) {
	// 	if (!m_viewList) {
	// 		m_viewList = new Array<CViewBean>();
	// 	}
	// 	m_viewList.push(o);
	// }
	
	return ret;
}
public removeBean(b:CLifeCycle) : boolean {
	let ret:boolean = super.removeBean(b);
	// if (b is CViewBean) {
	// 	let idx:int = m_viewList.indexOf(b as CViewBean);
	// 	m_viewList.splice(idx, 1);
	// }
	return ret;
}

public get stage() : CAppStage {
	return this.m_stage;
}
public set stage(v:CAppStage) {
	this.m_stage = v;
}

private m_stage:CAppStage;

// private let m_viewList:Array<CViewBean>;

}
}
}