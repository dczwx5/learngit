//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/2/23.
 */
package core.character.pathing {

import core.game.ecsLoop.CSubscribeBehaviour;
import core.pathing.IPathingFacade;

public class CPathingMediator extends CSubscribeBehaviour implements IPathingFacade {
    public function CPathingMediator(pPathingFacade:IPathingFacade, isMainCity:Boolean) {
        super("pathing");
        _isMainCity = isMainCity;
        _pPathingFacade = pPathingFacade;
    }
    override public function dispose() : void {
        super.dispose();
        this._pPathingFacade = null;
    }

    override protected function onEnter() : void {
        super.onEnter();
    }
    override protected function onExit() : void {
        super.onExit();
    }

    public function findOrderPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        return _pPathingFacade.findPath(stGridX, stGridY, endGridX, endGridY);
    }
    public function findReversePath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        return _pPathingFacade.findReversePath(stGridX, stGridY, endGridX, endGridY);
    }
    public function findPath(stGridX:int, stGridY:int, endGridX:int, endGridY:int) : Array {
        if (_isMainCity) {
            return findReversePath(stGridX, stGridY, endGridX, endGridY);
        } else {
            return findOrderPath(stGridX, stGridY, endGridX, endGridY);
        }
    }

    private var _pPathingFacade:IPathingFacade;
    private var _isMainCity:Boolean;
}
}
