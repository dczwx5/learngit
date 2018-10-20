//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar.tile {

import kof.game.pathing.astar.neighbor.CNeighborData;

public class CSquareTile implements ITile {

    public function CSquareTile(gCost:int, gObliqueCost:int) {
        _baseGCose = gCost;
        _baseGObliqueCost = gObliqueCost;

        _neighborList = [
            new CNeighborData(-1, 0, gCost),		// left
            new CNeighborData(1, 0, gCost),		// right
            new CNeighborData(0, -1, gCost),		// up
            new CNeighborData(0, 1, gCost),		// down
            new CNeighborData(-1, -1, gObliqueCost),		// top_left
            new CNeighborData(1, -1, gObliqueCost),		// top_right
            new CNeighborData(-1, 1, gObliqueCost),		// bottom_left
            new CNeighborData(1, 1, gObliqueCost)			// bottom_right
        ];
    }

    public function resetWeight() : void {
        for (var i:int = 0; i < _neighborList.length; i++) {
            if (i < 4) {
                (_neighborList[i] as CNeighborData).cost = _baseGCose;
            } else {
                (_neighborList[i] as CNeighborData).cost = _baseGObliqueCost;
            }
        }
    }
    public function reCalcWeight(deltaX:int, deltaY:int) : void {
        if (deltaX > deltaY) {
            (_neighborList[0] as CNeighborData).cost = _baseGCose * 2;
            (_neighborList[1] as CNeighborData).cost = _baseGCose * 2;
        } else if (deltaX < deltaY) {
            (_neighborList[2] as CNeighborData).cost = _baseGCose * 2;
            (_neighborList[3] as CNeighborData).cost = _baseGCose * 2;
        } else {

        }
    }

    [Inline]
    public function get neighborList() : Array {
        return _neighborList;
    }

    private var _neighborList:Array;

    private var _baseGCose:int;
    private var _baseGObliqueCost:int;
}
}
