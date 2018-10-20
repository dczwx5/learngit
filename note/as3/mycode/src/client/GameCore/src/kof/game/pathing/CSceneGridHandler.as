//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.pathing {

import kof.framework.CAbstractHandler;

/**
 * 场景格子数据逻辑
 * - 格子坐标|像素坐标转换
 *
 * @author tanjiazhang
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CSceneGridHandler extends CAbstractHandler {

}
}
//
//package kof.game.scene.grid {
//
//import flash.geom.Point;
//
//import kof.framework.CAbstractHandler;
//import kof.framework.CAppSystem;
//import kof.game.scene.grid.astar.CANode;
//import kof.game.scene.grid.astar.CAStar;
//import kof.game.scene.grid.astar.CAStar2;
//import kof.game.scene.grid.astar.CGridData;
//import kof.game.scene.grid.astar.CNode;
//import kof.game.scene.grid.util.CDoubleBufferArray;
//
///**
// * 场景格子数据逻辑
// * - 格子坐标|像素坐标转换
// *
// * @author tanjiazhang
// * @author Jeremy (jeremy@qifun.com)
// */
//public final class CSceneGridHandler extends CAbstractHandler {
//
//    public static const GRID_WIDTH:uint = 86;
//    public static const HexagonSize:int = 50;
//    public static const Sqrt:Number = 1.73205;  // 根号3
//    public static const HexDistanceUint:Number = HexagonSize * Sqrt * 0.5;
//
//    // public static var USING_NEW_PATH_FINDING:Boolean = true;
//    private static var new_path_result:CDoubleBufferArray;
//
//    // 是否使用正方形格子
//    public static const isUseSquare:Boolean = true;
//
//    public static var tileUtil:ITileUtil;
//
//    private static var h00:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
//    private static var h10:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
//    private static var h01:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
//    private static var h11:Vector.<Number> = Vector.<Number>([1.0, 1.0, 1.0, 1.0]);
//
//    private var _astar:CAStar;
//    private var _astar2:CAStar2;
//    private var _curMapGrid:CGridData;
//    private var _hasWater:Boolean = false;
//    private var _hasReflection:Boolean = false;
//
//    private var _vector:Point = new Point();
//    private var _tempVector:Point = new Point();
//
//    /**
//     * Creates a new CSceneGridHandler.
//     */
//    public function CSceneGridHandler() {
//        super();
//    }
//
//    override protected function onSetup():Boolean {
//        _astar2 = new CAStar2();
//        _curMapGrid = new CGridData(10, 10); // pre-set data.
//
//        if (isUseSquare)
//            tileUtil = new CSquareTile(this);
//        else
//            tileUtil = new CHexTile(this, HexagonSize);
//
//        return true;
//    }
//
//    override protected function enterSystem(system:CAppSystem):void {
//        _astar = system.getBean(CAStar) as CAStar;
//    }
//
//    public function reset(mapInfo:Object):void {
//        _hasWater = false;
//        //create default grids
//        var size:Point = tileUtil.pixelToSize(mapInfo.width, mapInfo.height);
//
//
//        _curMapGrid = new CGridData(size.x, size.y);
//        var blocks:Array = mapInfo["blockPoints"];
//        if (blocks) {
//            for each(var item:Object in blocks) _curMapGrid.setWalkable(item.x, item.y, false);
//        }
//    }
//
//    public function resetBlockData(dataInfo:Object):void {
//        if (dataInfo.hasOwnProperty("lightsData")) {
//            var lights:Array = dataInfo.lightsData;
//            for each(var lightData:Object in lights) {
//                _curMapGrid.setLight(lightData.position.x, lightData.position.y, lightData.color, lightData.contrast);
//            }
//        }
//    }
//
//    // 暂时写这，到时需要写到：PathFinding中
//    private static function floydVector(target:Point, n1:CANode, n2:CANode):void {
//        target.x = n1.x - n2.x;
//        target.y = n1.y - n2.y;
//    }
//
//    private static function floydVector1(target:Point, n1:CNode, n2:CNode):void {
//        target.x = n1.x - n2.x;
//        target.y = n1.y - n2.y;
//    }
//
//    /**
//     * 寻路
//     *
//     * @param end 结束索引点
//     * @param start 开始索引点
//     * @return
//     */
//    public function findPath(start:Point, end:Point):CDoubleBufferArray {
//        _curMapGrid.clearState();
//        var arr:Array = _astar2.find(_curMapGrid, start.x, start.y, end.x, end.y);
//
//        if (!arr || arr.length == 0) {
//            return null;
//        }
//
//        var i:int, len:int;
//        if (CAStar.compressed) {
//            // compress
//            if (arr.length > 2) {
//                floydVector1(_vector, arr[0], arr[1]); // sub vector.xy, arr[0].xy, arr[1].xy
//                _vector.normalize(1);
//                for (i = 2; i < arr.length; ++i) {
//                    floydVector1(_tempVector, arr[i - 1], arr[i]); // sub tempVector.xy, grid[i-1].xy, grid[i].xy
//                    _tempVector.normalize(1);
//                    if (_vector.equals(_tempVector)) {
//                        arr.splice(i - 1, 1);
//                        --i;
//                    } else {
//                        _vector.copyFrom(_tempVector);
//                    }
//                }
//            }
//        }
//
//        if (!new_path_result) {
//            new_path_result = new CDoubleBufferArray(arr.length);
//        }
//
//        new_path_result.pushArrToBackBuffer(arr);
//        return new_path_result;
//    }
//
//    /**
//     * 寻路,需要传入resultBuffer
//     * @param end 结束索引点
//     * @param start 开始索引点
//     * @param resultBuffer
//     */
//    public function findPath2(start:Point, end:Point, resultBuffer:CDoubleBufferArray):CDoubleBufferArray {
//        _curMapGrid.clearState();
//        var arr:Array = _astar2.find(_curMapGrid, start.x, start.y, end.x, end.y);
//
//        if (!arr || arr.length == 0) {
//            return null;
//        }
//        var i:int, len:int;
//        if (CAStar.compressed) {
//            // compress
//            if (arr.length > 2) {
//                floydVector1(_vector, arr[0], arr[1]); // sub vector.xy, arr[0].xy, arr[1].xy
//                _vector.normalize(1);
//                for (i = 2; i < arr.length; ++i) {
//                    floydVector1(_tempVector, arr[i - 1], arr[i]); // sub tempVector.xy, grid[i-1].xy, grid[i].xy
//                    _tempVector.normalize(1);
//                    if (_vector.equals(_tempVector)) {
//                        arr.splice(i - 1, 1);
//                        --i;
//                    } else {
//                        _vector.copyFrom(_tempVector);
//                    }
//                }
//            }
//        }
//
//        if (!resultBuffer) {
//            resultBuffer = new CDoubleBufferArray(arr.length);
//        }
//        resultBuffer.pushArrToBackBuffer(arr);
//        resultBuffer.swap();
//        return resultBuffer;
//    }
//
//    /**
//     * 计算一条优化的路径，注意，该方法每次执行优化算法并重新创建
//     * 同时该方法会产生一个速率调整因子
//     *
//     * @return 路径的Point数组
//     */
//    public function createOptPathPoints():CDoubleBufferArray {
//        new_path_result.swap();
//        return new_path_result;
//    }
//
//    private function countRawPathLength():Number {
//        var dRaw:Number = 0;
//        //使用简单的算法，服务端格子按照匀速计算（忽略纵向压缩）
//        if (isUseSquare) {
//            dRaw = (_astar.rawPath.frontLength - 1) * CSquareTile.TILE_WITH;
//        }
//        else {
//            dRaw = (_astar.rawPath.frontLength - 1) * GRID_WIDTH;
//        }
//        return dRaw;
//    }
//
//    /**
//     * 获取原始寻路路径，注意，返回的对象为内部复用对象，外部不应该修改
//     */
//    final public function get rawPath():CDoubleBufferArray {
//        return _astar.rawPath;
//    }
//
//    final public function get compressedPath():CDoubleBufferArray {
//        return _astar.compressedPath;
//    }
//
//    public function get water():Boolean {
//        return this._hasWater;
//    }
//
//    public function get reflect():Boolean {
//        return this._hasReflection;
//    }
//
//    public function set water(value:Boolean):void {
//        this._hasWater = value;
//    }
//
//    public function set reflect(value:Boolean):void {
//        this._hasReflection = value;
//    }
//
//    /**
//     * 该坐标是不是可以通行
//     * @param px 格子坐标x
//     * @param py 格子坐标y
//     * @return
//     *
//     */
//    public function isWalk(px:int, py:int):Boolean {
//        var node:CNode = _curMapGrid.getNode(px, py);
//
//        var walkable:Boolean = node && node.walkable;
//        return walkable;
//
//        // 下面的潜规则暂时没看懂
////			// HACK: 避免最右侧边界可走的情况
////			if (walkable && px == _curMapGrid.numCols - 1)
////				return _curMapGrid.getNode(px - 1, py).walkable;
////			else
////				return walkable;
//    }
//
//    //输入格子,返回像素
//    public function getNearestWalkPoint(x:int, y:int):Point {
//        var node:CNode = _curMapGrid.getNode(x, y);
//        if (!node) return null;
//        return node.nearestWalkablePoint;
//    }
//
//    //xy是格子，point是像素
//    public function setNearestWalkPoint(x:int, y:int, point:Point):void {
//        var node:CNode = _curMapGrid.getNode(x, y);
//        if (!node) return;
//        node.nearestWalkablePoint = point;
//    }
//
//    public function isReflection(px:int, py:int):Boolean {
//        return true;
//        var node:CNode = _curMapGrid.getNode(px, py);
//
//        var reflection:Boolean = node && node.reflection;
//
//        // HACK: 避免最右侧边界可走的情况
//        if (reflection && px == _curMapGrid.numCols - 1)
//            return _curMapGrid.getNode(px - 1, py).reflection;
//        else
//            return reflection;
//    }
//
//
//    public function getWaterHeight(x:int, y:int):Number {
//        var yFrac:Number = tileUtil.toPixelY(x, y);
//        var yInt:int = int(Math.floor(yFrac));
//        var xFrac:Number = tileUtil.toPixelX(x, y);
//        var xInt:int = int(Math.floor(xFrac));
//        xFrac -= xInt;
//        yFrac -= yInt;
//        var node00:CNode = _curMapGrid.getNode(xInt, yInt);
//        var node10:CNode = _curMapGrid.getNode(xInt + 1, yInt);
//        var node01:CNode = _curMapGrid.getNode(xInt, yInt + 1);
//        var node11:CNode = _curMapGrid.getNode(xInt + 1, yInt + 1);
//        var h00:Number = node00 ? node00.waterHeight : 0.0;
//        var h10:Number = node10 ? node10.waterHeight : 0.0;
//        var h01:Number = node01 ? node01.waterHeight : 0.0;
//        var h11:Number = node11 ? node11.waterHeight : 0.0;
//        h00 = h00 * (1.0 - xFrac) + h10 * xFrac;
//        h01 = h01 * (1.0 - xFrac) + h11 * xFrac;
//        return h00 * (1.0 - yFrac) + h01 * yFrac;
//    }
//
//    public function getLightColor(x:int, y:int):Vector.<Number> {
//        var yFrac:Number = tileUtil.toPixelY(x, y);
//        var yInt:int = int(Math.floor(yFrac));
//        var xFrac:Number = tileUtil.toPixelX(x, y);
//        var xInt:int = int(Math.floor(xFrac));
//        xFrac -= xInt;
//        yFrac -= yInt;
//        var node00:CNode = _curMapGrid.getNode(xInt, yInt);
//        var node10:CNode = _curMapGrid.getNode(xInt + 1, yInt);
//        var node01:CNode = _curMapGrid.getNode(xInt, yInt + 1);
//        var node11:CNode = _curMapGrid.getNode(xInt + 1, yInt + 1);
//
//        var i:int = 0;
//        if (node00) {
//            for (i = 0; i < 4; i++) h00[i] = node00.lightColor[i];
//        }
//        else {
//            h00[0] = h00[1] = h00[2] = h00[3] = 1.0;
//        }
//
//        if (node10) {
//            for (i = 0; i < 4; i++) h10[i] = node10.lightColor[i];
//        }
//        else {
//            h10[0] = h10[1] = h10[2] = h10[3] = 1.0;
//        }
//
//        if (node01) {
//            for (i = 0; i < 4; i++) h01[i] = node01.lightColor[i];
//        }
//        else {
//            h01[0] = h01[1] = h01[2] = h01[3] = 1.0;
//        }
//
//        if (node11) {
//            for (i = 0; i < 4; i++) h11[i] = node11.lightColor[i];
//        }
//        else {
//            h11[0] = h11[1] = h11[2] = h11[3] = 1.0;
//        }
//
//        for (i = 0; i < 4; i++) h00[i] = h00[i] * (1.0 - xFrac) + h10[i] * xFrac;
//        for (i = 0; i < 4; i++) h01[i] = h01[i] * (1.0 - xFrac) + h11[i] * xFrac;
//        for (i = 0; i < 4; i++) h00[i] = h00[i] * (1.0 - yFrac) + h01[i] * yFrac;
//
//        return h00;
//    }
//
//    public function getLightContrast(x:int, y:int):Number {
//        var yFrac:Number = tileUtil.toPixelY(x, y);
//        var yInt:int = int(Math.floor(yFrac));
//        var xFrac:Number = tileUtil.toPixelX(x, y);
//        var xInt:int = int(Math.floor(xFrac));
//        xFrac -= xInt;
//        yFrac -= yInt;
//        var node00:CNode = _curMapGrid.getNode(xInt, yInt);
//        var node10:CNode = _curMapGrid.getNode(xInt + 1, yInt);
//        var node01:CNode = _curMapGrid.getNode(xInt, yInt + 1);
//        var node11:CNode = _curMapGrid.getNode(xInt + 1, yInt + 1);
//        var h00:Number = node00 ? node00.lightContrast : 0.0;
//        var h10:Number = node10 ? node10.lightContrast : 0.0;
//        var h01:Number = node01 ? node01.lightContrast : 0.0;
//        var h11:Number = node11 ? node11.lightContrast : 0.0;
//        h00 = h00 * (1.0 - xFrac) + h10 * xFrac;
//        h01 = h01 * (1.0 - xFrac) + h11 * xFrac;
//        return h00 * (1.0 - yFrac) + h01 * yFrac;
//    }
//
//    /**
//     * 该坐标是不是可以通行
//     * @param x 像素坐标x
//     * @param y 像素坐标y
//     * @return
//     *
//     */
//    private var _P:Point = new Point();
//
//    public function isWalkBy(x:int, y:int):Boolean {
//        if (x < 0)
//            return false;
//
//        var point:Point = pixel2Grid(x, y, _P);
//        return isWalk(point.x, point.y);
//    }
//
//
//    public static function pixel2Grid(x:int, y:int, point1:Point = null):Point {
//        return tileUtil.toGrid(x, y, point1);
//    }
//
//    public function getPosition(x:int, y:int, point:Point):Point {
//        return pixel2Grid(x, y, point);
//    }
//
//    /**
//     * startX,Y, endX,Y都是格子坐标
//     * */
//    public function distance(startX:Number, startY:Number, endX:Number, endY:Number):Number {
//        return tileUtil.distance(startX, startY, endX, endY);
//    }
//
//    public function distanceByPoint(startPoint:Point, endPoint:Point):Number {
//        return tileUtil.distance(startPoint.x, startPoint.y, endPoint.x, endPoint.y);
//    }
//
//    /**
//     * 把格子转成像素
//     * @param x//对应的寻路数据的x索引
//     * @param y//对应的寻路数据的y索引
//     * @param point
//     *
//     */
//    public function getRealPosition(x:int, y:int, point:Point):Point {
//        return grid2Pixel(x, y, point);
//    }
//
//    public static function grid2Pixel(x:int, y:int, result1:Point = null):Point {
//        return tileUtil.toPixel(x, y, result1);
//    }
//
//    public function transform(a:Array):Array {
//        for each (var obj:Point in a) {
//            getRealPosition(obj.x, obj.y, obj);
//        }
//        return a;
//    }
//
//    /**
//     * 获取离不可走点最近的可走点，以开始点和结束点为参照算出
//     * @param startPos
//     * @param endPos
//     * @return
//     *
//     */
//    public function getPointByBlockPoint(startPos:Point, endPos:Point, speed:Number):Point {
////			var dis:Number = Point.distance(startPos,endPos);
////			speed = HexagonSize*17/speed;
////			var timer:uint = uint(dis/speed);
////			var list:Vector.<Point> = DisplayUtil.getLine(startPos,endPos,timer);
////			var pos:Point;
////			for(var i1:int = list.length-1; i1 >= 0; i1--)
////			{
////				pos = list[i1] as Point;
////
////				var isWalk:Boolean = isWalkBy(pos.x,pos.y);
////				if(isWalk)
////					return pos;
////			}
////			return null;
//
//        return tileUtil.getPointByBlockPoint(startPos, endPos, speed);
//    }
//
//    /** @return maybe null.*/
//    public function randomSpecialRadiusWalkablePoint(centerPos:Point, radius:Number, pixelCoordinate:Boolean = true):Point {
//        var randomRadius:Number = Math.random() * radius;
//        var angle:Number = Math.random() * (2 * Math.PI);
//        var offsetX:Number = Math.cos(angle) * randomRadius;
//        var offsetY:Number = Math.sin(angle) * randomRadius;
//        var result:Point;
//        if (pixelCoordinate) {
//            centerPos.setTo(centerPos.x + offsetX, centerPos.y + offsetY);
//
//            result = pixel2Grid(centerPos.x, centerPos.y); // 格子坐标
//        }
//        else {
//            result = new Point(centerPos.x + offsetX, centerPos.y + offsetY); // // 格子坐标
//        }
//        if (!isWalk(result.x, result.y)) // 格子坐标
//        {
//            result = calculateNearestWalkablePoint(result); // 像素坐标
//            if (!pixelCoordinate) {
//                result = pixel2Grid(result.x, result.y, result); // 像素转格子坐标
//            }
//        }
//        else {
//            if (pixelCoordinate) {
//                result = grid2Pixel(result.x, result.y, result); // 格子转像素坐标
//            }
//        }
//        return result;
//    }
//
//    public function calculateNearestWalkablePoint(centerGridPoint:Point):Point {
////			var offset:int = 1;
////			var cx:int = centerGridPoint.x;
////			var cy:int = centerGridPoint.y;
////			var leftTopX:int;
////			var leftTopY:int;
////			var rightBottomX:int;
////			var rightBottomY:int;
////			var numRows:int = _curMapGrid.numRows;
////			var numCols:int = _curMapGrid.numCols;
////			var i:int;
////			while(offset < 6){
////				leftTopX = Math.max(0, cx - offset);
////				leftTopY = Math.max(0, cy - offset);
////				rightBottomX = Math.min(numCols, cx + offset);
////				rightBottomY = Math.min(numRows, cy + offset);
////
////				//下
////				for(i = leftTopX + 1; i <= rightBottomX; ++i){
////					if(isWalk(i, rightBottomY)){
////						return grid2Pixel(i, rightBottomY);
////					}
////				}
////
////				//左
////				for(i = leftTopY + 1; i <= rightBottomY; ++i){
////					if(isWalk(leftTopX, i)){
////						return grid2Pixel(leftTopX, i);
////					}
////				}
////
////				//右
////				for(i = leftTopY; i < rightBottomY; ++i){
////					if(isWalk(rightBottomX, i)){
////						return grid2Pixel(rightBottomX, i);
////					}
////				}
////
////				//上
////				for(i = leftTopX; i < rightBottomX; ++i){
////					if(isWalk(i, leftTopY)){
////						return grid2Pixel(i, leftTopY);
////					}
////				}
////
////				++offset;
////			}
////			return null;
//
//        return tileUtil.calculateNearestWalkablePoint(centerGridPoint, _curMapGrid, isWalk);
//    }
//
//    /**
//     *找出两点间所成线段，其穿过的所有hex点，并 callback，根据callback的返回值决定是否执行下一个点
//     * 如果遍历过程没有遇到handler返回false，则本函数最终返回true
//     * @param fromX
//     * @param fromY
//     * @param toX
//     * @param toY
//     * @param handler function(x, y):Boolean 若返回false，则遍历过程立刻停止，并返回false
//     * @param useEndpoint
//     *
//     */
//    public static function lineForeach(fromX:int, fromY:int, toX:int, toY:int, handler:Function, useEndpoint:Boolean = true):Boolean {
//        //find hexpoint by pixel line
////			var from:Point = grid2Pixel(fromX, fromY, new Point());
////			var to:Point = grid2Pixel(toX, toY, new Point());
////
////			//prepare data to calc every prosible point
////			var lenX:Number = Math.abs(from.x - to.x);
////			var lenY:Number = Math.abs(from.y - to.y);
////			var lenTotal:Number = Math.sqrt(lenX*lenX+lenY*lenY);
////			var rateX:Number = to.x>=from.x?lenX/lenTotal:-lenX/lenTotal;
////			var rateY:Number = to.y>=from.y?lenY/lenTotal:-lenY/lenTotal;
////
////			if(useEndpoint) if(!handler(fromX, fromY)) return false;
////			var lastPoint:Point = new Point();
////			to.setTo(toX, toY);
//////			var debug:Array = [];
//////			debug.push(new Point(lastPoint.x, lastPoint.y));
////			//该方法不是很高效，采用每隔一段距离就检测一次的方式来寻找所有被经过的点
////			for(var len:Number=HexDistanceUInt;;)
////			{
////				var nextPoint:Point = new Point();
////				pixel2Grid(from.x+len*rateX, from.y+len*rateY, nextPoint);
////				if(!lastPoint.equals(nextPoint) && !to.equals(nextPoint))//meet a new hex point
////				{
////					lastPoint.copyFrom(nextPoint);
//////					debug.push(new Point(nextPoint.x, nextPoint.y));
////					if(!handler(nextPoint.x, nextPoint.y)) return false;
////				}
////				if(len>=lenTotal) break;//完成
////				len += HexDistanceUInt;
////			}
////			//需要遍历端点而且端点未处理
//////			debug.push(new Point(toX, toY));
////			if(useEndpoint) if(!handler(toX, toY)) return false;
////			return true;
//
//        return tileUtil.lineForeach(fromX, fromY, toX, toY, handler, useEndpoint);
//    }
//
//    // 只知道x的情况下， 获取一个可行走的目标点
//    public function getLegalPointByX(xPos:Number):Point {
//        var myGridPoint:Point = new Point();
//        // FIXME: Retrieves player location below.
////        pixel2Grid(MainManager.myAvatar.point.x, MainManager.myAvatar.point.y, myGridPoint);
//
//        myGridPoint.x = xPos;
//        for (var i:int = myGridPoint.y; i < _curMapGrid.numRows; i++) {
//            myGridPoint.y = i;
//            if (isWalk(myGridPoint.x, myGridPoint.y)) {
//                return myGridPoint;
//            }
//        }
//
//        for (var j:int = myGridPoint.y - 1; j >= 0; j--) {
//            myGridPoint.y = j;
//            if (isWalk(myGridPoint.x, myGridPoint.y)) {
//                return myGridPoint;
//            }
//        }
//
//        return null;
//    }
//
//    // 根据起始点找一个掉落结束点
//    public function findDropPoint(startPoint:Point, endPoint:Point, dropTick:int = 0):Point {
//        if (endPoint) return endPoint;
//
//        var dropPoint:Point;
//        var startX:Number = startPoint.x;
//        var startY:Number = startPoint.y;
//
//        var endX:Number;
//        var endY:Number;
//
//        var isLeft:Boolean = Math.random() > 0.5;
//        var xRange:int = 150 + dropTick * 20;
//        if (isLeft) {
//            endX = Math.max(0, startX - (xRange + Math.random() * xRange));
//        }
//        else {
//            endX = startX + (xRange + Math.random() * xRange);
//        }
//
//        var yRange:int = 140 + dropTick * 10;
//        endY = startY - 20 + Math.random() * yRange;
//
//        if (isWalkBy(endX, endY)) {
//            return new Point(endX, endY);
//        }
//        else {
//            dropTick++;
//            while (dropTick < 50) {
//                trace("startPoint.x : ", startPoint.x, "startPoint.y : ", startPoint.y, "endX : ", endX, "endY : ", endY, "droptick : ", dropTick);
//                return findDropPoint(startPoint, endPoint, dropTick);
//            }
//        }
//
//        // 暂时先抛出异常
////			throw new Error("无法找到附近可以掉落的点");
//        return new Point(startPoint.x, startPoint.y);
//    }
//
//    public function getCurWalkablePoints():Vector.<CNode> {
//        if (_curMapGrid) {
//            return _curMapGrid.walkableNodes;
//        }
//        return null;
//    }
//
//    public function get curMapGrid():CGridData {
//        return _curMapGrid;
//    }
//}
//}
