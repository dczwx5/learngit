//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by auto on 2017/4/28.
 */
package kof.game.common.hero {

import QFLib.Framework.CFramework;

import kof.framework.CAppSystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerHeroData;
import kof.game.scene.ISceneFacade;
import kof.table.PlayerBasic;
import kof.ui.component.CCharacterFrameClip;

import morn.core.components.SpriteBlitFrameClip;

public class CHeroSpriteUtil {
    public static function setSkinByID(system:CAppSystem, rclip:SpriteBlitFrameClip, heroID:int, forceHide:Boolean = false):void {
        if (heroID > 0) {
            var heroData:CPlayerHeroData = (system.stage.getSystem(CPlayerSystem) as CPlayerSystem).playerData.heroList.getHero(heroID);
            setSkin(system, rclip, heroData, forceHide);
        } else {
            setSkin(system, rclip, null, forceHide);
        }

    }
    public static function setSkin(system:CAppSystem, rclip:SpriteBlitFrameClip, playerHeroData:CPlayerHeroData, forceHide:Boolean = false,sAnimationName:String="Idle_1", boLoop : Boolean = true):void{
        var clip:CCharacterFrameClip = rclip as CCharacterFrameClip;
        if (!clip) return ;
        if(!playerHeroData) {
            clip.dataSource = null;
            clip.visible = false;
            clip.framework = null;
            return;
        }

        if (null == clip.framework ) {
            var framework:CFramework = (system.stage.getSystem(ISceneFacade) as ISceneFacade).scenegraph.graphicsFramework;
            clip.framework = framework;
        }
        if (!forceHide) {
            clip.visible = true;
        }
        clip.dataSource = playerHeroData;
        var pPlayerObject : PlayerBasic = playerHeroData.playerBasic;
        if (sAnimationName) {
            clip.animationName = sAnimationName;
            clip.isLoopPlay = boLoop;
        }

        clip.skin = pPlayerObject.SkinName;
    }

    public static function setSkinBySkin(system:CAppSystem, rclip:SpriteBlitFrameClip, data:Object, skinName:String, forceHide:Boolean = false):void{
        var clip:CCharacterFrameClip = rclip as CCharacterFrameClip;
        if (!clip) return ;
        if(skinName == null || skinName.length == 0) {
            clip.dataSource = null;
            clip.visible = false;
            clip.framework = null;
            return;
        }

        if (null == clip.framework ) {
            var framework:CFramework = (system.stage.getSystem(ISceneFacade) as ISceneFacade).scenegraph.graphicsFramework;
            clip.framework = framework;
        }
        if (!forceHide) {
            clip.visible = true;
        }
        clip.dataSource = data;
        clip.skin = skinName;
    }
}
}
