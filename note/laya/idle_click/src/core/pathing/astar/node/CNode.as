/**
 * Created by auto
 */
package core.pathing.astar.node {
import laya.maths.Point;

public class CNode {
    public function CNode(gridx:int, gridy:int) {
        this.gridX = gridx;
        this.gridY = gridy;
    }

    public function calcF() : void {
        f = g + h;
    }

    
    public function equal(n:CNode) : Boolean {
        return gridX == n.gridX && gridY == n.gridY;
    }
    
    public function notEqual(n:CNode) : Boolean {
        return !(gridX == n.gridX && gridY == n.gridY);
    }
    /*
    * -1 : self is smaller
    * 0 : equal
    * 1 : self is bigger
    */
    
    public function compareF(n:CNode) : int {
        return f - n.f;
    }
    
    public function exportGrid() : Point {
        return new Point(gridX, gridY);
    }

    public function setData(g:int, h:int, f:int, parent:CNode) : void {
        this.g = g;
        this.f = f;
        this.h = h;
        this.pParent = parent;
    }
//    
//    public function exportPixel() : Point {
//        return new Point(gridX, gridY);
//    }

    public var pParent:CNode;
    public var f:int;
    public var g:int;
    public var h:int;

    public var gridX:int; // 格子x
    public var gridY:int; // 格子y

    public var isBlock:Boolean;

    public var inOpenList:Boolean;
    public var inCloseList:Boolean;

    public static const G_VALUE:int = 10; // 水平。垂直
    public static const G_OBLIQUE_VALUE:int = 14; // 斜角
    public static const H_VALUE:int = 10;

    public static const SIZE:int = 35;
}
}
