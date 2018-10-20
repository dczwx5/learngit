//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.enum {

import kof.ui.instance.InstanceScenarioUI;
import kof.ui.master.HeroStoryView.HeroStoryViewUI;
import kof.ui.master.HeroStoryView.HeroStoryWinUI;

public class EStoryWndResType {
    public static const MAIN:Array = [[HeroStoryViewUI, InstanceScenarioUI]];
    public static const WIN:Array = [[HeroStoryWinUI], ["frameclip_winner.swf"]];

}
}
