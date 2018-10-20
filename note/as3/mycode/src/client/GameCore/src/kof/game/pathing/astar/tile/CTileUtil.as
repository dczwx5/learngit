//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/20.
 */
package kof.game.pathing.astar.tile {

public class CTileUtil implements  ITile {
    public function CTileUtil(tile:ITile) {
        _tile = tile;
    }

    [Inline]
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
