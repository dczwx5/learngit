class PublicConfig{
	public cardGroupCount:number;
	public maxRubbishCount:number;
	public maxHandCardCount:number;
	public maxGroupCardCount:number;

	public attrs(){
		return ["cardGroupCount","maxRubbishCount","maxHandCardCount","maxGroupCardCount"];
	}
}

window["PublicConfig"] = PublicConfig;
