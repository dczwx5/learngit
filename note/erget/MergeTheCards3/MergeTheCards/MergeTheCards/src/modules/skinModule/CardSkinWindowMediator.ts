class CardSkinWindowMediator extends ViewMediator{

    protected view:SkinWindow;

    private source:CardSkinItemData[] = [];
    private skinCollection:eui.ArrayCollection;

    private selectedItem:CardSkinItemData;

    constructor(){
        super();
        this.skinCollection = new eui.ArrayCollection([]);
    }

    protected onViewOpen() {
        let view = this.view;
        let skinMng =  this.getModel(PlayerModel).skinMng;
        view.btn_close.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onTap, this);
        view.dGroup_cardSkins.addEventListener(eui.ItemTapEvent.ITEM_TAP, this.onTapItem, this);
        skinMng.dg_SkinChanged.register(this.onSkinChanged, this);

        let source = this.source;
        source.length = 0;
        let cfg = app.config.getConfig(SkinConfig);
        let skinData:CardSkinItemData;
        let playerLv = this.getModel(PlayerModel).lv;
        let totalCount = 0;
        let unlockedCount = 0;
        for(let idx in cfg){
            skinData = {skinCfg:cfg[idx], playerLv:playerLv, isSelected:skinMng.skinId.toString() == idx};
            if(skinData.isSelected){
                this.selectedItem = skinData;
            }
            source.push(skinData);

            totalCount++;
            if(playerLv >= skinData.skinCfg.unlockLv){
                unlockedCount++;
            }
            view.lb_unlockedCount.text = `${unlockedCount}/${totalCount}`;
        }
        this.skinCollection.source = source;
        view.dGroup_cardSkins.dataProvider = this.skinCollection;
    }

    protected onViewClose() {

        let view = this.view;
        let skinMng =  this.getModel(PlayerModel).skinMng;
        view.btn_close.removeEventListener(egret.TouchEvent.TOUCH_TAP, this.onTap, this);
        view.dGroup_cardSkins.removeEventListener(eui.ItemTapEvent.ITEM_TAP, this.onTapItem, this);
        skinMng.dg_SkinChanged.unregister(this.onSkinChanged);

        view.dGroup_cardSkins.dataProvider = null;
        this.skinCollection.source = null;
        this.selectedItem = null;
    }

    private onTap(e:egret.TouchEvent){
        let view = this.view;
        switch (e.currentTarget){
            case view.btn_close:
                this.sendMsg(create(CardSkinModuleMsg.CloseCardSkinWindow));
                break;
        }
    }

    private onTapItem(e:eui.ItemTapEvent){
        let skinData = e.itemRenderer.data as CardSkinItemData;
        let skinCfgId = skinData.skinCfg.Id;
        if(skinData.playerLv >= skinData.skinCfg.unlockLv){
            let skinMng =  this.getModel(PlayerModel).skinMng;
            skinMng.skinId = skinCfgId;
            this.sendMsg(create(CardSkinModuleMsg.ChangeSkin).init({skinCfg:skinData.skinCfg}));
        }
    }

    private onSkinChanged(data:{skinId: number}){
        this.selectedItem.isSelected = false;
        this.skinCollection.replaceItemAt(this.selectedItem, this.skinCollection.getItemIndex(this.selectedItem));
        this.selectedItem = {isSelected:true, skinCfg:app.config.getConfig(SkinConfig)[data.skinId], playerLv:this.getModel(PlayerModel).lv};
        let idx:number;
        for(let i = 0, l = this.source.length; i < l; i++){
            if(this.source[i].skinCfg.Id == data.skinId){
                idx = i;
                break;
            }
        }
        this.skinCollection.replaceItemAt(this.selectedItem, idx);
    }

    protected get viewClass(): new()=>SkinWindow  {
        return SkinWindow;
    }

    protected get openViewMsg():  new()=>CardSkinModuleMsg.OpenCardSkinWindow  {
        return CardSkinModuleMsg.OpenCardSkinWindow;
    }

    protected get closeViewMsg():  new()=>CardSkinModuleMsg.CloseCardSkinWindow  {
        return CardSkinModuleMsg.CloseCardSkinWindow;
    }
}
