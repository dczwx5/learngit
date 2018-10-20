//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/6/6.
//----------------------------------------------------------------------
package kof.game.character.fight.skill {

final public class CSkillConstEnums {

    //begin skill type enum define

     /**
      * *  NORMAL type , cast by AI or manual
      */
     public static const SKILLTYPE_NORMAL : int = 0;
    /**
     * passive type , cast once per situation
     */
     public static const SKILLTYPE_PASSIVE : int = 1;
     /**
      *chain type, cast  after active type if some trigger condition happens;
     */
     public static const SKILLTYPE_CHAIN : int = 2;
    /**
     * Auras type
     */
     public static const SKILLTYPE_AURA : int = 3;

    //begin animation mode enum define

    /**
     * stretch mode
     */
    public static const ANIMAION_MODE_STRETCH : int = 0;

    /**
     * loop mode
     */
    public static const ANIMTION_MODE_LOOP : int = 1;

    /**
     * last frame mode
     */
    public static const ANIMATION_MODE_LASTFRAME : int = 2;

    /**
     *
     * 位移类型
     */
    public static const MOTION_NORMAL : int = 1 ; //普通x,y,z位移
    public static const MOTION_AERO : int = 2;// 击飞类型

    /**
     *
     * 位移方式
     */
    public static const MOTION_DIR_CLOSE : int = 0 ;
    public static const MOTION_DIR_FAR : int = 1;

}
}
