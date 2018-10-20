//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof {

import kof.util.CSystemIDBinder;

public function SYSTEM_ID( keyword : String ) : int {
    return CSystemIDBinder.idByTag( keyword );
}

}
