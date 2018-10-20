//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof {

import kof.util.CSystemIDBinder;

public function SYSTEM_TAG( id : int ) : String {
    return CSystemIDBinder.tagById( id );
}

}
