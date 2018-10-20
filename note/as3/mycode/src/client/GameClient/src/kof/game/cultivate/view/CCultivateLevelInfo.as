//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/5/23.
 */
package kof.game.cultivate.view {

import kof.game.cultivate.data.cultivate.CCultivateLevelData;
import kof.game.cultivate.data.cultivate.CCultivateLevelListData;

public class CCultivateLevelInfo {
    public function CCultivateLevelInfo(levelListData:CCultivateLevelListData, levelIndex:int, curLevelIndex:int) {
        this.levelListData = levelListData;
        levelData = levelListData.getLevel(levelIndex);
        this.levelIndex = levelIndex;
        this.curLevelIndex = curLevelIndex;
        this.isCurLevel = curLevelIndex == levelIndex;
        this.isLevelOpen = curLevelIndex >= levelIndex;
        this.sectionIndex = levelListData.getSectionByLevelIndex(levelIndex);
        this.curSectionIndex = levelListData.getSectionByLevelIndex(curLevelIndex);
        this.isCurSection = sectionIndex == curSectionIndex;

        if (levelData && levelData.sectionID == levelListData.curOpenSectionIndex) {
            // 正在打的
            state = STATE_CURRENT_SECTION;
        } else if (levelData.layer < levelListData.curOpenLevelIndex) {
            // 已打过的
            state = STATE_PASS_SECTION;
        } else {
            // 未打的
            state = STATE_UNOPEN_SECTION;
        }
    }

    public var curLevelIndex:int; // 当前最新关卡
    public var curSectionIndex:int; // 当前最新section

    public var levelIndex:int; // 关卡id
    public var sectionIndex:int; // 组ID

    public var isLevelOpen:Boolean; // 本关卡是否开放
    public var isCurLevel:Boolean; // 当前关卡是否本关卡
    public var isCurSection:Boolean;

    public var levelListData:CCultivateLevelListData;
    public var levelData:CCultivateLevelData;

    public var state:int;

    public static const STATE_PASS_SECTION:int = 0; // 已打过
    public static const STATE_CURRENT_SECTION:int = 1; // 正在打
    public static const STATE_UNOPEN_SECTION:int = 2; // 未开放

}
}
