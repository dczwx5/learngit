//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2016/12/8.
 */
package kof.game.fightui.compoment {

import QFLib.Framework.CScene;
import QFLib.Math.CVector2;

import flash.utils.Dictionary;

import kof.framework.CViewHandler;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CKOFTransform;
import kof.game.core.CGameObject;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.ui.demo.FightUI;

import morn.core.components.Clip;

public class CCharacterPointViewHandler extends CViewHandler {

    private var m_fightUI:FightUI;
    private var _clipDic:Dictionary;
    private var _arrowDic:Dictionary;

    public function CCharacterPointViewHandler( $fightUI:FightUI ) {
        super();
        m_fightUI = $fightUI;
    }
    public function setData():void {
        hide();
        if(!m_fightUI)
            return;
        if(null == _clipDic)
            _clipDic = new Dictionary();
        if( null == _arrowDic )
            _arrowDic = new Dictionary();
        if(psceneSystem){
            psceneSystem.addEventListener(CSceneEvent.CHARACTER_IN_VIEW,_onInView, false, 0, true );
            psceneSystem.addEventListener(CSceneEvent.CHARACTER_OUT_VIEW,_onOutView, false, 0, true );
        }
        schedule(300/1000,updateView);
    }
    private function updateView( delta : Number ):void {
        for ( var gameObject:CGameObject in  _clipDic) {
            var clip : Clip;
            var arrow : Clip;
            if( gameObject && gameObject.isRunning == false ){
                clip  = _clipDic[gameObject];
                if(clip){
                    clip.remove();
                    clip = null;
                    delete _clipDic[gameObject];
                }
                arrow  = _arrowDic[gameObject];
                if(arrow){
                    arrow.remove();
                    arrow = null;
                    delete _arrowDic[gameObject];
                }
            }else if( gameObject && gameObject.transform ){
                var axis2d : CVector2 = (gameObject.transform as CKOFTransform).to2DAxis();
                var scene:CScene = _pSceneRendering.scene;
                if (scene) {
                    scene.mainCamera.worldToScreen(axis2d);
                }
                clip  = _clipDic[gameObject];
                arrow = _arrowDic[gameObject];
                if( axis2d.x <= 0 ) {
                    clip.x = 75;
                    arrow.x = 50;
                }else {
                    clip.x = system.stage.flashStage.stageWidth - 150;
                    arrow.scaleX = -1;
                    arrow.x = system.stage.flashStage.stageWidth - 60;
                }
                clip.y = axis2d.y;
                arrow.y = axis2d.y - 5;
            }
        }
    }
    private function _onInView(evt:CSceneEvent):void{
        if(!m_fightUI || !m_fightUI.parent)
            return;
        var gameObject:CGameObject = evt.value as CGameObject;
        if( CCharacterDataDescriptor.getType(gameObject.data) != 1 )
            return;
        var clip : Clip = _clipDic[gameObject];
        if(clip){
            clip.remove();
            clip = null;
            delete _clipDic[gameObject];
        }
        var arrow : Clip = _arrowDic[gameObject];
        if(arrow){
            arrow.remove();
            arrow = null;
            delete _arrowDic[gameObject];
        }

    }
    private function _onOutView(evt:CSceneEvent):void{
        if(!m_fightUI || !m_fightUI.parent)
            return;
        var gameObject:CGameObject = evt.value as CGameObject;
        if( CCharacterDataDescriptor.getType(gameObject.data) != 1 )
                return;
        if(_clipDic[gameObject])
                return;
        var index :int = CCharacterDataDescriptor.getOperateIndex( gameObject.data);
        var side :int = CCharacterDataDescriptor.getOperateSide( gameObject.data );
        var clip : Clip;
        var arrow : Clip;
        arrow = createPointClip("arrow");
        if( side == 1 ){
            if( index == 1 ){
                clip = createPointClip("green");
                arrow.index = 0;
            }else{
                clip = createPointClip("bule");
                arrow.index = 2;
            }
        }else{
            clip = createPointClip("red");
            arrow.index = 1;
        }
        clip.index = index - 1;
        _clipDic[gameObject]  = clip;
        _arrowDic[gameObject]  = arrow;

        updateView( 0 );

        m_fightUI.addChild(clip);
        m_fightUI.addChild(arrow);
    }
    private function createPointClip( color :String ):Clip{
        var clip:Clip = new Clip();
        if( color == "bule" ){
            clip.skin = m_fightUI.clip_bule123.skin;
        }else if(color == "green" ){
            clip.skin = m_fightUI.clip_green123.skin;
        }else if(color == "red" ){
            clip.skin = m_fightUI.clip_red123.skin;
        }else if(color == "arrow" ){
            clip.skin = m_fightUI.clip_arrow.skin;
        }
        return clip;
    }

    private function get psceneSystem():CSceneSystem{
        return system.stage.getSystem(CSceneSystem) as CSceneSystem;
    }
    public function hide(removed:Boolean = true):void {
        if(!m_fightUI)
            return;
        unschedule(updateView);
        psceneSystem.removeEventListener(CSceneEvent.CHARACTER_IN_VIEW,_onInView);
        psceneSystem.removeEventListener(CSceneEvent.CHARACTER_OUT_VIEW,_onOutView);
        for each( var clip:Clip in _clipDic ){
            clip.remove();
        }
        _clipDic = null;
        for each( var arrow:Clip in _arrowDic ){
            arrow.remove();
        }
        _arrowDic = null;

    }
    private function get _pSceneSystem():CSceneSystem{
        return system.stage.getSystem( CSceneSystem ) as CSceneSystem;
    }
    private function get _pSceneRendering():CSceneRendering{
        return _pSceneSystem.getBean( CSceneRendering ) as CSceneRendering;
    }
}
}
