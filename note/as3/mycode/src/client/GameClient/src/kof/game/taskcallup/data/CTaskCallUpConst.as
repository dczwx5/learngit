//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/6/20.
 */
package kof.game.taskcallup.data {

public class CTaskCallUpConst {
    public function CTaskCallUpConst() {
    }

    //任务类型
    static public const TEAM_TYPE : int = 1;//队伍任务
    static public const LOVE_TYPE : int = 2;//情侣任务
    static public const SINGLE_TYPE : int = 3;//单人任务
    static public const JOB_TYPE : int = 4;//职业任务
    static public const WOMEN_TYPE : int = 5;//女性任务
    static public const CLUB_TYPE : int = 6;//社团任务



    static public const UP_TYPE : int = 1;//上阵
    static public const DOWN_TYPE : int = 2;//下阵

    static public const NORMALE_RESPONE_TYPE : int = 0;//表示正常请求的返回
    static public const ACCEPT_RESPONE_TYPE : int = 1;//表示接取召集令请求的返回
    static public const CANCEL_RESPONE_TYPE : int = 2;//表示取消召集令请求的返回


}
}
