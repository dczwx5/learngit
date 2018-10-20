/**
 * Created by auto
 */
package core.pathing.astar.tile {

public class CTileUtil implements  ITile {
    public function CTileUtil(tile:ITile) {
        _tile = tile;
    }

    
    public function get neighborList() : Array {
        return _tile.neighborList;
    }
    public function resetWeight() : void {

    }

    public function reCalcWeight(deltaX:int, deltaY:int) : void {

    }

    private var _tile:ITile;
}
}
