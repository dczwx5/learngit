/**
 * Created by auto on 2016/8/4.
 */
package kof.game.scenario.timeline {
import kof.framework.CAppSystem;
import kof.game.scenario.enum.EScenarioPartType;
import kof.game.scenario.info.CScenarioPartInfo;
import kof.game.scenario.timeline.part.CScenarioPartActorAppear;
import kof.game.scenario.timeline.part.CScenarioPartActorHide;
import kof.game.scenario.timeline.part.CScenarioPartActorMove;
import kof.game.scenario.timeline.part.CScenarioPartActorPlayAction;
import kof.game.scenario.timeline.part.CScenarioPartActorPlayNoviceSkill;
import kof.game.scenario.timeline.part.CScenarioPartActorPlayNoviceSpeed;
import kof.game.scenario.timeline.part.CScenarioPartActorPlaySkill;
import kof.game.scenario.timeline.part.CScenarioPartActorScale;
import kof.game.scenario.timeline.part.CScenarioPartActorSpeed;
import kof.game.scenario.timeline.part.CScenarioPartActorTeleportation;
import kof.game.scenario.timeline.part.CScenarioPartActorTopFace;
import kof.game.scenario.timeline.part.CScenarioPartActorTrunTo;
import kof.game.scenario.timeline.part.CScenarioPartAudioPlay;
import kof.game.scenario.timeline.part.CScenarioPartAudioReset;
import kof.game.scenario.timeline.part.CScenarioPartAudioStop;
import kof.game.scenario.timeline.part.CScenarioPartBase;
import kof.game.scenario.timeline.part.CScenarioPartCGAnimation;
import kof.game.scenario.timeline.part.CScenarioPartCamerToTarget;
import kof.game.scenario.timeline.part.CScenarioPartCameraMove;
import kof.game.scenario.timeline.part.CScenarioPartCameraReset;
import kof.game.scenario.timeline.part.CScenarioPartCameraRotation;
import kof.game.scenario.timeline.part.CScenarioPartCameraScale;
import kof.game.scenario.timeline.part.CScenarioPartCameraShake;
import kof.game.scenario.timeline.part.CScenarioPartCameraSpeed;
import kof.game.scenario.timeline.part.CScenarioPartDialogBubbles;
import kof.game.scenario.timeline.part.CScenarioPartDialogPlay;
import kof.game.scenario.timeline.part.CScenarioPartMasterComing;
import kof.game.scenario.timeline.part.CScenarioPartSceneAnimationPlay;
import kof.game.scenario.timeline.part.CScenarioPartSceneNameShow;
import kof.game.scenario.timeline.part.CScenarioPartSceneRoll;
import kof.game.scenario.timeline.part.CScenarioPartScreenBlack;
import kof.game.scenario.timeline.part.CScenarioPartScreenWhite;
import kof.game.scenario.timeline.part.CScenarioPartVideoPlay;
import kof.game.scenario.timeline.part.CScenarioSystemStopPart;
import kof.game.scenario.timeline.part.CScenarioSystemStopPartAll;

public class CScenarioPartCreater {
    public static function createPart(partInfo:CScenarioPartInfo, system:CAppSystem) : CScenarioPartBase {
        switch (partInfo.type) {
            case EScenarioPartType.ACTOR_APPEAR:
                return new CScenarioPartActorAppear(partInfo, system);
            case EScenarioPartType.ACTOR_MOVE:
                return new CScenarioPartActorMove(partInfo, system);
            case EScenarioPartType.ACTOR_PLAY_ACTION:
                return new CScenarioPartActorPlayAction(partInfo, system);
            case EScenarioPartType.ACTOR_TURN_TO:
                return new CScenarioPartActorTrunTo(partInfo, system);
            case EScenarioPartType.ACTOR_HIDE:
                return new CScenarioPartActorHide(partInfo, system);
            case EScenarioPartType.ACTOR_ACTION_SPEED:
                return new CScenarioPartActorSpeed(partInfo, system);
            case EScenarioPartType.ACTOR_SCALE:
                return new CScenarioPartActorScale(partInfo, system);
            case EScenarioPartType.ACTOR_PLAY_SKILL:
                return new CScenarioPartActorPlaySkill(partInfo, system);
            case EScenarioPartType.ACTOR_TELEPORT:
                return new CScenarioPartActorTeleportation( partInfo, system );
            case EScenarioPartType.ACTOR_TOP_FACE:
                return new CScenarioPartActorTopFace( partInfo, system );
            case EScenarioPartType.ACTOR_NOVIECE_SKILL:
            return new CScenarioPartActorPlayNoviceSkill( partInfo, system );
            case EScenarioPartType.ACTOR_NOVIECE_SPEED:
                return new CScenarioPartActorPlayNoviceSpeed( partInfo, system );
            case EScenarioPartType.CAMERA_MOVE:
                return new CScenarioPartCameraMove(partInfo, system);
            case EScenarioPartType.CAMERA_SHAKE:
                return new CScenarioPartCameraShake(partInfo, system);
            case EScenarioPartType.CAMERA_SCALE:
                return new CScenarioPartCameraScale(partInfo, system);
            case EScenarioPartType.CAMERA_SPEED:
                return new CScenarioPartCameraSpeed(partInfo, system);
            case EScenarioPartType.CAMERA_ROTATION:
                return new CScenarioPartCameraRotation(partInfo, system);
            case EScenarioPartType.CAMERA_RESET:
                return new CScenarioPartCameraReset(partInfo, system);
            case EScenarioPartType.CAMERA_TO_TARGET:
                return new CScenarioPartCamerToTarget(partInfo, system);

            case EScenarioPartType.AUDIO_PLAY:
                return new CScenarioPartAudioPlay(partInfo, system);
            case EScenarioPartType.AUDIO_STOP:
                return new CScenarioPartAudioStop(partInfo, system);
            case EScenarioPartType.AUDIO_RESET:
                return new CScenarioPartAudioReset(partInfo, system);

//            case EScenarioPartType.EFFECT_MOVE:
//                return new CScenarioPartEffectMove(partInfo, system);
//            case EScenarioPartType.EFFECT_APPEAR:
//                return new CScenarioPartEffectAppear(partInfo, system);
//            case EScenarioPartType.EFFECT_PLAY:
//                return new CScenarioPartEffectPlay(partInfo, system);
//            case EScenarioPartType.EFFECT_HIDE:
//                return new CScenarioPartEffectHide(partInfo, system);
//            case EScenarioPartType.EFFECT_SPEED:
//                return new CScenarioPartEffectSpeed(partInfo, system);

            case EScenarioPartType.SCENE_ANIMATION_PLAY:
            case EScenarioPartType.EFFECT_PLAY:
                return new CScenarioPartSceneAnimationPlay(partInfo, system);
            case EScenarioPartType.SCENE_ROLL:
                return new CScenarioPartSceneRoll(partInfo, system);
            case EScenarioPartType.CG_ANIMATION:
                return new CScenarioPartCGAnimation(partInfo, system);
            case EScenarioPartType.DIALOG_PLAY:
                return new CScenarioPartDialogPlay(partInfo, system);
            case EScenarioPartType.DIALOG_BUBBLES:
                return new CScenarioPartDialogBubbles(partInfo, system);
            case EScenarioPartType.SCREEN_WHITE:
                return new CScenarioPartScreenWhite(partInfo, system);
            case EScenarioPartType.BLACK_WHITE:
                return new CScenarioPartScreenBlack(partInfo, system);
            case EScenarioPartType.VIDEO_PLAY:
                return new CScenarioPartVideoPlay(partInfo, system);
            case EScenarioPartType.SYSTEM_STOP_PART:
                return new CScenarioSystemStopPart(partInfo, system);
            case EScenarioPartType.SYSTEM_STOP_PART_ALL:
                return new CScenarioSystemStopPartAll(partInfo, system);
            case EScenarioPartType.MASTER_COMING:
                return new CScenarioPartMasterComing(partInfo, system);
            case EScenarioPartType.SCENE_NAME:
                return new CScenarioPartSceneNameShow(partInfo, system);

        }
        return null;
    }
}
}
