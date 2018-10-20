//------------------------------------------------------------------------------ // Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2017/8/17.
//----------------------------------------------------------------------
package kof.game.character.scripts.playersprite {

import kof.game.character.property.interfaces.IAddTemplate;

public class CVipTextConst {
    public static const HONOR_TITLE : String = "honortitle";
    public static const TX_VIP_FONT : String = "txvipfont";
    public static const PLAYER_VIP : String = "clipvip";
    public static const FONT_SIZE :  int  = 48;

    public static const MY_VIP : int = 0;

    public static const YELLOW_LEVEL_1 : int = 1;


    public static const YELLOW_YEAR_LEVEL_1 : String = 'a';

    public static const BLUE_LEVEL_1 : String = "A";
    public static const BLUE_SUPER_LEVEL_1 : String = "I";

    public static const BLUE_YEAR : int = 8;

    public static function getYellowByLevel( level : int ) : int{
        return YELLOW_LEVEL_1  + level - 1;
    }

    public static function getYearYellowByLevel( level : int ) : String {
        return _getCharPerLevel( YELLOW_YEAR_LEVEL_1, level ) ;
    }

    public static function getBlueByLevel( level : int ) : String{
        return _getCharPerLevel( BLUE_LEVEL_1 , level );
    }

    public static function getSuperBlueYearByLevel( level : int ) : String {
        return _getCharPerLevel( BLUE_SUPER_LEVEL_1 , level );
    }

    private static function _getCharPerLevel( orignalChar : String , level : int ) : String
    {
        var charCode : int = orignalChar.charCodeAt( 0 );
        charCode= charCode + level - 1 ;
        var retStr : String;
        retStr = String.fromCharCode( charCode );
        return retStr;
    }
}

}
