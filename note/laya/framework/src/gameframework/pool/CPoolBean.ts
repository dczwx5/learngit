namespace gameframework {
export namespace pool {

/**
 * ...
 * @author
 */
export class CPoolBean extends framework.CBean {
	constructor(sign:string, type:new()=>any){
		super();
		this.m_type = type;
		this.m_sign = sign;
	}

	public get sign() : string {
		return this.m_sign;
	}
	public get type() : new()=>any {
		return this.m_type;
	}

	public createObject() : any {
		let item:any = Laya.Pool.getItemByClass(this.sign, this.type);
		let reset:Function = item["reset"];
		if (reset) {
			item.reset();
		}
		return item;
	}

	public recoverObject(item:any) : void {
		let dispose:Function = item["dispose"];
		if (dispose) {
			item.dispose();
		}
		Laya.Pool.recover(this.sign, item);
	}

	private m_sign:string;
	private m_type:new()=>any;
}

}
}