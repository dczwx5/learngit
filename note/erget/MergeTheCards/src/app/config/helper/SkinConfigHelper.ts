class SkinConfigHelper {
    private static getCfg(skinId: number): SkinConfig {
        return app.config.getConfig(SkinConfig)[skinId];
    }

    private static cardSkinMap: { [skinId: number]: ICardSkin[] } = {};
    private static getArrCardSkin(skinId: number): ICardSkin[] {
        if (!this.cardSkinMap[skinId]) {
            let arr = this.cardSkinMap[skinId] = [];
            let skinCfg = this.getCfg(skinId);
            let strArrColor = skinCfg.cardColor.split(',');
            let strArrImg = skinCfg.cardImg.split(',');
            for (let i = 0, l = strArrColor.length; i < l; i++) {
                arr.push({color: parseInt('0x' + strArrColor[i], 16), img:strArrImg[i]});
            }
        }
        return this.cardSkinMap[skinId];
    }

    public static getCardColor(skinId: number, cardCfg: CardConfig): number {
        return this.getArrCardSkin(skinId)[cardCfg.id - 1].color;
    }

    public static getCardImg(skinId: number, cardCfg: CardConfig): string {
        return this.getArrCardSkin(skinId)[cardCfg.id - 1].img;
    }

    private static arrLvColor:number[];
    public static getLvColor(skinId: number, lv: number): number {
        if(!this.arrLvColor){
            this.arrLvColor = [];
            let arrStrLvColor = this.getCfg(skinId).lvColor.split(',');
            for(let i = 0, l = arrStrLvColor.length; i < l; i++){
                this.arrLvColor.push(parseInt(`0x${arrStrLvColor[i]}`,16));
            }
        }
        return this.arrLvColor[lv - 1];
    }

    public static getScoreMultipleBgColor(skinId:number){
        return parseInt('0x' + this.getCfg(skinId).scoreMultipleBgColor, 16);
    }

    public static getGameBgColor(skinId:number){
        return parseInt('0x' + this.getCfg(skinId).gameBgColor, 16);
    }

    public static getRubbishCellForeColor(skinId:number){
        return parseInt('0x' + this.getCfg(skinId).rubbishBinForeColor, 16);
    }
    public static getRubbishCellBgColor(skinId:number){
        return parseInt('0x' + this.getCfg(skinId).rubbishBinBgColor, 16);
    }
}
interface ICardSkin {
    color: number;
    img: string
}