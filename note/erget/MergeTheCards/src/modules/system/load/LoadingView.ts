class LoadingView extends App.BaseAutoSizeView{

    public readonly resources: string[] = ['preload'];

    private tf_progress:egret.TextField;

    public constructor() {
        super(null);
    }

    protected onInit(){
        super.onInit();

        let tf = this.tf_progress = new egret.TextField;
        tf.textColor = 0xff0000;
        tf.size = 40;
        this.addChild(tf);
    }

    public setProgress(curr:number, total:number){
        
        this.tf_progress.text = curr + ' / ' + total;
    }

    protected onDestroy() {
        this.removeChild(this.tf_progress); 
        this.tf_progress = null;
    }


}