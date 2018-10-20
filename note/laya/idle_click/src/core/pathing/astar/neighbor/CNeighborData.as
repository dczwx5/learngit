/**
 * Created by auto
 */
package core.pathing.astar.neighbor {

public class CNeighborData {
    public function CNeighborData(rX:int, rY:int, rCost:int) {
        x = rX;
        y = rY;
        cost = rCost;
    }

    public var x:int;
    public var y:int;
    public var cost:int;
}
}
