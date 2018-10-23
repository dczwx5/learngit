class BattleView extends App.BaseAutoSizeView {

	public battlePanel:BattleRecordPanel;
	public btn_refreshHandCard:RefreshBtn;
	public grp_handCards:eui.Group;
	public rubbishBin:RubbishBin;

	public rect_bg:eui.Rect;
	public btn_menu:eui.Image;
	public btn_help:eui.Image;


	public getCardGroup(idx:number):CardGroup{
		return this["cardGroup" + idx];
	}

	public constructor() {
		super("BattleViewSkin");
	}
	public get resources():string[]{
		return [];
	}

	// open(){
	// 	super.open();
	// 	for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
	// 		this.getCardGroup(i).activate();
	// 	}
	// }

	// close(){
	// 	super.close();
	// 	for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
	// 		this.getCardGroup(i).deactivate();
	// 	}
	// }

	protected onDestroy() {
	}
}
