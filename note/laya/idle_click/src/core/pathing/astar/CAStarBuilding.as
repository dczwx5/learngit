/**
 * Created by auto
 */
package core.pathing.astar {

import core.pathing.astar.buildPath.CBuildPath;
import core.pathing.astar.buildPath.CBuildReversePath;
import core.pathing.astar.buildPath.IBuildPath;
import core.pathing.astar.calc.CObliqueBlockCalc;
import core.pathing.astar.neighbor.CNeighborProcess;
import core.pathing.astar.node.CCloseList;
import core.pathing.astar.node.CMinHeapOpenList;
import core.pathing.astar.node.CNode;
import core.pathing.astar.tile.CSquareTile;
import core.pathing.astar.tile.CTileUtil;

public class CAStarBuilding {
    public function CAStarBuilding() {
    }
    public static function buildAStar(aStar:CAStar) : CAStar {
        if (aStar == null) aStar = new CAStar();

        var tile:CSquareTile = new CSquareTile(CNode.G_VALUE, CNode.G_OBLIQUE_VALUE);
        aStar.tileUtil = new CTileUtil(tile);
        aStar.openList = new CMinHeapOpenList();//new COpenList();
        aStar.closeList = new CCloseList();

        var buildOrderPath:IBuildPath = new CBuildPath();
        var buildReservePath:IBuildPath = new CBuildReversePath();
        aStar.buildPath = buildOrderPath;
        aStar.buildOrderPath = buildOrderPath;
        aStar.buildReversePath = buildReservePath;
        aStar.neighborProcess = new CNeighborProcess(aStar, new CObliqueBlockCalc(aStar));
        return aStar;
    }
}
}
