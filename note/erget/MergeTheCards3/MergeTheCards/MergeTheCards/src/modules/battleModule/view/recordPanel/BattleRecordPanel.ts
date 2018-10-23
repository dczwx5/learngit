class BattleRecordPanel extends eui.Component implements  eui.UIComponent {
	private lb_highScore:eui.Label;
	private lb_currScore:eui.Label;
	private lvBlock_curr:LvBlock;
	private lvBlock_next:LvBlock;
	private expPgBar:ExpPgBar;
	private rect_bg_scoreMultiple:eui.Rect;
	private lb_scoreMultiple:eui.Label;


	private _exp:number;

	private _skinId:number = 1;

	public constructor() {
		super();
		this.skinName = "BattleRecordPanelSkin";
	}

	public set currExp(exp:number){
		this._exp = exp;
		let currLv = LvConfigHelper.getLvByExp(exp);
		let currLvExp = LvConfigHelper.getExpByLv(currLv);
		let nextLvExp = LvConfigHelper.getExpByLv(currLv + 1);
		this.lvBlock_curr.lv = currLv;
		this.lvBlock_next.lv = currLv + 1;
		this.expPgBar.setProgress(exp - currLvExp, nextLvExp - currLvExp);
		this.expPgBar.displayColor = SkinConfigHelper.getLvColor(this._skinId, currLv);
	}

	public updateSkin(skinId:number){
		let lv = LvConfigHelper.getLvByExp(this._exp);
		this.expPgBar.displayColor = SkinConfigHelper.getLvColor(skinId, lv);
		this.lvBlock_curr.skinId = skinId;
		this.lvBlock_next.skinId = skinId;
		this.rect_bg_scoreMultiple.fillColor = SkinConfigHelper.getScoreMultipleBgColor(skinId);
	}

	public set highScore(value:number){
		this.lb_highScore.text = Utils.NumberToUnitStringUtil.convert(value);
	}
	public set currScore(value:number){
		this.lb_currScore.text = Utils.NumberToUnitStringUtil.convert(value);
	}

	public set scoreMultiple(value:number){
		this.lb_scoreMultiple.text = `X${value}`;
	}
	// public set currLv(value:number){
	// 	this.lvBlock_curr.lv = value;
	// 	this.lvBlock_next.lv = value+1;
	// }
	// public setLvExpProgress(curr:number, max:number){
	// 	this.pg_lv.maximum = max;
	// 	this.pg_lv.value = curr;
	// }
}

window['BattleRecordPanel'] = BattleRecordPanel;