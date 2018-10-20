//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun CNetwork Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

/**
 * A poor utilities as assert supported.
 *
 * @author Jeremy (jeremy@qifun.com)
 */
public final class CAssertUtils {

    static public function assertEquals(a:*, b:*, msg:String = null):void {
        CONFIG::debug {
        if (a != b) {
            _throwError(msg ? msg : "assertEquals Failed.");
        }
        }
    }

    static public function assertNotEquals(a:*, b:*, msg:String = null):void {
        CONFIG::debug {
        if (a == b) {
            _throwError(msg ? msg : "assertNotEquals Failed.");
        }
        }
    }

    static public function assertNull(a:*, msg:String = null):void {
        CONFIG::debug {
        if (null != a) {
            _throwError(msg ? msg : "assertNull Failed.");
        }
        }
    }

    static public function assertNotNull(a:*, msg:String = null):void {
        CONFIG::debug {
        if (null == a) {
            _throwError(msg ? msg : "assertNotNull Failed.");
        }
        }
    }

    static public function assertTrue(expressionResult:Boolean, msg:String = null):void {
        CONFIG::debug {
        if (true !== expressionResult)
            _throwError(msg ? msg : "assertTrue Failed.");
        }
    }

    static public function assertFalse(expressionResult:Boolean, msg:String = null):void {
        CONFIG::debug {
        if (false !== expressionResult)
            _throwError(msg ? msg : "assertFalse Failed.");
        }
    }

    CONFIG::debug {
    static private function _throwError(msg:String):void {
        throw new CAssertionError(msg);
    }
    }

    public static function assertNotNaN( x : Number, msg : String = null ) : void {
        CONFIG::debug {
            if (isNaN(x))
                _throwError(msg ? msg : "assertNotNaN Failed.");
        }
    }

    public static function assertNaN( x : Number, msg : String = null ) : void {
        CONFIG::debug {
            if (!isNaN(x))
                _throwError(msg ? msg : "assertNaN Failed.");
        }
    }
} // class CAssertUtils
}
