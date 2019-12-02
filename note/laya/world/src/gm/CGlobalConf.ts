
export default class CGlobalConf {
    static Version:string = '0.3.7';
    static SceneX:number = 0;
    static FixCanvasX:number = 0;
    static CONFIG_URL: string = "conf/configs.json";

    // 获得基础x, 因为scene和canvas都经过偏移
    // 用于View
    // view的设计宽高和最大宽高一致, 828x1792
    static getViewOrginX() {
        return -54 + CGlobalConf.SceneX;
    }

    static GameWidth:number = 720;
    static GameHeight:number = 1230;

    static LOGIN_WALLET: number = 0;
    static LOGIN_NORMAL: number = 1;

    // path
    static ATLAS_PATH:string = "res/atlas/";
	static getAtlasPath(uiName:string) : string {
		return CGlobalConf.ATLAS_PATH + uiName + ".atlas";
	}
	static getPokerPath(pokerName:string) : string {
		return 'common/poker/' + pokerName + '.png';
	}
	static s_rootDir:string = 'sound/';
    static TYPE:string = '.wav';
    static getSoundPath(name:string) {
        return CGlobalConf.s_rootDir + name + CGlobalConf.TYPE;
	}
}  