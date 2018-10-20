/**
 * Created by user on 2016/12/1.
 */
package kof.game.level.imp {
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFX;
import QFLib.Framework.CScene;
import QFLib.Graphics.Character.CAnimationClip;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;

import kof.game.level.CLevelManager;
import kof.game.scene.CSceneRendering;
import kof.game.scene.CSceneSystem;
import QFLib.Framework.CObject;

public class CSceneEffect implements IDisposable, IUpdatable {
    private var _levelManager:CLevelManager;

    public function CSceneEffect(levelManager:CLevelManager) {
        _levelManager = levelManager;
    }

    public function dispose() : void {
        _levelManager = null;
    }
    public function update(delta:Number) : void {

    }

    public function playAnimation(params:String,onStateChangedFun:Function = null) : void {
        var paramList:Array = params.split(",");
        var animName:String = paramList[0];
        var animAction:String = paramList[1];
        var loop:int = paramList[2];
        var playTime:int = paramList[3];

        var sceneSystem:CSceneSystem = _levelManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var arr:Vector.<CObject> = scene.findStaticObjects(animName);
        for each( var obj:CObject in arr){
            if (obj is CCharacter) {
                obj.enabled = true;
                (obj as CCharacter).animationSpeed = 1;
                if(loop){
                    (obj as CCharacter).playAnimation(animAction, true, true, true, 0, false, playTime,onStateChangedFun);
                }
                else{
                    (obj as CCharacter).playAnimation(animAction, false,false,false,0,false,0.0,onStateChangedFun);
                }
            }
        }
    }

    public function stopAnimation(params:String,onStateChangedFun:Function = null):void{
        var paramList:Array = params.split(",");
        var animName:String = paramList[0];

        var sceneSystem:CSceneSystem = _levelManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var obj:CObject = scene.findStaticObject(animName);
        if(obj) {
            if ( obj is CCharacter ) {
                (obj as CCharacter).animationSpeed = 0;
            }
        }
    }

    public function playEffect(params:String,onStateChangedFun:Function = null):void{
        var paramList:Array = params.split(",");
        var animName:String = paramList[0];
        var loop:int = paramList[1];
        var playTime:int = paramList[2];

        var sceneSystem:CSceneSystem = _levelManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var obj:CObject = scene.findStaticObject(animName);
        if(obj){
            if (obj is CFX) {
                obj.enabled = true;
                (obj as CFX).play(loop,playTime);
                if(onStateChangedFun) (obj as CFX).onStopedCallBack = onStateChangedFun;
            }
        }
    }

    public function stopEffect(params:String,onStateChangedFun:Function = null):void{
        var paramList:Array = params.split(",");
        var animName:String = paramList[0];

        var sceneSystem:CSceneSystem = _levelManager.system.stage.getSystem(CSceneSystem) as CSceneSystem;
        var scene:CScene = (sceneSystem.getBean(CSceneRendering) as CSceneRendering).scene;
        var obj:CObject = scene.findStaticObject(animName);
        if(obj) {
            if ( obj is CFX ) {
                (obj as CFX).stop();
            }
        }
    }
}
}