//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/11/4.
 */
package kof.game.gameSetting.util {

import QFLib.Foundation.CMap;

import flash.ui.Keyboard;

public class CKeyMapping {

    private static var KeyMapping:CMap;

    public function CKeyMapping()
    {
    }

    public static function InitKeyMap():void
    {
        KeyMapping = new CMap();

        KeyMapping.add(Keyboard.A, "A");
        KeyMapping.add(Keyboard.B, "B");
        KeyMapping.add(Keyboard.C, "C");
        KeyMapping.add(Keyboard.D, "D");
        KeyMapping.add(Keyboard.E, "E");
        KeyMapping.add(Keyboard.F, "F");
        KeyMapping.add(Keyboard.G, "G");
        KeyMapping.add(Keyboard.H, "H");
        KeyMapping.add(Keyboard.I, "I");
        KeyMapping.add(Keyboard.J, "J");
        KeyMapping.add(Keyboard.K, "K");
        KeyMapping.add(Keyboard.L, "L");
        KeyMapping.add(Keyboard.M, "M");
        KeyMapping.add(Keyboard.N, "N");
        KeyMapping.add(Keyboard.O, "O");
        KeyMapping.add(Keyboard.P, "P");
        KeyMapping.add(Keyboard.Q, "Q");
        KeyMapping.add(Keyboard.R, "R");
        KeyMapping.add(Keyboard.S, "S");
        KeyMapping.add(Keyboard.T, "T");
        KeyMapping.add(Keyboard.U, "U");
        KeyMapping.add(Keyboard.V, "V");
        KeyMapping.add(Keyboard.W, "W");
        KeyMapping.add(Keyboard.X, "X");
        KeyMapping.add(Keyboard.Y, "Y");
        KeyMapping.add(Keyboard.Z, "Z");
        KeyMapping.add(Keyboard.UP, "↑");
        KeyMapping.add(Keyboard.DOWN, "↓");
        KeyMapping.add(Keyboard.LEFT, "←");
        KeyMapping.add(Keyboard.RIGHT, "→");

        KeyMapping.add(Keyboard.NUMBER_0, "0");
        KeyMapping.add(Keyboard.NUMBER_1, "1");
        KeyMapping.add(Keyboard.NUMBER_2, "2");
        KeyMapping.add(Keyboard.NUMBER_3, "3");
        KeyMapping.add(Keyboard.NUMBER_4, "4");
        KeyMapping.add(Keyboard.NUMBER_5, "5");
        KeyMapping.add(Keyboard.NUMBER_6, "6");
        KeyMapping.add(Keyboard.NUMBER_7, "7");
        KeyMapping.add(Keyboard.NUMBER_8, "8");
        KeyMapping.add(Keyboard.NUMBER_9, "9");

        KeyMapping.add(Keyboard.NUMPAD_0, "0");
        KeyMapping.add(Keyboard.NUMPAD_1, "1");
        KeyMapping.add(Keyboard.NUMPAD_2, "2");
        KeyMapping.add(Keyboard.NUMPAD_3, "3");
        KeyMapping.add(Keyboard.NUMPAD_4, "4");
        KeyMapping.add(Keyboard.NUMPAD_5, "5");
        KeyMapping.add(Keyboard.NUMPAD_6, "6");
        KeyMapping.add(Keyboard.NUMPAD_7, "7");
        KeyMapping.add(Keyboard.NUMPAD_8, "8");
        KeyMapping.add(Keyboard.NUMPAD_9, "9");
    }

    public static function getKeyNameByKeyCode(keyCode:int):String
    {
        if(KeyMapping == null)
        {
            InitKeyMap();
        }

        for(var key:String in KeyMapping)
        {
            if(int(key) == keyCode)
            {
                return KeyMapping.find(keyCode) as String
            }
        }

        return "";
    }
}
}
