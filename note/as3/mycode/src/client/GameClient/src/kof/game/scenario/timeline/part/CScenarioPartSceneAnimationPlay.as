/**
 * Created by auto on 2016/8/22.
 */
package kof.game.scenario.timeline.part {
import QFLib.Framework.CCharacter;
import QFLib.Framework.CFX;
import QFLib.Framework.CObject;

import kof.framework.CAppSystem;
import kof.game.levelCommon.CLevelLog;
import kof.game.scenario.enum.EScenarioActorType;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;

public class CScenarioPartSceneAnimationPlay extends CScenarioPartBase {
    public function CScenarioPartSceneAnimationPlay(partInfo:CScenarioPartInfo, system:CAppSystem) {
        super (partInfo, system);
    }
    public override function dispose() : void {
        var playObject:CObject = this.getActor() as CObject;
        if (playObject) {
            playObject = null;
        }
    }
    public override function start() : void {
        if (_info.type == EScenarioPartType.SCENE_ANIMATION_PLAY && _info.actorType == EScenarioActorType.SCENE_ANIMATION ||
                _info.type == EScenarioPartType.EFFECT_PLAY && _info.actorType == EScenarioActorType.EFFECT)
        {
            _actionValue = false;

            var anim:String = _info.params["anim"]; // 特效没有
            var loop:Boolean = _info.params["loop"];
            var playTime:int = _info.params["playTime"];
            var posX:int = -1;
            var posY:int = -1;
            var posZ:int = -1;
            if (_info.params.hasOwnProperty("x") && _info.params.hasOwnProperty("y") && _info.params.hasOwnProperty("z")) {
                posX = _info.params["x"];
                posY = _info.params["y"];
                posZ = _info.params["z"];
            }
            var playObject:CObject = this.getActor() as CObject;
            _isLoop = loop;
            if (!playObject) {
                _actionValue = true;
            } else {
                _lastVisible = playObject.enabled;
                _lastX = playObject.position.x;
                _lastY = playObject.position.y;
                _lastZ = playObject.position.z;
                playObject.enabled = true;
                if (-1 != posX && -1 != posY && -1 != posZ) {
                    playObject.setPositionToFrom2D( posX, posY, 0.0, -posZ );
                }

                if (playObject is CCharacter) {
                    // 场景动画
                    var animation:CCharacter = playObject as CCharacter;
                    if (null == animation.findAnimationClipInfo(anim)) {
                        _actionValue = true;
                        CLevelLog.addDebugLog("can not find static Object's animation.. : " +  ", anim : " + anim, true);
                    } else {
                        animation.playState( anim, _isLoop );
                        CLevelLog.addDebugLog("animation state : " + animation.enabled + "," +animation.visible);
                    }
                } else {
                    // 特效
                    playObject.enableViewingCheckAnimation(false);
                    var fx:CFX = playObject as CFX;
                    fx.play(_isLoop, -1.0, 0, 0);
                }
            }

        } else {
            _actionValue = true;
        }
    }

    public override function end() : void {
        // 场景动画, 剧情播放完之后, 会有几种处理情况, 继续播放，还是回复, 待处理
        _actionValue = false;
        var playObject:CObject = this.getActor() as CObject;
        if (playObject) {
            var isStillAction:Boolean = false;
            if (_info.params.hasOwnProperty("stillAction")) {
                isStillAction = _info.params["stillAction"] > 0;
            }
            if (!isStillAction && !playObject.disposed) {
                playObject.enabled = _lastVisible;
                playObject.setPositionTo(_lastX, _lastY, _lastZ);
            }
            playObject = null;
        }
    }

    public override function update(delta:Number) : void {
        super.update(delta);
        if (!_actionValue) {
            var playObject:CObject = this.getActor() as CObject;
            if(playObject == null)return;
            if (playObject is CCharacter) {
                if((playObject as CCharacter).characterObject){
                    if ((playObject as CCharacter).currentAnimationClipTimeLeft <= 0) {
                        // 结束, 非循环
                        _actionValue = true;
                    }
                }
            } else if (playObject is CFX) {
                // 结束, 非循环
                if((playObject as CFX).theObject){
                    if ((playObject as CFX).isPlaying == false){
                        _actionValue = true;
                    }
                }
            }
        }
    }
    public override function isActionFinish() : Boolean {
        return _actionValue;
    }

    private var _lastVisible:Boolean;
    private var _isLoop:Boolean;
    private var _lastX:Number;
    private var _lastY:Number;
    private var _lastZ:Number;

}
}
