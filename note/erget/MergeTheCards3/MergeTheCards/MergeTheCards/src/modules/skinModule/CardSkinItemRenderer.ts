class CardSkinItemRenderer extends eui.ItemRenderer implements eui.UIComponent {

    public static readonly STATUS_USING:string = "using";
    public static readonly STATUS_ENABLED:string = "enabled";
    public static readonly STATUS_DISABLED:string = "disabled";

    private readonly cardValueList = [64, 32, 16, 8, 4, 2];
    data: CardSkinItemData;

    private rect_mask: eui.Rect;
    private grp_cards: eui.Group;
    private lb_status:eui.Label;


    // public rect_bg: eui.Rect;

    // public icon_locked: eui.Image;
    // public rect_statusBg: eui.Rect;
    // public lb_status: eui.Label;

    public constructor() {
        super();
    }

    protected childrenCreated(): void {
        super.childrenCreated();
        this.touchChildren = false;
        this.touchEnabled = true;
        let cardValueList = this.cardValueList;
        let value: number;
        for (let i = 0, l = 6; i < l; i++) {
            value = cardValueList[i];
            this.getCardValueLbByIdx(i).text = value.toString();
        }
        this.grp_cards.mask = this.rect_mask;
    }

    protected dataChanged(): void {
        super.dataChanged();
        let data = this.data;
        if(data.playerLv >= data.skinCfg.unlockLv){
            if(data.isSelected){
                this.currentState = CardSkinItemRenderer.STATUS_USING;
            }else {
                this.currentState = CardSkinItemRenderer.STATUS_ENABLED;
            }
            let cardValueList = this.cardValueList;
            for (let i = 0, l = 6; i < l; i++) {
                this.getCardBgByIdx(i).fillColor = SkinConfigHelper.getCardColor(data.skinCfg.Id, CardConfigHelper.getNormalCardByValue(cardValueList[i]));
            }
        }else {
            this.currentState = CardSkinItemRenderer.STATUS_DISABLED;
            egret.setTimeout(()=>{
                this.lb_status.text = `${data.skinCfg.unlockLv}级解锁`;
            }, this, 20);
        }
    }

    private getCardBgByIdx(idx: number): eui.Rect {
        return this['rect_cardBg' + idx];
    }

    private getCardValueLbByIdx(idx: number): eui.Label {
        return this['lb_cardValue' + idx];
    }
}
window['CardSkinItemRenderer'] = CardSkinItemRenderer;