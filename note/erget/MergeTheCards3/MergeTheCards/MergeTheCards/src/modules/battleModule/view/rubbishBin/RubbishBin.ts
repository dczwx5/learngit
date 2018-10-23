class RubbishBin extends eui.Component implements  eui.UIComponent, VL.DragDrop.IDropContainer {

	dg_onDropIn: VL.Delegate<{ dragItem: Card; container:RubbishBin }>;
	dropContainerCtrl: DropRubbishCtrl;

	private _isReady:boolean = false;

	private _rubbishCount:number = 0;

	private rect_mask:eui.Rect;
	private img_border:eui.Image;
	public grp_cell:eui.Group;

	private _clearCellChance:number;

	private _skinId:number = 1;

	public constructor() {
		super();
		this.skinName = "RubbishBinSkin";
		this.touchChildren = false;
		this.touchEnabled = true;
		this.dg_onDropIn = new VL.Delegate<{ dragItem: Card, container: RubbishBin }>();
		this.dropContainerCtrl = new DropRubbishCtrl(this);
	}

	protected childrenCreated():void{
		super.childrenCreated();
		this._isReady = true;
		this.updateShow();
		this.updateSkin();
		this.grp_cell.mask = this.rect_mask;
	}

	activate(skinId:number){
		app.dragDropManager.regDropContainer(this);
		this.dg_onDropIn.register(this.onDropIn, this);
		this._skinId = skinId;
		this.updateSkin();
	}
	deactivate(){
		app.dragDropManager.regDropContainer(this);
		this.dg_onDropIn.unregister(this.onDropIn);
	}

	checkHover(touchTarget: egret.DisplayObject): boolean {
		let result = touchTarget == this;
		this.img_border.visible = result;
		// if(result){
		// 	this.filters = [DropEnableFilter.instance];
		// }else {
		// 	this.filters = [];
		// }
		return  result;
	}

	private onDropIn(){
		this.img_border.visible = false;
		// this.filters = [];
	}

	private getRubbishCell(idx:number):RubbishBinCell{
		return this['cell'+idx];
	}

	private _needUpdate:boolean = false;
	private updateShow(){
		if(!this._isReady){
			return;
		}
		if(!this._needUpdate){
			this._needUpdate = true;
			egret.callLater(()=>{
				const max = PublicConfigHelper.MAX_RUBBISH_COUNT;
				let cell:RubbishBinCell;
				for(let i = 0; i < max; i++){
					cell = this.getRubbishCell(i);
					cell.isEmpty = i >= this.rubbishCount;
					cell.enableClear = i < this.clearCellChance;
				}
				this._needUpdate = false;
			}, this);
		}
	}

	private updateSkin(){
		if(this._isReady){
			const max = PublicConfigHelper.MAX_RUBBISH_COUNT;
			for(let i = 0; i < max; i++){
				this.getRubbishCell(i).skinId = this._skinId;
			}
		}
	}

	set rubbishCount(value: number) {
		const max = PublicConfigHelper.MAX_RUBBISH_COUNT;
		value = Math.min(max, Math.max(value, 0));
		this._rubbishCount = value;
		this.updateShow();
	}

	get rubbishCount(): number {
		return this._rubbishCount;
	}

	get clearCellChance(): number {
		return this._clearCellChance;
	}

	set clearCellChance(value: number) {
		const max = PublicConfigHelper.MAX_RUBBISH_COUNT;
		value = Math.min(max, Math.max(value, 0));
		this._clearCellChance = value;
		this.updateShow();
	}
}

window['RubbishBin'] = RubbishBin;