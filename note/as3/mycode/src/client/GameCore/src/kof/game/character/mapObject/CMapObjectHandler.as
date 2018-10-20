//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by user on 2017/2/27.
 */
package kof.game.character.mapObject {

import QFLib.Foundation.CMap;
import QFLib.Framework.CCharacter;
import QFLib.Framework.CScene;
import QFLib.Math.CAABBox2;
import QFLib.Math.CVector2;

import flash.display.Stage;

import flash.events.MouseEvent;

import kof.game.core.CGameSystemHandler;
import kof.game.core.CSubscribeBehaviour;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;

public class CMapObjectHandler extends CGameSystemHandler {
    public function CMapObjectHandler( ... comps ) {
        super( CSubscribeBehaviour );
    }
    override protected virtual function onSetup() : Boolean {

        system.stage.flashStage.addEventListener( MouseEvent.CLICK, _onMouseClick, false, 0, true );
        return true;
    }

    private function _onMouseClick(event : MouseEvent):void{
        if(!(event.target is Stage)) return;

        var sceneSystem:CSceneSystem = system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var obj:CMap = scene.staticObjectsMap;
        obj.loop(function (key:*, value:*) : void {
            if(value is CCharacter){
                var char:CCharacter = (value as CCharacter);
                if(isInNPC(char.currentGlobalBound,event) && char.currentAnimationClip){
                    var currClipName:String = char.currentAnimationClip.m_sName;
                    if(char.findAnimationClipInfo("Dianji_1") && currClipName != "Dianji_1"){
                        char.playAnimation("Dianji_1",false);
                        char.addNextPlayAnimation(currClipName,true);
                    }
                }
            }
        })
    }

    private function isInNPC(box:CAABBox2,event:MouseEvent):Boolean
    {
        if(box == null) {
            return false;
        }
        var pos:CVector2  = new CVector2(event.stageX, event.stageY);
        var m_pSceneFacade:ISceneFacade = system.stage.getSystem( ISceneFacade ) as ISceneFacade;
        m_pSceneFacade.scenegraph.mainCamera.screenToWorld(pos);
        return box.isCollidedVertex(pos);
    }

}
}
