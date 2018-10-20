//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.game.core {

import QFLib.Interface.IUpdatable;

/**
 * <code>CSubscribeBehaviour</code> handling by <code>CTickHandler</code> sub game system.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class CSubscribeBehaviour extends CGameComponent implements IUpdatable {

    /** Creates a new CSubscribeBehaviour. */
    public function CSubscribeBehaviour( name : String = null, branchData : Boolean = false ) {
        super( name, branchData );
    }

    /** @inheritDoc */
    public virtual function update( delta : Number ) : void {

    }

}
}
