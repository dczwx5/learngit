class CardGroupDropCtrl extends DropCardContainerCtrl{

    protected checkEnableDrop(dragItem: Card): boolean {
        if(this.cardGroup.cardCount < PublicConfigHelper.MAX_GROUP_CARDS_COUNT){
            return true;
        } else{
            return this.cardGroup.lastCard.cfg.value == dragItem.cfg.value || dragItem.cfg.type == Enum_CardType.UNIVERSAL;
        }
    }

    public get cardGroup():CardGroup{
        return this._container as CardGroup;
    }
}
