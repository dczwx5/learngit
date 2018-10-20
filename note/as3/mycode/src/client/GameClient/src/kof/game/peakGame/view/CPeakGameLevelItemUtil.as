//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/21.
 */
package kof.game.peakGame.view {

import kof.ui.master.PeakGame.PeakGameLevelItemUI;
import kof.ui.master.PeakGame.PeakGameLevelItembigIIUI;
import kof.ui.master.PeakGame.PeakGameLevelItembigUI;

import morn.core.components.FrameClip;

public class CPeakGameLevelItemUtil {
    public static function setValue(item:PeakGameLevelItemUI, levelID:int, subLevelID:int, levelName:String, isShowName:Boolean = true, isShowStar:Boolean = true) : void {
        if (item.rank_txt.visible) {
            item.rank_txt.visible = false;
        }
        if (item.level_clip.index != (7-levelID)) {
            item.level_clip.index = (7-levelID);
        }
        if (item.name_txt.visible != isShowName) {
            item.name_txt.visible = isShowName;
        }
        if (item.star_box.visible != isShowStar) {
            item.star_box.visible = isShowStar;
        }
        if (item.name_txt.text != levelName) {
            item.name_txt.text = levelName;
        }
        if (item.star1.visible != (subLevelID > 0)) {
            item.star1.visible = subLevelID > 0;
        }
        if (item.star2.visible != subLevelID > 1) {
            item.star2.visible = subLevelID > 1;
        }
        if (item.star3.visible != subLevelID > 2) {
            item.star3.visible = subLevelID > 2;
        }
    }

    public static function setValueBig(item:PeakGameLevelItembigUI, levelID:int, subLevelID:int,
                                       levelName:String, isShowName:Boolean = true, isShowStar:Boolean = true, rankValue:int = -1) : void {
        item.rank_txt.visible = rankValue > 0;
        item.rank_txt.text = rankValue.toString();
        item.level_clip.index = (7-levelID);
        item.name_txt.visible = isShowName;
        item.star_box.visible = isShowStar;
        item.name_txt.text = levelName;
        item.star1.visible = subLevelID > 0;
        item.star2.visible = subLevelID > 1;
        item.star3.visible = subLevelID > 2;
    }
    public static function setValueBigII(item:PeakGameLevelItembigIIUI, levelID:int, subLevelID:int,
                                       levelName:String, isShowName:Boolean = true, isShowStar:Boolean = true, rankValue:int = -1) : void {
        item.rank_txt.visible = rankValue > 0;
        item.rank_txt.text = rankValue.toString();
        item.name_txt.visible = isShowName;
        item.star_box.visible = isShowStar;
        item.name_txt.text = levelName;
        item.star1.visible = subLevelID > 0;
        item.star2.visible = subLevelID > 1;
        item.star3.visible = subLevelID > 2;

        for (var i:int = 0; i < 7; i++) {
            var mv:FrameClip = item["level_mv_" + (i+1)];
            mv.visible = false;
            mv.stop();
        }
        mv = item["level_mv_" + (levelID)];
        mv.play();
        mv.visible = true;
    }
}
}
