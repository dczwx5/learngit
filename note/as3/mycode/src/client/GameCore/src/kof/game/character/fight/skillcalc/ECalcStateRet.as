//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/8/30.
//----------------------------------------------------------------------
package kof.game.character.fight.skillcalc {

public class ECalcStateRet {
    /**
     * accept the result
     */
    public static var E_PASS : int = 1 ;

    /**
     * reject  and ignore the result
     */
    public static var E_BAN : int = 2;

    /**
     * accept the result but mean in A transfer state.
     */
    public static var E_TRANSFER : int = 3;

}
}
