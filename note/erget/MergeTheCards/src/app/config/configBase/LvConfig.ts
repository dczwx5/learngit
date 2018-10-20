class LvConfig{
	public id:number;
	public lv:number;
	public needExp:number;

	public attrs(){
		return ["id","lv","needExp"];
	}
}

window["LvConfig"] = LvConfig;
