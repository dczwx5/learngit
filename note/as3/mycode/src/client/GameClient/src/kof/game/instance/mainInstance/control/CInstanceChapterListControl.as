//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2018/5/1.
 */
package kof.game.instance.mainInstance.control {

import kof.game.common.view.CViewBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.instance.event.CInstanceEvent;
import kof.game.instance.mainInstance.data.CChapterData;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.enum.EInstanceWndType;
import kof.game.instance.mainInstance.view.event.EInstanceViewEventType;
import kof.game.reciprocation.CReciprocalSystem;
import kof.game.reciprocation.popWindow.EPopWindow;

public class CInstanceChapterListControl extends CInstanceControler{
    public function CInstanceChapterListControl() {
    }
    public override function dispose() : void {
        _wnd.removeEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        system.removeEventListener(CInstanceEvent.CHAPTER_REWARD, _onDataUpdate);

    }
    public override function create() : void {
        _wnd.addEventListener(CViewEvent.UI_EVENT, _onUIEvent);
        system.addEventListener(CInstanceEvent.CHAPTER_REWARD, _onDataUpdate);

    }

    private function _onUIEvent(e:CViewEvent) : void {
        var subType:String = e.subEvent;
        switch (subType) {
            case EInstanceViewEventType.CHAPTER_REPLAY_MOVIE :
                var pInstanceData:CChapterInstanceData = e.data as CChapterInstanceData;
                if (pInstanceData && pInstanceData.firstPassMovieUrl && pInstanceData.firstPassMovieUrl.length > 0) {
                    (system.stage.getSystem( CReciprocalSystem ) as CReciprocalSystem).addEventPopWindow( EPopWindow.POP_WINDOW_15, function():void{
                        uiHandler.showChapterMovieView(pInstanceData);
                    });
                }
                break;
            case EInstanceViewEventType.CHAPTER_SELECT :
                var chapter:CChapterData = e.data as CChapterData;
                var rootView:CViewBase = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_SCENARIO);
                if (rootView == null) {
                    rootView = uiHandler.getWindow(EInstanceWndType.WND_INSTANCE_ELITE);
                }
                if (rootView) {
                    rootView.dispatchEvent(new CViewEvent(CViewEvent.UI_EVENT, EInstanceViewEventType.INSTANCE_CHANGE_CHAPTER, chapter));
                }

                break;

        }

    }

    private function _onDataUpdate(e:CInstanceEvent) : void {
        _wnd.invalidate();
    }
}
}
