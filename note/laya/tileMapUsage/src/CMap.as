
package
{
   import laya.events.Event;
    import laya.map.TiledMap;
    import laya.maths.Rectangle;
    import laya.utils.Browser;
    import laya.utils.Handler;
    import laya.webgl.WebGL;

    public class CMap
    {

        private var tMap:TiledMap;
        private var scaleValue:Number = 0;
        private var MapX:Number = 0;
        private var MapY:Number = 0;
        private var mLastMouseX:Number;
        private var mLastMouseY:Number;
        public function CMap()
        {
            //创建TiledMap实例
            tMap = new TiledMap();

            //创建Rectangle实例，视口区域
            var viewRect:Rectangle = new Rectangle(0, 0, Browser.width, Browser.height);
            //创建TiledMap地图，加载orthogonal.json后，执行回调方法onMapLoaded()
            tMap.createMap("res/TiledMap/orthogonal.json",viewRect, Handler.create(this,onMapLoaded));
        }


        private function onMapLoaded():void
        {
            //设置缩放中心点为视口的左上角
            tMap.setViewPortPivotByScale(0,0);
            //将原地图放大3倍          
            // tMap.scale = 3;

            Laya.stage.on(Event.RESIZE,this, this.resize);
            Laya.stage.on(Event.MOUSE_DOWN, this, this.mouseDown);
            Laya.stage.on(Event.MOUSE_UP, this, this.mouseUp);
            resize();
        }

        /**
         * 移动地图视口
         */
        private function mouseMove():void
        {
            var moveX:Number = MapX - (Laya.stage.mouseX - mLastMouseX);
            var moveY:Number = MapY - (Laya.stage.mouseY - mLastMouseY)
            //移动地图视口
            tMap.moveViewPort(moveX, moveY);
        }


        private function mouseUp():void
        {
            MapX = MapX - (Laya.stage.mouseX - mLastMouseX);
            MapY = MapY - (Laya.stage.mouseY - mLastMouseY);
            Laya.stage.off(Event.MOUSE_MOVE, this, this.mouseMove);
        }

        private function mouseDown():void
        {
            mLastMouseX = Laya.stage.mouseX;
            mLastMouseY = Laya.stage.mouseY;
            Laya.stage.on(Event.MOUSE_MOVE, this, this.mouseMove);
        }        


        /**
         *  改变视口大小
         *  重设地图视口区域
         */    
        private function resize():void
        {
            //改变视口大小
            tMap.changeViewPort(MapX, MapY, Browser.width, Browser.height);
        }
    }
}
