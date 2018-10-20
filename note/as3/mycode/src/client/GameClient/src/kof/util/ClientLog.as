//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

import flash.external.ExternalInterface;

/**
 * 客户端打点日志
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public class ClientLog {

    public static function log( logID : int ) : void {
        if ( ExternalInterface.available ) {
            try {
                ExternalInterface.call( "window.client_log", logID );
            } catch ( e : Error ) {
                // ignore.
            }
        }
    }

    public function ClientLog() {
    }

}
}
