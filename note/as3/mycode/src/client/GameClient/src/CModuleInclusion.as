//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package {

public class CModuleInclusion {
    public function CModuleInclusion() {
    }
}
}

/*package
{

import QFLib.DashBoard.CConsolePage;
import QFLib.DashBoard.CDashBoard;
import QFLib.DashBoard.CDashPage;
import QFLib.DashBoard.IConsoleCommand;
import QFLib.Foundation;
import QFLib.Foundation.CKeyboard;
import QFLib.Foundation.CMap;
import QFLib.Framework.CObject;
import QFLib.Graphics.RenderCore.utils.CGraphicsPage;
import QFLib.Interface.IDisposable;
import QFLib.Interface.IUpdatable;
import QFLib.Math.CVector2;
import QFLib.Math.CVector3;
import QFLib.Utils.PathUtil;

import avmplus.getQualifiedClassName;

import com.greensock.TweenLite;

import kof.SYSTEM_ID;

import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.CAppStage;

import kof.framework.CAppSystem;
import kof.framework.CViewHandler;
import kof.framework.IApplication;
import kof.framework.IConfiguration;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.framework.INetworking;
import kof.game.Tutorial.CTutorHandler;
import kof.game.Tutorial.CTutorSystem;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorData;
import kof.game.Tutorial.battleTutorPlay.CBattleTutorEvent;
import kof.game.Tutorial.battleTutorPlay.IBattleTutorFacade;
import kof.game.audio.IAudio;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.CCharacterDataDescriptor;
import kof.game.character.CFacadeMediator;
import kof.game.character.CSkillList;
import kof.game.character.ai.CAIComponent;
import kof.game.character.ai.CAIEvent;
import kof.game.character.ai.CAIHandler;
import kof.game.character.collision.CCollisionHandler;
import kof.game.character.display.IDisplay;
import kof.game.character.fight.buff.buffentity.CBuffAttModifiedProperty;
import kof.game.character.fight.event.CFightTriggleEvent;
import kof.game.character.fight.skill.CSimulateSkillCaster;
import kof.game.character.fight.skill.CSkillUtil;
import kof.game.character.fight.skill.ESkillSkipType;
import kof.game.character.fight.skillcalc.CFightCalc;
import kof.game.character.fight.skillchain.CCharacterFightTriggle;
import kof.game.character.handler.CPlayHandler;
import kof.game.character.movement.CMovement;
import kof.game.character.property.CCharacterProperty;
import kof.game.character.property.CMonsterProperty;
import kof.game.character.property.interfaces.ICharacterProperty;
import kof.game.character.state.CCharacterActionStateConstants;
import kof.game.character.state.CCharacterInput;
import kof.game.character.state.CCharacterStateBoard;
import kof.game.character.state.CCharacterStateMachine;
import kof.game.common.CLang;
import kof.game.common.system.CAppSystemImp;
import kof.game.common.system.CNetHandlerImp;
import kof.game.common.view.CChildView;
import kof.game.common.view.CRootView;
import kof.game.common.view.CViewBase;
import kof.game.common.view.CViewManagerHandler;
import kof.game.common.view.control.CControlBase;
import kof.game.common.view.event.CViewEvent;
import kof.game.core.CECSLoop;
import kof.game.core.CGameObject;
import kof.game.core.ITransform;
import kof.game.fightui.CFightViewHandler;
import kof.game.fightui.compoment.CInstanceProcessViewHandler;
import kof.game.fightui.compoment.CSkillViewHandler;
import kof.game.instance.CInstanceSystem;
import kof.game.instance.mainInstance.data.CChapterInstanceData;
import kof.game.instance.mainInstance.data.CInstanceData;
import kof.game.instance.event.CInstanceEvent;
import kof.game.level.CLevelSystem;
import kof.game.lobby.CLobbySystem;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.scenario.CScenarioSystem;
import kof.game.scene.CSceneEvent;
import kof.game.scene.CSceneSystem;
import kof.game.scene.ISceneFacade;
import kof.message.GM.GMCommandRequest;
import kof.table.InstanceContent;
import kof.table.PlayerSkill;
import kof.table.Skill;
import kof.ui.demo.FightUI;
import kof.ui.demo.SkillItemUI;
import kof.ui.gm.GMMenuItemUI;
import kof.ui.gm.GMPropertyViewUI;
import kof.ui.gm.GMViewUI;
import kof.ui.gm.GMenuUI;
import kof.ui.master.BattleTutor.BTAbilityUI;
import kof.ui.master.BattleTutor.BTDefense1UI;
import kof.ui.master.BattleTutor.BTDefense2UI;
import kof.ui.master.BattleTutor.BTDescUI;
import kof.ui.master.BattleTutor.BTKeyDescUI;
import kof.ui.master.BattleTutor.BTKeyboardUI;
import kof.ui.master.BattleTutor.BTMaskUI;
import kof.ui.master.BattleTutor.BTMultiKeyDescUI;
import kof.ui.master.BattleTutor.BTMultiKeyPressUI;
import kof.ui.master.BattleTutor.BTPromptUI;
import kof.ui.master.BattleTutor.BTQEUI;
import kof.ui.master.BattleTutor.BTQTEUI;
import kof.ui.master.BattleTutor.BTSkillItemUI;
import kof.util.CAssertUtils;

import morn.core.components.Box;
import morn.core.components.Button;
import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.components.FrameClip;
import morn.core.components.Image;
import morn.core.components.TextInput;
import morn.core.handlers.Handler;

//
    //
    //
    public class CModuleInclusion
    {
        public function CModuleInclusion()
        {
            // for battle tutor module
            CMap;
            CAppSystem;
            CBattleTutorData;
            CBattleTutorEvent;
            IBattleTutorFacade;
            TweenLite;
            CTutorSystem;
            ITransform;
            CChapterInstanceData;
            CInstanceData;
            CInstanceEvent;
            CSceneEvent;
            ISceneFacade;
            InstanceContent;
            FightUI;
            CAssertUtils;
            Box;
            Component;
            CFacadeMediator;
            CMovement;
            CGameObject;
            getQualifiedClassName;
            Handler;
            PathUtil;
            CVector2;
            CVector3;
            KOFTableConstants;
            IDataTable;
            IDatabase;
            CCharacterDataDescriptor;
            CAIHandler;
            IDisplay;
            CFightTriggleEvent;
            CSimulateSkillCaster;
            CFightCalc;
            CCharacterFightTriggle;
            CPlayHandler;
            ICharacterProperty;
            CCharacterActionStateConstants;
            CCharacterInput;
            CCharacterStateMachine;
            CSceneSystem;
            PlayerSkill;
            CCharacterProperty;
            CCharacterStateBoard;
            CPlayerData;
            CKeyboard;
            IApplication;
            IAudio;
            CECSLoop;
            CInstanceSystem;
            CLevelSystem;
            CPlayerSystem;
            CScenarioSystem;
            CObject;
            CFightViewHandler;
            CInstanceProcessViewHandler;
            CSkillViewHandler;
            CLobbySystem;
            SkillItemUI;
            BTDescUI;
            Button;
            Image;
            BTKeyDescUI;
            BTPromptUI;
            BTMultiKeyDescUI;
            BTSkillItemUI;
            BTMultiKeyPressUI;
            Clip;
            CSkillUtil;
            CLang;
            BTKeyboardUI;
            FrameClip;
            CAIEvent;
            BTAbilityUI;
            CViewHandler;
            Dialog;
            BTDefense1UI;
            BTDefense2UI;
            BTMaskUI;
            BTQEUI;
            BTQTEUI;
            CPlayerPath;
            Skill;

            // for GMClient
            CAppStage;
            CNetHandlerImp;
            CDashBoard;
            CGraphicsPage;
            IUpdatable;
            CAppSystemImp;
            CViewBase;
            CViewManagerHandler;
            GMCommandRequest;
            IConfiguration;
            Foundation;
            CConsolePage;
            IConsoleCommand;
            CAbstractHandler;
            INetworking;
            IDisposable;
            SYSTEM_ID;
            ISystemBundle;
            ISystemBundleContext;
            CTutorHandler;
            CAIComponent;
            CCollisionHandler;
            ESkillSkipType;
            CMonsterProperty;
            CControlBase;
            CViewEvent;
            CSkillList;
            CDashPage;
            CRootView;
            GMMenuItemUI;
            GMenuUI;
            CBuffAttModifiedProperty;
            GMPropertyViewUI;
            TextInput;
            GMViewUI;
            CChildView;
        }
    }

}*/
