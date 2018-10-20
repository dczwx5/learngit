//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/23.
 */
package kof.game.pathing.astar {

import kof.game.pathing.astar.buildPath.CBuildPath;
import kof.game.pathing.astar.buildPath.CBuildReversePath;
import kof.game.pathing.astar.buildPath.IBuildPath;
import kof.game.pathing.astar.calc.CObliqueBlockCalc;
import kof.game.pathing.astar.neighbor.CNeighborProcess;
import kof.game.pathing.astar.node.CCloseList;
import kof.game.pathing.astar.node.CMinHeapOpenList;
import kof.game.pathing.astar.node.CNode;
import kof.game.pathing.astar.tile.CSquareTile;
import kof.game.pathing.astar.tile.CTileUtil;

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
