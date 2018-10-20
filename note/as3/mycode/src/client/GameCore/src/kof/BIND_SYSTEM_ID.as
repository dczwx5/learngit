//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof {

import kof.util.CSystemIDBinder;

public function BIND_SYSTEM_ID( keyword : String, ID : int ) : void {
    CSystemIDBinder.bind( keyword, ID );
}
}

