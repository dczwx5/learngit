class SkinConfig{
	public Id:number;
	public lvColor:string;
	public cardImg:string;
	public cardColor:string;
	public gameBgColor:string;
	public rubbishBinBgColor:string;
	public rubbishBinForeColor:string;
	public scoreMultipleBgColor:string;
	public cardForeColor:string;

	public attrs(){
		return ["Id","lvColor","cardImg","cardColor","gameBgColor","rubbishBinBgColor","rubbishBinForeColor","scoreMultipleBgColor","cardForeColor"];
	}
}

window["SkinConfig"] = SkinConfig;
