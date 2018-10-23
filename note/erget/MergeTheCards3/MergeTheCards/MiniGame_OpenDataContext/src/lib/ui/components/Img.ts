class Img extends egret.Bitmap{

    private imgLoader:egret.ImageLoader;
    private _url:string;

    private _isLoading:boolean;

    constructor(){
        super();
        this.imgLoader = new egret.ImageLoader();
    }

    public set url(url:string){
        this._url = url && url.length > 0 ? url : null;

        if(!this._url){
            this.$setTexture(null);
            return;
        }
        this.imgLoader.addEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
        this.imgLoader.addEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
        this._isLoading = true;
        this.imgLoader.load(url);
    }
    public get url():string{
        return this._url;
    }

    private onLoadComplete(e:egret.Event){
        this.imgLoader.removeEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
        this.imgLoader.removeEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
        let imageLoader = e.currentTarget;
        let texture = new egret.Texture();
        texture._setBitmapData(imageLoader.data);
        this.$setTexture(texture);
        this._isLoading = false;
    }

    private onError(e:egret.Event){
        this.imgLoader.removeEventListener(egret.Event.COMPLETE, this.onLoadComplete, this);
        this.imgLoader.removeEventListener(egret.IOErrorEvent.IO_ERROR, this.onError, this);
        this.$setTexture(null);
        this._isLoading = false;
    }

    public get isLoading():boolean{
        return this._isLoading;
    }
}