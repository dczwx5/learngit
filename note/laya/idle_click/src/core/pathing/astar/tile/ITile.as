/**
 * Created by auto
 */
package core.pathing.astar.tile {

public interface ITile {
    function get neighborList() : Array;
    function resetWeight() : void ;
    function reCalcWeight(deltaX:int, deltaY:int) : void ;
}
}
