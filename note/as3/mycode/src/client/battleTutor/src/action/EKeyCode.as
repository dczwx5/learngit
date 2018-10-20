//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/6/19.
 */
package action {

import flash.ui.Keyboard;

public class EKeyCode {
    public static const W:String = "W";
    public static const S:String = "S";
    public static const A:String = "A";
    public static const D:String = "D";
    public static const U:String = "U";
    public static const I:String = "I";
    public static const O:String = "O";
    public static const J:String = "J";
    public static const K:String = "K";
    public static const L:String = "L";
    public static const Q:String = "Q";
    public static const E:String = "E";

    public static const SPACE:String = "SPACE";

    public static const W_INDEX:int = 0;
    public static const A_INDEX:int = 1;
    public static const S_INDEX:int = 2;
    public static const D_INDEX:int = 3;

    public static const U_INDEX:int = 0;
    public static const I_INDEX:int = 1;
    public static const O_INDEX:int = 2;
    public static const J_INDEX:int = 3;
    public static const K_INDEX:int = 4;
    public static const L_INDEX:int = 5;

    public static function getKeyCodeByKey(key:String) : uint {
        switch (key) {
            case W :
                return Keyboard.W;
            case A :
                return Keyboard.A;
            case S :
                return Keyboard.S;
            case D :
                return Keyboard.D;

            case U :
                return Keyboard.U;
            case I :
                return Keyboard.I;
            case O :
                return Keyboard.O;
            case J :
                return Keyboard.J;
            case K :
                return Keyboard.K;
            case L :
                return Keyboard.L;
            case SPACE :
                return Keyboard.SPACE;
        }
        return 0;
    }
    public static function getKeyByKeyCode(keyCode:uint) : String {
        switch (keyCode) {
            case Keyboard.W :
                return W;
            case Keyboard.A :
                return A;
            case Keyboard.S :
                return S;
            case Keyboard.D :
                return D;

            case Keyboard.U :
                return U;
            case Keyboard.I :
                return I;
            case Keyboard.O :
                return O;
            case Keyboard.J :
                return J;
            case Keyboard.K :
                return K;
            case Keyboard.L :
                return L;
            case Keyboard.SPACE :
                return SPACE;
        }
        return "";
    }

    public static function getIndexByKey(key:String) : int {
        switch (key) {
            case W :
                return W_INDEX;
            case A :
                return A_INDEX;
            case S :
                return S_INDEX;
            case D :
                return D_INDEX;

            case U :
                return U_INDEX;
            case I :
                return I_INDEX;
            case O :
                return O_INDEX;
            case J :
                return J_INDEX;
            case K :
                return K_INDEX;
            case L :
                return L_INDEX;
            case SPACE :
                return K_INDEX; // todo : fix it
        }
        return 0;
    }
}
}
