//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2016/9/1.
 */
package kof.game.level.imp {
import QFLib.Framework.CFX;
import QFLib.Framework.CScene;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.level.CLevelManager;
import kof.game.levelCommon.info.entity.CTrunkEntityTriggerPortal;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;

public class CLevelPortalDisplayProcess implements IDisposable, IUpdatable {
    public function CLevelPortalDisplayProcess(levelManager:CLevelManager) {
        _levelManager = levelManager;
    }
    public function dispose() : void {
        clear();
        _levelManager = null;
    }

    public function clear() : void {

    }

    public function update(delta:Number) : void {

    }

    public function show() : void {
        if (_levelManager.levelConfigInfo.portal && _levelManager.levelConfigInfo.portal.length > 0) {
            var sceneSystem:CSceneSystem = _levelManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
            for each (var portal:CTrunkEntityTriggerPortal in _levelManager.levelConfigInfo.portal) {
                var sFxName:String = portal.effectID;
                if ( !sFxName || !sFxName.length ) {
                    continue ;
                }
                var pFX : CFX;
                var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
                pFX = scene.findStaticObject(sFxName) as CFX;
                if (pFX) {
                    pFX.visible = true;
                    pFX.play(true);
                }
            }
        }
    }

    private var _levelManager:CLevelManager;

}
}
