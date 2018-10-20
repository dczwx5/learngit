//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2016/12/3.
 */
package kof.game.level.bubbles {

import QFLib.Foundation.CMap;
import QFLib.Framework.CObject;
import QFLib.Framework.CScene;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;

import flash.display.DisplayObject;

import flash.utils.getTimer;

import kof.framework.CAppStage;
import kof.framework.CViewHandler;
import kof.game.character.display.IDisplay;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.ui.CUISystem;
import kof.ui.demo.BubblesShoutUI;

import morn.core.handlers.Handler;

/*对话冒泡*/
public class CBubblesViewHandler extends CViewHandler implements IUpdatable {
    private var _appStage : CAppStage;

    private var m_ActorMap:CMap;

    private var m_bViewInitialized : Boolean;
    public function CBubblesViewHandler() {
        super(true);
    }
    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !m_bViewInitialized ) {
            m_bViewInitialized = true;
            if ( !m_ActorMap ) {
                m_ActorMap = new CMap();
            }
        }

        return m_bViewInitialized;
    }

    override public function get viewClass() : Array {
        return [ BubblesShoutUI ];
    }

    override protected function enterStage( appStage : CAppStage ) : void {
        super.enterStage( appStage );
        _appStage = appStage;
    }

    public function addBubbles(actor:CGameObject, content:String, time:int = 6, position:int = 0, x:int = 0, y:int = 0, hideCallBack:Function = null, type:int = 0 ) : void {

        if(m_ActorMap.find(actor)){
            return;
        }

        var data:Object = type ? new CBubblesShoutDialogueView() : new CBubblesDialogueView();
        data.actor = actor;
        data.hideCallBack = hideCallBack;
        data.content = content;
        data.position = position;
        data.time = (time*1000) + getTimer();
        data.x = x;
        data.y = y;
        data.init();

        m_ActorMap.add(data.actor,data);
//        if(m_ActorMap.length == 1){
//            schedule(1/60,update,1/60);
//        }
    }

    public function hide(actor:CGameObject) : void {
        var data:Object = m_ActorMap.find(actor);
        if(data){
            (uiCanvas as CUISystem).plotLayer.close(data.bubblesDialogueUI);
            if(data.hideCallBack){
                data.hideCallBack.apply();
            }
            data.dispose();
            m_ActorMap.remove(actor);
        }
    }

    public function hideAll() : void {
        for each (var data:Object in m_ActorMap){
            (uiCanvas as CUISystem).plotLayer.close(data.bubblesDialogueUI);
        }
    }

    public function update(delta:Number):void {
        if (m_ActorMap == null)
                return;
        if(m_ActorMap.length == 0){
//            unschedule(this.update);
            return;
        }
        for each (var data:Object in m_ActorMap){
            if(!data.actor.isRunning){
                break;
            }
            var transform:ITransform = data.actor.transform;
            var pDisplay:IDisplay = data.actor.getComponentByClass( IDisplay , true ) as IDisplay;

            var xOffset : int = pDisplay.defaultBound != null ?
                    ( data.position ? pDisplay.defaultBound.max.x + data.x: pDisplay.defaultBound.min.x - data.x )
                    : 50;
            var yOffset : int = pDisplay.defaultBound != null ? pDisplay.defaultBound.min.y : -200;
            yOffset += data.y;

            var vector3:CVector3 = CObject.get2DPositionFrom3D( transform.x + xOffset, transform.z - yOffset, transform.y );
            var vector2:CVector2 = new CVector2(vector3.x, vector3.y);
            var scene:CScene = ((system.stage.getSystem(CSceneSystem) as CSceneSystem).getBean(CSceneRendering) as CSceneRendering).scene;
            if (scene) {
                scene.mainCamera.worldToScreen(vector2);
            }

            if(data.position){
                data.bubblesDialogueUI.x = vector2.x;
            }
            else{
                data.bubblesDialogueUI.x = vector2.x - data.bubblesDialogueUI.txt_content.width;
            }

            data.bubblesDialogueUI.y = vector2.y - data.bubblesDialogueUI.txt_content.height;

            if(data.bubblesDialogueUI.parent == null){
                (uiCanvas as CUISystem).loadingLayer.parent.addChildAt(data.bubblesDialogueUI,0);
            }

            if(data.time <= getTimer()) {
                hide(data.actor);
            }
        }
    }

    override public function dispose() : void {
        super.dispose();
    }

}
}
