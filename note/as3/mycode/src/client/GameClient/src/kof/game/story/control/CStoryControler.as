//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/6/14.
 */
package kof.game.story.control {

import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.common.view.control.CControlBase;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.story.CStoryNetHandler;
import kof.game.story.CStorySystem;
import kof.game.story.CStoryUIHandler;
import kof.game.story.data.CStoryData;

public class CStoryControler extends CControlBase {
    [Inline]
    public function get uiHandler() : CStoryUIHandler {
        return _wnd.viewManagerHandler as CStoryUIHandler;
    }
    [Inline]
    public function get system() : CStorySystem {
        return _system as CStorySystem;
    }
    [Inline]
    public function get pInstanceSystem() : CInstanceSystem {
        return _system.stage.getSystem(CInstanceSystem) as CInstanceSystem;
    }
    [Inline]
    public function get netHandler() : CStoryNetHandler {
        return (_system as CStorySystem).netHandler;
    }
    [Inline]
    public function get storyData() : CStoryData {
        return (_system as CStorySystem).data;
    }
    [Inline]
    public function get playerData() : CPlayerData {
        return (_system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData;
    }

    public function getInstanceData(instanceContentID:int) : CChapterInstanceData {
        var pInstanceSystem:CInstanceSystem = (_system.stage.getSystem(CInstanceSystem) as CInstanceSystem);
        var instanceData:CChapterInstanceData = pInstanceSystem.instanceData.instanceList.getByID(instanceContentID);
        return instanceData;
    }

    public function getItem(itemID:int) : CBagData {
        var pBagSystem:CBagSystem = _system.stage.getSystem(CBagSystem) as CBagSystem;
        var itemData:CBagData = (pBagSystem.getBean(CBagManager) as CBagManager).getBagItemByUid(itemID);
        return itemData;
    }
}
}
