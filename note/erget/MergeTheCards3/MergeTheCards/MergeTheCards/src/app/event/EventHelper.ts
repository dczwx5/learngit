namespace App{
    export class EventHelper{
        public addTapEvent(target:egret.DisplayObject, handler:(e:egret.TouchEvent)=>void, thisObj:any){
            target.addEventListener(egret.TouchEvent.TOUCH_TAP, handler, thisObj);
        }
        public removeTapEvent(target:egret.DisplayObject, handler:(e:egret.TouchEvent)=>void, thisObj:any){
            target.removeEventListener(egret.TouchEvent.TOUCH_TAP, handler, thisObj);
        }
    }
}
let EventHelper = new App.EventHelper();