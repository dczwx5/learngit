//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.util {

/**
 *
 */
public class CRandCode {

    static private var CODES : Array = [
        'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
        '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'
    ];

    public function CRandCode() {

    }

    public function generateCode( iMinLength : int, iMaxLength : int = -1 ) : String {
        if ( iMinLength <= 0 )
            return null;

        iMaxLength = iMaxLength <= 0 ? iMinLength : iMaxLength;

        const nCodes : uint = CODES.length;
        // length between min - max
        var nLen : uint = iMinLength + int( Math.random() * ( iMaxLength - iMinLength ) );
        var ret : String = '';

        for ( var i : uint = 0; i < nLen; ++i ) {
            var idx : uint = Math.random() * nCodes;
            ret += CODES[ idx ];
        }

        return ret;
    }
}
}
