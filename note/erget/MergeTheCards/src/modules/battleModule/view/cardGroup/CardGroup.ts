class CardGroup extends eui.Component implements VL.DragDrop.IDropContainer{

	private readonly marginTop:number = 10;
	private readonly gap:number = 105;

	private _groupId:number;

	public img_dropArea:eui.Image;
	public img_border:eui.Image;
	private _isActive:boolean = false;

	private _currDropArea:egret.DisplayObject;

	dg_onDropIn: VL.Delegate<{ dragItem: Card; container: CardGroup }>;
	dropContainerCtrl: CardGroupDropCtrl;

	/**合并卡牌动画播放完毕*/
	dg_mergeCardComplete:VL.Delegate<{group:CardGroup}>;

	private _cardList:Card[];

	private _skinMng:SkinManager;

	public constructor() {
		super();
		this.skinName = "CardGroupSkin";
		this._cardList = [];
		this.touchChildren = false;
		this.touchEnabled = true;
		this.dg_onDropIn = new VL.Delegate<{ dragItem: Card; container: CardGroup }>();
		this.dropContainerCtrl = new CardGroupDropCtrl(this);
		this.dg_mergeCardComplete = new VL.Delegate<{group:CardGroup}>();
	}

	public activate(groupId:number, skinMng:SkinManager){
		if(!this.stage || this._isActive){
			return;
		}
		this._groupId = groupId;
		this._skinMng = skinMng;
		app.dragDropManager.regDropContainer(this);
		this.dg_onDropIn.register(this.onDropIn, this);
		this._isActive = true;
		this.updateDropArea();
	}
	public deactivate(){
		app.dragDropManager.unregDropContainer(this);
		this.dg_onDropIn.unregister(this.onDropIn);
		this._skinMng = null;
		this._isActive = false;
	}

	private onDropIn(data:{ dragItem: Card; container: CardGroup }){
		// this._currDropArea.filters = [];
		this.img_border.visible = false;
	}

	public appendCard(card:Card){
		card.y = this.marginTop + this._cardList.length * this.gap;
		card.x = this.width - card.width >> 1;
		this.addChild(card);
		this._cardList.push(card);
		this.updateDropArea();
	}

	public async mergeCard(distCardCfg:CardConfig, addScore:number){
		// app.log(`cards:`, this._cardList);
		// app.log(`mergeCardAnim:`, distCardCfg);

			// this.touchChildren = false;
			this.touchEnabled = false;
			let lastCard = this.lastCard;
			let lastButOneCard = this.lastButOneCard;
			this.flyScoreTip(lastCard, distCardCfg, addScore);
			await this.moveLastCardToLastButOneCard();
			// egret.Tween.get(lastCard)
             //    .to({y: lastCard.y - this.gap}, 150)
             //    .call(()=>{
					this._cardList.pop();
					lastCard.restore();

		return new Promise((resolve, reject) => {
					egret.Tween.get(lastButOneCard)
                        .to({scaleX:0.7, scaleY:0.7, x:lastButOneCard.x + lastButOneCard.width * 0.15, y:lastButOneCard.y + lastButOneCard.height * 0.15}, 150)
                        .call(()=>{
							lastButOneCard.cfg = distCardCfg;
						})
                        .to({scaleX:1, scaleY:1, x:this.width - lastButOneCard.width >> 1, y:lastButOneCard.y}, 150)
                        .call(()=>{
							// this.touchChildren = true;
							this.touchEnabled = true;
							this.updateDropArea();
							// this.dg_mergeCardComplete.boardcast({group:this});
							resolve();
						});
				});
		// } );
	}

	private flyScoreTip(card:Card, distCardCfg:CardConfig, addScore:number){
		let tip = create(FlyScoreTip).init(this._skinMng.getCardColor(distCardCfg), addScore);
		let x = this.width >> 1;
		let fromY = card.y + (card.height >> 1);
		let toY = fromY - (card.height >> 1);
		egret.Tween.get(tip)
			.set({alpha:1, x:x, y:fromY})
			.to({alpha:0, y:toY}, 600)
			.call(()=>{
				tip.restore();
			});
		this.addChild(tip);
	}

	/**
	 * 移除牌组后面几张牌
	 * @param count
	 */
	public removeCards(count:number){
		count = Math.min(this._cardList.length, count);
		for(let i = 0; i < count; i++){
			this._cardList.pop().restore();
		}
		this.updateDropArea();
	}

	public removeAllCards(){
		while(this._cardList.length > 0){
			this._cardList.pop().restore();
		}
		this.updateDropArea();
	}

	public async removeAllCardsAsync(){
		// this.touchChildren = false;
		this.touchEnabled = false;
		let lastButOneCard:Card;
		while(this._cardList.length > 1){
			await this.moveLastCardToLastButOneCard();
			lastButOneCard = this.lastButOneCard;
			this.flyScoreTip(lastButOneCard, lastButOneCard.cfg, lastButOneCard.cfg.value);
			this._cardList.splice(this._cardList.length - 2, 1);
			lastButOneCard.restore();
		}
		return new Promise((resolve)=>{
			let lastCard = this.lastCard;
			if(lastCard){
				egret.Tween.get(lastCard)
                    .to({x:this.width >> 1, y:lastCard.y + lastCard.height >> 1, scaleX:0, scaleY:0}, 300)
                    .call(()=>{
						this._cardList.pop();
						lastCard.parent.removeChild(lastCard);
						lastCard.scaleY = lastCard.scaleX = 1;
						lastCard.restore();
						this.updateDropArea();
						// this.touchChildren = true;
						this.touchEnabled = true;
						resolve();
					})
			}
			else {
				this.updateDropArea();
				// this.touchChildren = true;
				this.touchEnabled = true;
				resolve();
			}
		});
	}

	private async moveLastCardToLastButOneCard(){
		return new Promise((resolve)=>{
			let lastCard = this.lastCard;
			let lastButOneCard = this.lastButOneCard;
			egret.Tween.get(lastCard)
                .to({y: lastButOneCard.y}, 150)
				.call(()=>{
					resolve();
				});
		});
	}

	checkHover(touchTarget: egret.DisplayObject): boolean {
		let result = touchTarget == this._currDropArea;
		this.img_border.visible = result;
		// if(result){
		// 	this._currDropArea.filters = [DropEnableFilter.instance];
		// }else {
		// 	this._currDropArea.filters = [];
		// }
		return  result;
	}


	private updateDropArea(){
		this._currDropArea = this;
		// return;
		// if(this._cardList.length == 0){
		// 	this._currDropArea = this.img_dropArea;
		// }
		// else{
		// 	this._currDropArea = this.lastCard;
		// }
	}

	public get lastCard():Card{
		return this._cardList[this._cardList.length - 1];
	}

	public get lastButOneCard():Card{
		return this._cardList[this._cardList.length - 2];
	}


	public get groupId(): number {
		return this._groupId;
	}

	public get cardCount():number{
		return this._cardList.length;
	}
}

window["CardGroup"] = CardGroup;