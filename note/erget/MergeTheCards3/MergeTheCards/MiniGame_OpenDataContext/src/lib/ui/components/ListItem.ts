abstract class ListItem extends egret.DisplayObjectContainer{

    protected _index:number;
    protected _data:any;

    public abstract onRemoved();

    protected abstract onDataChanged();

    public get data():any{
        return this._data;
    }

    public set data(value:any){
        this._data = value;
        this.onDataChanged();
    }

    public get index(): number {
        return this._index;
    }

    public set index(value: number) {
        this._index = value;
    }
}
