//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by dendi on 2018/4/23.
 */
package kof.game.level.view {

import QFLib.ResourceLoader.CResource;
import QFLib.ResourceLoader.CResourceLoaders;
import QFLib.ResourceLoader.CSwfLoader;
import QFLib.ResourceLoader.ELoadingPriority;
import QFLib.Utils.PathUtil;

import flash.display.MovieClip;
import flash.utils.setTimeout;

import kof.game.common.view.CRootView;
import kof.ui.master.Introduction.IntroductionViewUI;

//角色介绍
public class CLevelIntroductionView extends CRootView {

    private var m_MC:MovieClip;
    private var m_pMCResource : CResource;
    private var m_callbackFun:Function;
    private var m_url:String;
    private var m_time:int;
    public function CLevelIntroductionView( ) {
        super(IntroductionViewUI, null, [[IntroductionViewUI]], false);
    }

    protected override function _onShow():void {
        this.listStageClick = true;
    }

    override public function setData( data : Object, forceInvalid:Boolean = true ) : void {
        super.setData( data, forceInvalid );
        m_callbackFun = data.callback;
        m_url = getSWFPath(data.data[0]);
        m_time = data.data[1];
    }

    public virtual override function updateWindow() : Boolean {
        if (false == super.updateWindow()) return false;

        this.addToDialog(null);
        CResourceLoaders.instance().startLoadFile( m_url, swfOnLoadComplete, null, ELoadingPriority.CRITICAL );
        return true;
    }

    private function swfOnLoadComplete( pLoader : CSwfLoader, idError : int ):void {
        if ( 0 == idError ) {
            m_pMCResource = pLoader.createResource();
            m_MC = m_pMCResource.theObject as MovieClip;
            m_MC.gotoAndPlay( 0 );
            m_MC.addFrameScript( m_MC.totalFrames - 1, _onPlayFinish );
            _ui._box.addChild( m_MC );

            m_MC.x = -m_MC.width/2 + 50;//m_pUI.stage.stageWidth;
            m_MC.y = -m_MC.height/2 - 100;//m_pUI.stage.stageHeight;
        }
    }

    private function _onPlayFinish() : void {
        m_MC.stop();
        if(m_callbackFun != null){
            if(m_time > 0){
                setTimeout(_onDispose, m_time * 1000);
                return;
            }
            _onDispose();
        }
    }

    protected override function _onDispose() : void {
        if(m_callbackFun){
            m_callbackFun();
        }

        m_MC.stop();
        _ui._box.removeChild( m_MC );
        m_MC = null;
    }

    protected function get _ui() : IntroductionViewUI {
        return rootUI as IntroductionViewUI;
    }

    public static function getSWFPath(videoName:String) : String {
        var url:String = "assets/video/swf/" + videoName+".swf";

        return PathUtil.getVUrl(url);
    }
}
}
