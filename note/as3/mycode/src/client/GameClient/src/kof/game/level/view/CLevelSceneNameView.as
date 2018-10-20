/**
 * Created by dendi on 2018/1/4.
 */
package kof.game.level.view {
import flash.events.Event;
import flash.text.TextField;

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.IDataTable;

import kof.game.common.view.CRootView;
import kof.table.Levelinformation;
import kof.ui.master.level.SceneNameUI;

import morn.core.components.FrameClip;
import morn.core.handlers.Handler;

public class CLevelSceneNameView extends CRootView {

    private var m_characterClip:FrameClip;
    private var m_callbackFun:Function;
    public function CLevelSceneNameView() {
        super(SceneNameUI, null, [[SceneNameUI]], false);
    }

    protected override function _onShow():void {
        this.listStageClick = true;
        m_characterClip = _ui.clipCharacter as FrameClip;
        m_characterClip.playFromTo(null,null,new Handler(_onMovieCompleted));
    }

    private function _onMovieCompleted():void{
        if(m_callbackFun != null){
            m_callbackFun();
        }
    }

    override public function setData( data : Object, forceInvalid:Boolean = true ) : void {
        super.setData( data, forceInvalid );
        m_callbackFun = data.callback;

        m_characterClip = _ui.clipCharacter as FrameClip;
        var text:TextField =  m_characterClip.mc.mc_sceneName.text_name;
        var levelTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.LEVELINFORMATION);
        var obj:Levelinformation = levelTable.findByPrimaryKey(data.data[0]);
        text.text = obj.Levelmessage;
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToRoot();

        return true;
    }

    protected override function _onDispose() : void {
        m_characterClip.removeEventListener(Event.COMPLETE, _onMovieCompleted);
        m_characterClip = null;
    }

    protected function get _ui() : SceneNameUI {
        return rootUI as SceneNameUI;
    }
}
}
