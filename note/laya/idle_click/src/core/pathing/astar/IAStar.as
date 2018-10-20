/**
 * Created by auto
 */
package core.pathing.astar {
import core.pathing.astar.node.CNode;
import core.pathing.astar.tile.ITile;
import core.pathing.astar.node.INodeList;
import core.pathing.astar.buildPath.IBuildPath;
import core.pathing.astar.neighbor.INeighborProcess;
public interface IAStar {
    function initialByGridData(blockGrids:Object, xCount:int) : void ;

    function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array;
    function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array;
    // function isWalkable(gridX:int, gridY:int) : Boolean;
    function isInClose(node:CNode) : Boolean;
    function isInOpen(node:CNode) : Boolean;
    function calcH(node:CNode, endNode:CNode) : int;

    function set tileUtil(v:ITile) : void;
    function set openList(v:INodeList) : void;
    function set closeList(v:INodeList) : void;
    function set buildPath(v:IBuildPath) : void;
    function set neighborProcess(v:INeighborProcess) : void;
    function getNode(gridX:int, gridY:int) : CNode ;

}
}
