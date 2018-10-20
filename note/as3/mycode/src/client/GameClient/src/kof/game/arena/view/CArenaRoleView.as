//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by sprite on 2017/7/27.
 */
package kof.game.arena.view {

import QFLib.Interface.IDisposable;

import kof.framework.CAppSystem;
import kof.game.arena.CArenaHelpHandler;
import kof.game.arena.CArenaManager;
import kof.game.arena.CArenaNetHandler;
import kof.game.arena.CArenaSystem;
import kof.game.arena.data.CArenaBaseData;
import kof.game.arena.data.CArenaRoleData;
import kof.game.arena.event.CArenaEvent;
import kof.game.arena.util.CArenaState;
import kof.game.common.CLang;
import kof.game.common.hero.CHeroSpriteUtil;
import kof.game.common.status.CGameStatus;
import kof.game.instance.enum.EInstanceType;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CEmbattleListData;
import kof.game.player.data.CPlayerHeroData;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;
import kof.ui.component.CCharacterFrameClip;
import kof.ui.master.arena.ArenaRoleViewUI;

import morn.core.components.Box;

import morn.core.components.SpriteBlitFrameClip;
import morn.core.handlers.Handler;

public class CArenaRoleView implements IDisposable{

    private var m_pViewUI:ArenaRoleViewUI;
    private var m_pSystem:CAppSystem;
    private var m_pData:CArenaRoleData;
    private var m_bIsAutoPlay:Boolean;

    public function CArenaRoleView(system:CAppSystem)
    {
        m_pSystem = system;
    }

    public function initialize():void
    {
        if(m_pViewUI)
        {
            clear();
            m_pViewUI.btn_mb.clickHandler = new Handler(_onClickMbHandler);
            m_pViewUI.btn_tz.clickHandler = new Handler(_onClickTzHandler);
        }
    }

    public function addListeners():void
    {
        m_pSystem.addEventListener(CArenaEvent.WorshipSucc, _onWorshipSuccHandler);
    }

    public function removeListeners():void
    {
        m_pSystem.removeEventListener(CArenaEvent.WorshipSucc, _onWorshipSuccHandler);
    }

    public function set data(value:CArenaRoleData):void
    {
        m_pData = value;

        if(m_pData && m_pViewUI)
        {
            m_pViewUI.box_rank.visible = true;
            m_pViewUI.txt_rank.visible = value.rank > 3;
            if(value.rank == 0)
            {
                var hisBestRank:int = (m_pSystem.getHandler(CArenaManager) as CArenaManager).getHisBestRank();
                var myRank:int = (m_pSystem.getHandler(CArenaManager) as CArenaManager).getMyRank();
                m_pViewUI.txt_rank.visible = true;

                if(myRank == 0)
                {
                    m_pViewUI.box_djm.visible = false;
                    m_pViewUI.txt_rank.text = "暂无排名";
                }
                else
                {
                    m_pViewUI.box_djm.visible = true;
                    m_pViewUI.txt_rank.text = hisBestRank.toString();
                }
            }
            else
            {
//                m_pViewUI.box_djm.visible = true;
                m_pViewUI.box_djm.visible = !(value.rank == 1 || value.rank == 2 || value.rank == 3);
                m_pViewUI.txt_rank.text = value.rank.toString();
            }
            m_pViewUI.img_first.visible = value.rank == 1;
            m_pViewUI.img_second.visible = value.rank == 2;
            m_pViewUI.img_three.visible = value.rank == 3;
            m_pViewUI.txt_name.text = value.roleName;

            m_pViewUI.box_top.centerX = 0;
            m_pViewUI.box_rank.centerX = 0;
            m_pViewUI.txt_rank.centerX = 0;

            m_pViewUI.box_role.x = 2;
            m_pViewUI.box_role.y = 127;

            if(_arenaHelp.getHeroIdArr().indexOf(value.displayId) != -1)
            {
                var playerSystem:CPlayerSystem = m_pSystem.stage.getSystem(CPlayerSystem ) as CPlayerSystem;
                var heroData:CPlayerHeroData = playerSystem.playerData.heroList.getHero(value.displayId);
                var clip:CCharacterFrameClip = m_pViewUI.box_role.getChildAt(0) as CCharacterFrameClip;
                CHeroSpriteUtil.setSkin( m_pSystem.stage.getSystem( CUISystem ) as CAppSystem, clip, heroData, false);
                clip.autoPlay = m_bIsAutoPlay;

                if(_arenaHelp.isSelf(value.roleId) && value.displayPos == 2)
                {
                    clip.scaleX = -1;
                }
                else
                {
                    clip.scaleX = 1;
                }

                clip.centerX = 0;

                if(value.rank == 3)
                {
                    m_pViewUI.box_role.y = 137;
                }
                else
                {
                    m_pViewUI.box_role.y = 127;
                }
            }

            m_pViewUI.box_mb.visible = value.rank <= 3 && value.rank > 0 && value.displayPos == 1;
            m_pViewUI.box_tz.visible = value.rank > 3 || value.rank == 0;
            if(value.rank <= 3 && value.displayPos == 2)
            {
                m_pViewUI.box_tz.visible = true;
            }

            if(_arenaHelp.isSelf(value.roleId))
            {
                m_pViewUI.btn_tz.visible = false;
            }
            else
            {
                m_pViewUI.btn_tz.visible = true;
            }

            m_pViewUI.txt_beAdmired.text = value.worshipNum.toString();
            m_pViewUI.clip_combat1.num = value.combat;
            m_pViewUI.clip_combat2.num = value.combat;

            m_pViewUI.box_combat1.centerX = 0;
            m_pViewUI.box_combat2.centerX = 0;
            m_pViewUI.box_mbInfo.centerX = 0;

            var tipsData:Object = {};
            tipsData["roleName"] = m_pData.roleName;

            var heroList:Array = [];
            if(m_pData.heroList)
            {
                for(var i:int = 0; i < m_pData.heroList.length; i++)
                {
                    var heroInfo:Object = m_pData.heroList[i];
                    var heroId:int = heroInfo["heroId"];
                    heroData = (m_pSystem.stage.getSystem(CPlayerSystem ) as CPlayerSystem).playerData.heroList.getHero(heroId) as CPlayerHeroData;

                    var obj:Object = {};

                    obj["intelligence"] = heroData.qualityBaseType;
                    obj["career"] = _arenaHelp.getHeroCareer(heroId);
                    if(_arenaHelp.isSelf(value.roleId))
                    {
                        obj["quality"] = heroData.quality;
                    }
                    else
                    {
                        obj["quality"] = heroInfo["quality"];
                    }
                    obj["heroId"] = heroId;
                    obj["star"] = heroInfo["star"];
                    heroList.push(obj);
                }
            }

            tipsData["heroList"] = heroList;
            m_pViewUI.box_role.toolTip = new Handler( showTips, [m_pViewUI.box_role,[tipsData]] );
        }
        else
        {
            clear();
        }
    }

    /**
     * 物品tips
     * @param item
     */
    public function showTips(item:Box,tipsData:Array):void
    {
        (m_pSystem as CArenaSystem).addTips(CArenaRoleEmbattleTipsView,item,tipsData);
    }

    public function clear():void
    {
        m_pViewUI.box_rank.visible = false;
        m_pViewUI.txt_rank.visible = false;
        m_pViewUI.img_first.visible = false;
        m_pViewUI.img_second.visible = false;
        m_pViewUI.img_three.visible = false;
        m_pViewUI.txt_name.text = "";
        var clip:SpriteBlitFrameClip = m_pViewUI.box_role.getChildAt(0) as SpriteBlitFrameClip;
        CHeroSpriteUtil.setSkin( m_pSystem.stage.getSystem( CUISystem ) as CAppSystem, clip, null, false);
        clip.autoPlay = false;
        clip.scaleX = 1;

        m_pViewUI.box_mb.visible = false;
        m_pViewUI.box_tz.visible = false;
    }

    /**
     * 点击膜拜
     */
    private function _onClickMbHandler():void
    {
        if(CArenaState.isInWorship)
        {
            (m_pSystem.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        if(m_pData)
        {
            (m_pSystem.getHandler(CArenaNetHandler) as CArenaNetHandler).arenaWorshipRequest(m_pData.rank);
        }
    }

    /**
     * 点击挑战
     */
    private function _onClickTzHandler():void
    {
        if(CArenaState.isInChallenge)
        {
            (m_pSystem.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("clientLockTips"));
            return;
        }

        var arenaBaseData:CArenaBaseData = (m_pSystem.getHandler(CArenaManager) as CArenaManager).arenaBaseData;
        if(arenaBaseData)
        {
            var currNum:int = arenaBaseData.challengeNum;
            if(currNum == 0)
            {
                (m_pSystem.getHandler(CArenaBuyTimesViewHandler) as CArenaBuyTimesViewHandler).addDisplay();
                return;
            }
        }

        if(!CGameStatus.checkStatus(m_pSystem))
        {
            return;
        }

        var playerSystem:CPlayerSystem = m_pSystem.stage.getSystem(CPlayerSystem) as CPlayerSystem;
        var emList:CEmbattleListData = playerSystem.playerData.embattleManager.getByType(EInstanceType.TYPE_ARENA);
        if (emList && emList.list.length == 3)
        {
            if(m_pData)
            {
                (m_pSystem as CArenaSystem).currChallengeRank = m_pData.rank;
                (m_pSystem.getHandler(CArenaNetHandler) as CArenaNetHandler).arenaChallengeRequest(m_pData.rank);
            }
        }
        else
        {
            (m_pSystem.stage.getSystem(IUICanvas) as IUICanvas).showMsgAlert(CLang.Get("peak_need_3_hero"));
        }
    }

    private function _onWorshipSuccHandler(e:CArenaEvent):void
    {
        if(m_pData)
        {
            var rank:int = e.data as int;
            if(rank == m_pData.rank)
            {
                (m_pSystem.stage.getSystem(CUISystem) as CUISystem).showMsgAlert(CLang.Get("arena_worship_succ"),CMsgAlertHandler.NORMAL);
                m_pViewUI.txt_beAdmired.text = (m_pData.worshipNum + 1).toString();
                return;
            }
        }
    }

    public function set isAutoPlay(value:Boolean):void
    {
        var clip:CCharacterFrameClip = m_pViewUI.box_role.getChildAt(0) as CCharacterFrameClip;
        if(clip)
        {
            clip.autoPlay = value;
            m_bIsAutoPlay = value;
        }
    }

    public function set viewUI(value:ArenaRoleViewUI):void
    {
        m_pViewUI = value;
    }

    public function get viewUI():ArenaRoleViewUI
    {
        return m_pViewUI;
    }

    private function get _arenaHelp():CArenaHelpHandler
    {
        return m_pSystem.getHandler(CArenaHelpHandler) as CArenaHelpHandler;
    }

    public function dispose():void
    {
        clear();

        m_pData = null;
    }
}
}
