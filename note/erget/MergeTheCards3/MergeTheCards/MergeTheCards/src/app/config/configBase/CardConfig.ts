class CardConfig{
	public id:number;
	public type:number;
	public value:number;
	public unlock:number;
	public weight:number;

	public attrs(){
		return ["id","type","value","unlock","weight"];
	}
}

window["CardConfig"] = CardConfig;
