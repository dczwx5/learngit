//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by Administrator on 2016/9/26.
 */
package kof.game.instance.mainInstance.enum {

import kof.ui.demo.GlobalViewUI;
import kof.ui.instance.InstanceChapterEffectUI;
import kof.ui.instance.InstanceChapterMovieUI;
import kof.ui.instance.InstanceLoseUI;
import kof.ui.instance.InstanceNoteUI;
import kof.ui.instance.InstancePvpWinUI;
import kof.ui.instance.InstanceScenarioUI;
import kof.ui.instance.InstanceWinDescUI;
import kof.ui.instance.InstanceWinUI;
import kof.ui.master.PeakGame.PeakGameResultUI;
import kof.ui.master.level.BossComingUI;
import kof.ui.master.level.MasterComingUI;
import kof.ui.master.level.ReadyGoUI;
import kof.ui.master.level.SceneNameUI;

public class EInstanceWndResType {

    public static const INSTANCE_SCENARIO:Array = [[InstanceScenarioUI, InstanceNoteUI, BossComingUI, ReadyGoUI, MasterComingUI, SceneNameUI], ["frameclip_zjjl.swf"]];
    public static const INSTANCE_WIN_RESULT:Array = [[InstanceWinUI, InstanceWinDescUI]];// [["instance.swf", "frameclip_winner.swf"]];
    public static const INSTANCE_LOSE_RESULT:Array = [[InstanceLoseUI]];
    public static const INSTANCE_READY_GO:Array = [[ReadyGoUI]];
    public static const INSTANCE_PVP_RESULT:Array = [[PeakGameResultUI]]; //
    public static const INSTANCE_PVP_ROUND_RESULT:Array = [[InstancePvpWinUI]]; //
    public static const INSTANCE_GOLD_RESULT:Array = [[GlobalViewUI]]; //
    public static const INSTANCE_TRAIN_RESULT:Array = [[GlobalViewUI]]; //
    public static const INSTANCE_CHAPTER_EFFECT:Array = [[InstanceChapterEffectUI]]; //
    public static const INSTANCE_CHAPTER_MOVIE:Array = [[InstanceChapterMovieUI]]; //



}
}
