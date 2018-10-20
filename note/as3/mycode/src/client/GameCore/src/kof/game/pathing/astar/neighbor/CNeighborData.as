//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar.neighbor {

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
