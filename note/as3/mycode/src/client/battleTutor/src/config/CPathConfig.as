//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/7/4.
 */
package config {

import QFLib.Utils.PathUtil;

public class CPathConfig {
    public static function getAudioPath(musicName:String) : String {
        var url:String = "assets/audio/battle_tutor/" + musicName;
        if (musicName.indexOf(".mp3") == -1) url += ".mp3";
        return PathUtil.getVUrl(url);
    }

    public static const AUDIO_1:String = "1";
    public static const AUDIO_2:String = "2";
    public static const AUDIO_3:String = "3";
    public static const AUDIO_4:String = "4";
    public static const AUDIO_5:String = "5";
    public static const AUDIO_6:String = "6";
    public static const AUDIO_7:String = "7";
    public static const AUDIO_8:String = "8";
    public static const AUDIO_9:String = "9";
    public static const AUDIO_10:String = "10";
    public static const AUDIO_11:String = "11";
    public static const AUDIO_12:String = "12";
    public static const AUDIO_13:String = "13";
    public static const AUDIO_14:String = "14";
    public static const AUDIO_15:String = "15";
    public static const AUDIO_16:String = "16";
    public static const AUDIO_17:String = "17";
    public static const AUDIO_18:String = "18";
    public static const AUDIO_19:String = "19";
    public static const AUDIO_20:String = "20";

    public static const STEP_100:int = 100; // wsad引导开始
    public static const STEP_105:int = 105; // wsad界面出现
    public static const STEP_110:int = 110; // D出现
    public static const STEP_120:int = 120; // 完成wsad

    public static const STEP_200:int = 200; // J引导开始
    public static const STEP_205:int = 205; // J介绍出现
    public static const STEP_210:int = 210; // 等待按J
    public static const STEP_220:int = 220; // 按了J, 引导完成, 下版本去掉

    public static const STEP_300:int = 300; // UIO引导开始
    public static const STEP_305:int = 305; // UIO介绍出现
    public static const STEP_310:int = 310; // 等待按U
    public static const STEP_320:int = 320; // 等待按I
    public static const STEP_330:int = 330; // 等待按O
    public static const STEP_340:int = 340; // U键 飞UIO
    public static const STEP_350:int = 350; // UIO引导完成

    public static const STEP_400:int = 400; // 大招引导开始
    public static const STEP_405:int = 405; // 大招介绍出现
    public static const STEP_410:int = 410; // 等待按空格
    public static const STEP_420:int = 420; // 空格键 飞
    public static const STEP_450:int = 450; // 大招引导完成

    public static const STEP_490:int = 490; // 强制自动战斗
    public static const STEP_492:int = 492; // 点了自动
    public static const STEP_496:int = 496; // 强制自动战斗完成

    public static const STEP_600:int = 600; // 格档引导开始
    public static const STEP_605:int = 605; // 格档详细界面1
    public static const STEP_610:int = 610; // 格档详细界面2
    public static const STEP_620:int = 620; // 格档引导完成

    public static const STEP_700:int = 700; // QE引导开始
    public static const STEP_715:int = 715; // QE引导完成

    public static const STEP_800:int = 800; // 受身引导开始
    public static const STEP_805:int = 805; // 受身详细界面1
    public static const STEP_810:int = 810; // 受身详细界面2
    public static const STEP_820:int = 820; // 受身引导完成
//
//    // 以下是未整理的
//    public static const STEP_500:int = 500; // 大招引导开始
//    public static const STEP_505:int = 505; // 大招介绍出现
//    public static const STEP_510:int = 510; // 等待按空格
//    public static const STEP_520:int = 520; // 空格键 飞UI
//    public static const STEP_530:int = 530; // 大招详细界面1
//    public static const STEP_540:int = 540; // 大招详细界面2
//    public static const STEP_560:int = 560; // 大招引导完成
//
//
//







}
}
