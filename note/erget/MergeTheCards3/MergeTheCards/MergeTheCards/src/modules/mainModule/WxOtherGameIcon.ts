class WxOtherGameIcon extends eui.Component implements eui.UIComponent {

    private img_gameIcon: eui.Image;

    private isPlayingAnim: boolean = false;

    public constructor() {
        super();
    }

    protected childrenCreated(): void {
        super.childrenCreated();
        this.touchEnabled = true;
        this.touchChildren = false;
    }

    public setData(otherGameData: WxOtherGameData) {
        if (otherGameData) {
            this.img_gameIcon.source = otherGameData.image_small;
            this.visible = true;
            this.playAnim();
        } else {
            this.visible = false;
            this.stopAnim();
        }
    }

    public playAnim() {
        if (this.isPlayingAnim) {
            return;
        }

        let img = this.img_gameIcon;
        egret.Tween.removeTweens(img);
        img.rotation = 0;
        egret.Tween.get(img, { loop: true })
            .to({rotation: -15}, 50)
            .to({rotation: 0}, 50)
            .to({rotation: 15}, 50)
            .to({rotation: 0}, 50)
            .wait(5000);

        this.isPlayingAnim = true;
    }

    public stopAnim() {
        if (!this.isPlayingAnim) {
            return;
        }

        let img = this.img_gameIcon;
        egret.Tween.removeTweens(img);
        img.rotation = 0;

        this.isPlayingAnim = false;
    }
}

window['WxOtherGameIcon'] = WxOtherGameIcon;