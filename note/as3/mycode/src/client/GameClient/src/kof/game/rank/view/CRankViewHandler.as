//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/7/20.
 */
package kof.game.rank.view {

import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.KOFSysTags;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.club.CClubManager;
import kof.game.club.CClubSystem;
import kof.game.club.data.CClubInfoData;
import kof.game.club.data.CClubPath;
import kof.game.common.CLang;
import kof.game.common.CSystemRuleUtil;
import kof.game.common.view.CTweenViewHandler;
import kof.game.player.CPlayerManager;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerData;
import kof.game.player.data.CPlayerHeroData;
import kof.game.rank.CRankEvent;
import kof.game.rank.CRankHandler;
import kof.game.rank.CRankManager;
import kof.game.rank.data.CRankConst;
import kof.game.rank.data.RankData;
import kof.table.ClubUpgradeBasic;
import kof.table.PlayerQuality;
import kof.table.SystemConstant;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.master.rank.RankItemViewUI;
import kof.ui.master.rank.RankViewUI;
import kof.util.CQualityColor;

import morn.core.components.Clip;
import morn.core.components.Component;
import morn.core.components.Dialog;
import morn.core.events.UIEvent;
import morn.core.handlers.Handler;

public class CRankViewHandler extends CTweenViewHandler {

    private var _tabType : int;

    private var _rankViewUI : RankViewUI;

    private var m_pCloseHandler : Handler;

    private var _curRankItemViewUI : RankItemViewUI;

    public function CRankViewHandler( bLoadViewByDefault : Boolean = false ) {
        super( bLoadViewByDefault );
    }
    override public function dispose() : void {
        super.dispose();
        removeDisplay();
        _rankViewUI = null;
    }
    override public function get viewClass() : Array {
        return [ RankViewUI ];
    }
    override protected function get additionalAssets() : Array {
        return [
            "main_fx.swf"
        ];
    }

    override protected function onAssetsLoadCompleted() : void {
        super.onAssetsLoadCompleted();
        this.onInitializeView();
    }

    override protected function onInitializeView() : Boolean {
        if ( !super.onInitializeView() )
            return false;

        if ( !_rankViewUI ) {
            _rankViewUI = new RankViewUI();

            _rankViewUI.closeHandler = new Handler( _onClose );

            _rankViewUI.btn_point.clickHandler = new Handler( pointHandler );
            _rankViewUI.btn_like.clickHandler = new Handler( likeHandler );

            _rankViewUI.list.renderHandler = new Handler( renderItem );
            _rankViewUI.list.selectHandler = new Handler( selectItemHandler );
            _rankViewUI.list.mouseHandler = new Handler( mouseItemHandler );
            _rankViewUI.list.dataSource = [];

            _rankViewUI.btnGronp.selectHandler = new Handler( tabSelectHandler );

            _rankViewUI.btn_left.clickHandler = new Handler(_onPageChange,[_rankViewUI.btn_left]);
            _rankViewUI.btn_right.clickHandler = new Handler(_onPageChange,[_rankViewUI.btn_right]);
            _rankViewUI.btn_allleft.clickHandler = new Handler(_onPageChange,[_rankViewUI.btn_allleft]);
            _rankViewUI.btn_allright.clickHandler = new Handler(_onPageChange,[_rankViewUI.btn_allright]);


            _rankViewUI.item_self.getChildByName('selectBox' ).visible = false;
            var pMaskDisplayObject : DisplayObject ;
            pMaskDisplayObject = _rankViewUI.item_self.maskimg;
            if ( pMaskDisplayObject ) {
                _rankViewUI.item_self.icon_image.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                _rankViewUI.item_self.icon_image.mask = pMaskDisplayObject;
            }
            pMaskDisplayObject  = _rankViewUI.item_self.maskimg_club;
            if ( pMaskDisplayObject ) {
                _rankViewUI.item_self.img_club.cacheAsBitmap = true;
                pMaskDisplayObject.cacheAsBitmap = true;
                _rankViewUI.item_self.img_club.mask = pMaskDisplayObject;
            }
            _pageBtnDisable();

            CSystemRuleUtil.setRuleTips(_rankViewUI.img_tips, CLang.Get("rank_rule"));

        }

        return _rankViewUI;
    }
    private function tabSelectHandler( ...args ):void{
        var page : int = args[1];
        if( page <= 0 )
            page = 1;
        _rankViewUI.item_self.visible = false;
        _rankViewUI.list.dataSource = [];
        _pRankHandler.onRankRequest( args[0] + 1 , page );

        var ary : Array = CRankConst.TITLE_ARY[_rankViewUI.btnGronp.selectedIndex];
        for( var index : int = 0 ; index <= 2 ; index++ ){
            _rankViewUI['txt_title_' + index ].text = ary[index];
        }

        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;

        if( selectedIndex == CRankConst.POWER_RANK ){
            _rankViewUI.clip_desT.index = 1;
            _rankViewUI.btn_point.label = '提升战斗力';
        }else if( selectedIndex == CRankConst.FIGHTER_RANK ){
            _rankViewUI.clip_desT.index = 0;
            _rankViewUI.btn_point.label = '获得格斗家';
        } else if( selectedIndex == CRankConst.CLUB_RANK ){
            _rankViewUI.clip_desT.index = 0;
            _rankViewUI.btn_point.label = '查看俱乐部';
        } else if( selectedIndex == CRankConst.FIGHTER_NUM_RANK ){
            _rankViewUI.clip_desT.index = 1;
            _rankViewUI.btn_point.label = '前往获得';
        }else if( selectedIndex == CRankConst.ROLE_LEVEL_RANK ){
            _rankViewUI.clip_desT.index = 1;
            _rankViewUI.btn_point.label = '提升等级';//剧情副本
        }else if( selectedIndex == CRankConst.ENDLESS_TOWER_RANK ){
            _rankViewUI.clip_desT.index = 0;
            _rankViewUI.btn_point.label = '前往提升';//无尽塔
        }else if( selectedIndex == CRankConst.HERO_TOTAL_STAR_RANK ){
            _rankViewUI.clip_desT.index = 1;
            _rankViewUI.btn_point.label = '前往获得';//招募
        }else if( selectedIndex == CRankConst.ARTIFACT_TOTAL_BATTLE_VALUE_RANK ){
            _rankViewUI.clip_desT.index = 0;
            _rankViewUI.btn_point.label = '提升神器等级';//神器面板
        }


        _rankViewUI.kofnum_power.visible = _rankViewUI.clip_desT.index == 0;
        _rankViewUI.fightScoreFireFx.visible = _rankViewUI.clip_desT.index == 0;
        _rankViewUI.txt_des.visible = _rankViewUI.clip_desT.index == 1;


    }

    private function renderItem(item:Component, idx:int):void {
        if (!(item is RankItemViewUI)) {
            return;
        }
        var rankItemViewUI:RankItemViewUI = item as RankItemViewUI;
        if( !rankItemViewUI.dataSource )
            return;
        rankItemViewUI.lb_ClubMemberCounts.text = "";//仅用于显示公会人数的文本
        var pMaskDisplayObject : DisplayObject;
        pMaskDisplayObject = rankItemViewUI.maskimg;
        if ( pMaskDisplayObject ) {
            rankItemViewUI.icon_image.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            rankItemViewUI.icon_image.mask = pMaskDisplayObject;
        }
        pMaskDisplayObject  = rankItemViewUI.maskimg_club;
        if ( pMaskDisplayObject ) {
            rankItemViewUI.img_club.cacheAsBitmap = true;
            pMaskDisplayObject.cacheAsBitmap = true;
            rankItemViewUI.img_club.mask = pMaskDisplayObject;
        }
        var selectBox : Clip = rankItemViewUI.getChildByName('selectBox') as Clip;
        if( idx % 2 == 0 ){
            rankItemViewUI.box_right.x = 66;
            selectBox.x = 60;
            rankItemViewUI.box_1.x = 104;
            rankItemViewUI.box_2.x = 337;
            rankItemViewUI.img_club.x = rankItemViewUI.maskimg_club.x = 74;
            rankItemViewUI.lb_ClubMemberCounts.x = 223;
        }else{
            rankItemViewUI.box_right.x = 76;
            selectBox.x = 70;
            rankItemViewUI.box_1.x = 94;
            rankItemViewUI.box_2.x = 327;
            rankItemViewUI.img_club.x = rankItemViewUI.maskimg_club.x = 84;
            rankItemViewUI.lb_ClubMemberCounts.x = 213;
        }

        var rankData : RankData;
        var clubInfoData : CClubInfoData;
        if( rankItemViewUI.dataSource is RankData ){
            rankData  = rankItemViewUI.dataSource as RankData ;
            rankItemViewUI.clip_rank.visible = rankData.rank <= 3 ;
            if( rankItemViewUI.clip_rank.visible )
                rankItemViewUI.clip_rank.index = rankData.rank - 1;
            rankItemViewUI.txt_rank.visible = rankData.rank > 3 ;
            if( rankItemViewUI.txt_rank.visible )
                rankItemViewUI.txt_rank.text = String( rankData.rank );
//            rankItemViewUI.txt_name.text = rankData.name;
            rankItemViewUI.txt_level.text = 'LV.' +   rankData.level;
            if( rankData.rank <= 3 )
                rankItemViewUI.clip_bg.index = rankData.rank - 1;
            else
                rankItemViewUI.clip_bg.index = 3;
            rankItemViewUI.txt_rankOut.visible = false;

//            vipInfo( rankItemViewUI , rankData.vipLevel ,_pRankManager.getTxVipInfo( rankData ) );
            _playerSystem.platform.signatureRender.renderSignature(rankData.vipLevel, rankData.platformData, rankItemViewUI.signature, rankData.name);

        }else if( rankItemViewUI.dataSource is CClubInfoData ){
            clubInfoData  = rankItemViewUI.dataSource as CClubInfoData ;
            rankItemViewUI.clip_rank.visible = clubInfoData.rank <= 3 ;
            if( rankItemViewUI.clip_rank.visible )
                rankItemViewUI.clip_rank.index = clubInfoData.rank - 1;
            rankItemViewUI.txt_rank.visible = clubInfoData.rank > 3 ;
            if( rankItemViewUI.txt_rank.visible )
                rankItemViewUI.txt_rank.text = String( clubInfoData.rank );
            rankItemViewUI.txt_level.text = 'LV.' +   clubInfoData.level ;
            if( clubInfoData.rank <= 3 )
                rankItemViewUI.clip_bg.index = clubInfoData.rank - 1;
            else
                rankItemViewUI.clip_bg.index = 3;
            rankItemViewUI.txt_rankOut.visible = false;
            //================================add by Lune 0712==========================================
            //排行榜增加俱乐部人数显示
            var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( clubInfoData.level );
            if(clubUpgradeBasic)
            {
                rankItemViewUI.lb_ClubMemberCounts.text = clubInfoData.memberCount+ "/" + clubUpgradeBasic.memberCountMax;
            }
            //================================add by Lune 0712==========================================
            _playerSystem.platform.signatureRender.renderSignature(0, clubInfoData.platformData, rankItemViewUI.signature, clubInfoData.name);
        }


        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;

        rankItemViewUI.kofnum_value.visible = selectedIndex != CRankConst.FIGHTER_RANK;
        rankItemViewUI.txt_value.visible = selectedIndex == CRankConst.FIGHTER_RANK;

        rankItemViewUI.icon_image.visible = selectedIndex != CRankConst.CLUB_RANK;
        rankItemViewUI.img_club.visible = selectedIndex == CRankConst.CLUB_RANK;

        if( selectedIndex == CRankConst.POWER_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId );
            rankItemViewUI.kofnum_value.num = rankData.value;
        }else if( selectedIndex == CRankConst.FIGHTER_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.heroId );
            var playerHeroData : CPlayerHeroData = _playerData.heroList.getHero( rankData.heroId );

            var qualityLevelValue : int;
            var qualityLevel:PlayerQuality = _heroQualityLevelTable.findByPrimaryKey(rankItemViewUI.dataSource.quality);
            if (!qualityLevel) {
                qualityLevelValue = 0;
            }else{
                qualityLevelValue = int(qualityLevel.qualityColour);
            }
            //这里注意描边的问题
            rankItemViewUI.txt_value.text = "<font color='" + CQualityColor.QUALITY_COLOR_ARY[qualityLevelValue] + "'>" + playerHeroData.heroName + "</font>";
//            rankItemViewUI.txt_value.text = playerHeroData.heroNameWithColor;
        } else if( selectedIndex == CRankConst.CLUB_RANK ){
            rankItemViewUI.img_club.url = CClubPath.getBigClubIconUrByID( clubInfoData.clubSignID );
            rankItemViewUI.kofnum_value.num =  clubInfoData.battleValue ;

        } else if( selectedIndex == CRankConst.FIGHTER_NUM_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
            rankItemViewUI.kofnum_value.num = rankData.value;

        } else if( selectedIndex == CRankConst.ROLE_LEVEL_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
            rankItemViewUI.kofnum_value.num = rankData.value;

        }else if( selectedIndex == CRankConst.ENDLESS_TOWER_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
            rankItemViewUI.kofnum_value.num = rankData.value;

        }else if( selectedIndex == CRankConst.HERO_TOTAL_STAR_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
            rankItemViewUI.kofnum_value.num = rankData.value;

        }else if( selectedIndex == CRankConst.ARTIFACT_TOTAL_BATTLE_VALUE_RANK ){
            rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
            rankItemViewUI.kofnum_value.num = rankData.value;

        }


    }
//    //腾讯 蓝钻 黄钻 游戏中的VIP
//    private function vipInfo( rankItemViewUI : RankItemViewUI , vipLevel : int = 0, vipObj : Object = null ):void{
//        rankItemViewUI.clip_blue.visible =
//                rankItemViewUI.clip_superBlue.visible =
//                        rankItemViewUI.clip_year.visible =
//                                rankItemViewUI.clip_yellow.visible =
//                                        rankItemViewUI.clip_superYellow.visible = false;
//        rankItemViewUI.txt_name.x = 0;
//
//        var txVipFlg : Boolean = true;
//        if( vipObj == null || vipObj.type == 0){
//            txVipFlg = false;
//        }
//        if( txVipFlg ){
//            if( vipObj.subType == 1 ){
//                rankItemViewUI.clip_superBlue.visible = rankItemViewUI.clip_year.visible = true;
//                rankItemViewUI.clip_superBlue.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 40;
//                    rankItemViewUI.txt_name.x = 60;
//                }else {
//                    rankItemViewUI.txt_name.x = 40;
//                }
//
//            }else if( vipObj.subType == 2 ){
//                rankItemViewUI.clip_blue.visible = rankItemViewUI.clip_year.visible = true;
//                rankItemViewUI.clip_blue.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 40;
//                    rankItemViewUI.txt_name.x = 60;
//                }else {
//                    rankItemViewUI.txt_name.x = 40;
//                }
//            }else if( vipObj.subType == 3 ){
//                rankItemViewUI.clip_superBlue.visible = true;
//                rankItemViewUI.clip_superBlue.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 25;
//                    rankItemViewUI.txt_name.x = 45;
//                }else {
//                    rankItemViewUI.txt_name.x = 25;
//                }
//            }else if( vipObj.subType == 4 ){
//                rankItemViewUI.clip_blue.visible = true;
//                rankItemViewUI.clip_blue.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 25;
//                    rankItemViewUI.txt_name.x = 45;
//                }else {
//                    rankItemViewUI.txt_name.x = 25;
//                }
//            }else if( vipObj.subType == 5 ){
//                rankItemViewUI.clip_superYellow.visible = true;
//                rankItemViewUI.clip_superYellow.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 40;
//                    rankItemViewUI.txt_name.x = 60;
//                }else {
//                    rankItemViewUI.txt_name.x = 40;
//                }
//            }else if( vipObj.subType == 6 ){
//                rankItemViewUI.clip_yellow.visible = true;
//                rankItemViewUI.clip_yellow.index = vipObj.level - 1;
//                rankItemViewUI.img_vip.visible = vipLevel > 0;
//                if( vipLevel > 0 ){
//                    rankItemViewUI.img_vip.x = 25;
//                    rankItemViewUI.txt_name.x = 45;
//                }else {
//                    rankItemViewUI.txt_name.x = 25;
//                }
//            }
//        }else{
//            rankItemViewUI.img_vip.visible = vipLevel > 0;
//            if( vipLevel > 0 ){
//                rankItemViewUI.img_vip.x = 0;
//                rankItemViewUI.txt_name.x = 20;
//            }else {
//                rankItemViewUI.txt_name.x = 0;
//            }
//        }
//
//    }

    ////自己的榜单信息////////////////

    private function selfRankInfo():void{
        var rankItemViewUI:RankItemViewUI = _rankViewUI.item_self;
        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;
        if( selectedIndex == CRankConst.CLUB_RANK ){
            rankItemViewUI.dataSource = _pRankManager.selfClubRank;
        }else  {
            rankItemViewUI.dataSource = _pRankManager.selfRank;
        }

        if( rankItemViewUI.dataSource ){
            rankItemViewUI.visible = true;
            var rankData : RankData;
            var clubInfoData : CClubInfoData;
            if( rankItemViewUI.dataSource is RankData ){
                rankData  = rankItemViewUI.dataSource as RankData ;
                rankItemViewUI.clip_rank.visible = ( rankData.rank <= 3 && rankData.rank >= 1 );
                if( rankItemViewUI.clip_rank.visible )
                    rankItemViewUI.clip_rank.index = rankData.rank - 1;
                rankItemViewUI.txt_rank.visible = rankData.rank > 3 ;
                if( rankItemViewUI.txt_rank.visible )
                    rankItemViewUI.txt_rank.text = String( rankData.rank );
                rankItemViewUI.txt_rankOut.visible = rankData.rank <= 0;

//                rankItemViewUI.txt_name.text = rankData.name;
                rankItemViewUI.txt_level.text = 'LV.' +  rankData.level ;

//                vipInfo( rankItemViewUI, rankData.vipLevel, _pRankManager.getTxVipInfo( rankData ) );
                _playerSystem.platform.signatureRender.renderSignature(rankData.vipLevel, rankData.platformData, rankItemViewUI.signature, rankData.name);
            }else if( rankItemViewUI.dataSource is CClubInfoData ){
                clubInfoData  = rankItemViewUI.dataSource as CClubInfoData ;
                rankItemViewUI.clip_rank.visible = ( clubInfoData.rank <= 3 && clubInfoData.rank >= 1 );
                if( rankItemViewUI.clip_rank.visible )
                    rankItemViewUI.clip_rank.index = clubInfoData.rank - 1;
                rankItemViewUI.txt_rank.visible = clubInfoData.rank > 3 ;
                if( rankItemViewUI.txt_rank.visible )
                    rankItemViewUI.txt_rank.text = String( clubInfoData.rank );
                rankItemViewUI.txt_rankOut.visible = clubInfoData.rank <= 0;

//                rankItemViewUI.txt_name.text = clubInfoData.name;
                rankItemViewUI.txt_level.text = 'LV.' +  clubInfoData.level ;

//                vipInfo( rankItemViewUI  );
                _playerSystem.platform.signatureRender.renderSignature(0, clubInfoData.platformData, rankItemViewUI.signature, clubInfoData.name);
            }

            rankItemViewUI.clip_bg.index = 3;
            rankItemViewUI.box_1.x = 104;
            rankItemViewUI.box_2.x = 337;
            rankItemViewUI.clip_bg.visible = false;

            rankItemViewUI.kofnum_value.visible = selectedIndex != CRankConst.FIGHTER_RANK;
            rankItemViewUI.txt_value.visible = selectedIndex == CRankConst.FIGHTER_RANK;

            rankItemViewUI.icon_image.visible = selectedIndex != CRankConst.CLUB_RANK;
            rankItemViewUI.img_club.visible = selectedIndex == CRankConst.CLUB_RANK;

            if( selectedIndex == CRankConst.POWER_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId );
                rankItemViewUI.kofnum_value.num = rankData.value;

            }else if( selectedIndex == CRankConst.FIGHTER_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.heroId );
                var playerHeroData : CPlayerHeroData = _playerData.heroList.getHero( rankData.heroId );
                rankItemViewUI.txt_value.text = playerHeroData.heroNameWithColor;

            } else if( selectedIndex == CRankConst.CLUB_RANK ){
                rankItemViewUI.img_club.url = CClubPath.getBigClubIconUrByID( clubInfoData.clubSignID );
                rankItemViewUI.kofnum_value.num =  clubInfoData.battleValue ;
            }
            else if( selectedIndex == CRankConst.FIGHTER_NUM_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
                rankItemViewUI.kofnum_value.num = rankData.value;

            }else if( selectedIndex == CRankConst.ROLE_LEVEL_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
                rankItemViewUI.kofnum_value.num = rankData.value;

            }else if( selectedIndex == CRankConst.ENDLESS_TOWER_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
                rankItemViewUI.kofnum_value.num = rankData.value;

            }else if( selectedIndex == CRankConst.HERO_TOTAL_STAR_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
                rankItemViewUI.kofnum_value.num = rankData.value;

            }else if( selectedIndex == CRankConst.ARTIFACT_TOTAL_BATTLE_VALUE_RANK ){
                rankItemViewUI.icon_image.url = CPlayerPath.getHeroBigconPath( rankData.headId);
                rankItemViewUI.kofnum_value.num = rankData.value;

            }
            rankItemViewUI.visible = true;
            _rankViewUI.txt_notInClub.visible = false;
        }else{
            rankItemViewUI.visible = false;
            _rankViewUI.txt_notInClub.visible = true;
        }
    }
    private function selectItemHandler( index : int ) : void {
        var rankItemViewUI : RankItemViewUI = _rankViewUI.list.getCell( index ) as RankItemViewUI;
        if ( !rankItemViewUI )
            return;
        if( !rankItemViewUI.dataSource){
            _rankViewUI.txt_name.text =
                    _rankViewUI.img.url =
                            _rankViewUI.txt_likeNum.text =
                                    _rankViewUI.txt_des.text = '';
            _rankViewUI.kofnum_power.visible = false;
            _rankViewUI.btn_like.disabled = true;
            return;
        }

        var rankData : RankData;
        var clubInfoData : CClubInfoData;
        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;
        if( rankItemViewUI.dataSource is RankData ){
            rankData  = rankItemViewUI.dataSource as RankData ;
            if( selectedIndex == CRankConst.POWER_RANK ){
                rankData.clubName ? _rankViewUI.txt_des.text = rankData.clubName : _rankViewUI.txt_des.text = '暂未加入俱乐部';
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }else if( selectedIndex == CRankConst.FIGHTER_RANK ){
                _rankViewUI.kofnum_power.num = rankData.value;
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.heroId );
            }else if( selectedIndex == CRankConst.FIGHTER_NUM_RANK ){
                rankData.clubName ? _rankViewUI.txt_des.text = rankData.clubName : _rankViewUI.txt_des.text = '暂未加入俱乐部';
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }else if( selectedIndex == CRankConst.ROLE_LEVEL_RANK ){
                rankData.clubName ? _rankViewUI.txt_des.text = rankData.clubName : _rankViewUI.txt_des.text = '暂未加入俱乐部';
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }else if( selectedIndex == CRankConst.ENDLESS_TOWER_RANK ){
                _rankViewUI.kofnum_power.num = rankData.power;
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }else if( selectedIndex == CRankConst.HERO_TOTAL_STAR_RANK ){
                rankData.clubName ? _rankViewUI.txt_des.text = rankData.clubName : _rankViewUI.txt_des.text = '暂未加入俱乐部';
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }else if( selectedIndex == CRankConst.ARTIFACT_TOTAL_BATTLE_VALUE_RANK ){
                _rankViewUI.kofnum_power.num = rankData.power;
                _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( rankData.headId );
            }
            _rankViewUI.txt_name.text = rankData.name;
            _rankViewUI.btn_like.disabled = _pRankManager.likeList.indexOf( rankData._id ) != -1;
        }else if( rankItemViewUI.dataSource is CClubInfoData ){
            clubInfoData  = rankItemViewUI.dataSource as CClubInfoData ;
            _rankViewUI.kofnum_power.num = clubInfoData.chairmanInfo.battleValue ;
            _rankViewUI.txt_name.text = clubInfoData.chairmanInfo.name;
            _rankViewUI.img.url = CPlayerPath.getPeakUIHeroFacePath( clubInfoData.chairmanInfo.headID );
            _rankViewUI.btn_like.disabled = _pRankManager.likeList.indexOf( clubInfoData.chairmanInfo.roleID ) != -1;
        }
        if( rankData )
            _rankViewUI.txt_likeNum.text = String( rankData.like );
        else if( clubInfoData )
            _rankViewUI.txt_likeNum.text = String( clubInfoData.like );

        _curRankItemViewUI = rankItemViewUI;

        _onUpdataLikeTips();

    }
    private function _onUpdataLikeTips():void{
        var num : int = _systemConstant.rankLikeLimit - _pRankManager.likeList.length ;
        _rankViewUI.btn_like.toolTip = '剩余点赞次数：'+ num + '\n点赞可获得：金币*1万'  ;
    }

    private function mouseItemHandler( evt:Event,idx : int ) : void {
        var rankItemViewUI : RankItemViewUI = _rankViewUI.list.getCell( idx ) as RankItemViewUI;
        if ( evt.type == MouseEvent.CLICK ) {
            if(rankItemViewUI.dataSource){
                if( rankItemViewUI.dataSource is CClubInfoData )//策划不需要展示俱乐部
                        return;
                _pRankMenuHandler.show( rankItemViewUI );
            }
        }
    }
    private function _onPageChange(...args):void{

        switch ( args[0] ) {
            case _rankViewUI.btn_left:{
                if( _pRankManager.page <= 1 )
                    return;
                _pRankHandler.onRankRequest( _rankViewUI.btnGronp.selectedIndex + 1 ,_pRankManager.page - 1 );
                break
            }
            case _rankViewUI.btn_right:{
                if( _pRankManager.page >= _pRankManager.totalPage )
                    return;
                _pRankHandler.onRankRequest( _rankViewUI.btnGronp.selectedIndex + 1 ,_pRankManager.page + 1 );
                break

            }
            case _rankViewUI.btn_allleft:{
                if( _pRankManager.page <= 1 )
                    return;
                _pRankHandler.onRankRequest( _rankViewUI.btnGronp.selectedIndex + 1 ,1 );
                break

            }
            case _rankViewUI.btn_allright:{
                if( _pRankManager.page >= _pRankManager.totalPage )
                    return;
                _pRankHandler.onRankRequest( _rankViewUI.btnGronp.selectedIndex + 1 ,_pRankManager.totalPage );
                break
            }
        }
    }
    private function _pageBtnDisable():void{
        _rankViewUI.btn_left.disabled =
                _rankViewUI.btn_allleft.disabled = _pRankManager.page <= 1;
        _rankViewUI.btn_right.disabled =
                _rankViewUI.btn_allright.disabled = _pRankManager.page >= _pRankManager.totalPage;
        _rankViewUI.txt_page.text = _pRankManager.page + '/' + _pRankManager.totalPage;
        if( _pRankManager.totalPage <= 0 )
            _rankViewUI.txt_page.text =  '0/0';
    }
    public function get closeHandler() : Handler {
        return m_pCloseHandler;
    }

    public function set closeHandler( value : Handler ) : void {
        m_pCloseHandler = value;
    }

    public function addDisplay( tabType :int  ) : void {
        _tabType = tabType;
        this.loadAssetsByView( viewClass, _showDisplay );
    }

    protected function _showDisplay() : void {
        if ( onInitializeView() ) {
            invalidate();
            callLater( _addToDisplay );
        } else {
            // Show warning, error, etc.
            LOG.logErrorMsg( "Initialized \"" + viewClass + "\" failed by requesting display shown." );
        }
    }
    private function _addToDisplay() : void {
        _addEventListeners();
//        _rankViewUI.btnGronp.selectedIndex = 0;
//        _rankViewUI.btnGronp.callLater(tabSelectHandler,[0,1]);
        _rankViewUI.btnGronp.selectedIndex = _tabType;
        _rankViewUI.btnGronp.callLater( tabSelectHandler, [_tabType , 1] );
    }
    public function removeDisplay() : void {
        closeDialog();
    }

    private function _onClose( type : String ) : void {
        switch ( type ) {
            default:
                if ( this.closeHandler ) {
                    this.closeHandler.execute();
                }
                break;
        }
        _removeEventListeners();
    }
    private function  _onRankDataUpdateHandler( evt : CRankEvent = null ):void{
        if( _rankViewUI.btnGronp.selectedIndex + 1 != _pRankManager.type )
            return;

        _rankViewUI.list.addEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender, false, 0, true );
        _rankViewUI.list.dataSource = _pRankManager.rankList;
        selfRankInfo();
        _pageBtnDisable();
        if ( _rankViewUI && !_rankViewUI.parent ) {
            setTweenData(KOFSysTags.RANKING);
            showDialog(_rankViewUI);
//            uiCanvas.addDialog( _rankViewUI );
        }
    }
    private function _onLikeDataUpdateHandler( evt : CRankEvent = null ):void{
        if ( !_curRankItemViewUI )
            return;
        if( !_curRankItemViewUI.dataSource)
            return;
        _rankViewUI.txt_likeNum.text = String( _curRankItemViewUI.dataSource.like );
        _rankViewUI.btn_like.disabled = true;
        _pCUISystem.showMsgAlert('点赞成功',CMsgAlertHandler.NORMAL );
        _onUpdataLikeTips();
    }
    private function _onListActiveRender( evt : UIEvent ):void{
        _rankViewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender );
        _rankViewUI.list.selectedIndex = 0;
        _rankViewUI.list.callLater( selectItemHandler,[0]);
    }
    private function likeHandler():void{
        if( _pRankManager.likeList.length >= _systemConstant.rankLikeLimit ){
            _pCUISystem.showMsgAlert( '很抱歉，您的点赞次数已使用完，请明日再点赞' );
            return;
        }
        var likeRoleId : int;
        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;
        if( selectedIndex == CRankConst.CLUB_RANK ){
            likeRoleId = (_curRankItemViewUI.dataSource as CClubInfoData).chairmanInfo.roleID;
        }else {
            likeRoleId = (_curRankItemViewUI.dataSource as RankData)._id;
        }
        if( _pRankManager.likeList.indexOf( likeRoleId ) != -1 ){
            _pCUISystem.showMsgAlert( '很抱歉，已经点赞过了' );
            return;
        }

        _pRankHandler.onRankLikeRequest( _rankViewUI.btnGronp.selectedIndex + 1, likeRoleId);

    }
    private function pointHandler():void{
        var bundleCtx : ISystemBundleContext = system.stage.getSystem( ISystemBundleContext ) as ISystemBundleContext;
        var bundle : ISystemBundle;
        var selectedIndex : int = _rankViewUI.btnGronp.selectedIndex + 1;
        if( selectedIndex == CRankConst.POWER_RANK ){
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.ROLE));
        }else if( selectedIndex == CRankConst.FIGHTER_RANK ){
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CARDPLAYER));
        } else if( selectedIndex == CRankConst.CLUB_RANK ){
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.GUILD));
        } else if( selectedIndex == CRankConst.FIGHTER_NUM_RANK ){
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CARDPLAYER));
        }else if( selectedIndex == CRankConst.ROLE_LEVEL_RANK ){
            //剧情副本
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.INSTANCE));
        }else if( selectedIndex == CRankConst.ENDLESS_TOWER_RANK ){
            //无尽塔
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.ENDLESS_TOWER));
        }else if( selectedIndex == CRankConst.HERO_TOTAL_STAR_RANK ){
           //招募
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.CARDPLAYER));
        }else if( selectedIndex == CRankConst.ARTIFACT_TOTAL_BATTLE_VALUE_RANK ){
           //神器面板
            bundle =  bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.ARTIFACT));
        }
        bundleCtx.setUserData( bundle, CBundleSystem.ACTIVATED, true );

        _rankViewUI.close( Dialog.CLOSE );
    }

    private function _addEventListeners():void {
        _removeEventListeners();
        system.addEventListener( CRankEvent.RANK_DATA_UPDATE, _onRankDataUpdateHandler );
        system.addEventListener( CRankEvent.LIKE_DATA_UPDATE, _onLikeDataUpdateHandler );
    }
    private function _removeEventListeners():void{
        system.removeEventListener( CRankEvent.RANK_DATA_UPDATE ,_onRankDataUpdateHandler );
        system.removeEventListener( CRankEvent.LIKE_DATA_UPDATE ,_onLikeDataUpdateHandler );
        if( _rankViewUI ){
            _rankViewUI.list.removeEventListener( UIEvent.ITEM_RENDER ,_onListActiveRender );
        }
    }

    private function get _pRankHandler():CRankHandler{
        return system.getBean( CRankHandler ) as CRankHandler;
    }
    private function get _pRankManager():CRankManager{
        return system.getBean( CRankManager ) as CRankManager;
    }
    private function get _playerSystem() : CPlayerSystem {
        return system.stage.getSystem( CPlayerSystem ) as CPlayerSystem;
    }
    private function get _playerData() : CPlayerData {
        return ( _playerSystem.getBean( CPlayerManager ) as CPlayerManager ).playerData;
    }
    private function get _pCUISystem():CUISystem{
        return system.stage.getSystem( CUISystem ) as CUISystem;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
    private function get _systemConstant() : SystemConstant{
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.SYSTEMCONSTANT );
        var systemConstant : SystemConstant =  pTable.findByPrimaryKey(1);
        return systemConstant;
    }
    private function get _heroQualityLevelTable():IDataTable{
        return  _pCDatabaseSystem.getTable(KOFTableConstants.HERO_TRAIN_QUALITY_LEVEL);
    }
    private function get _pRankMenuHandler():CRankMenuHandler{
        return system.getBean( CRankMenuHandler ) as CRankMenuHandler;
    }
    private function get _pClubManager() : CClubManager {
        return (system.stage.getSystem(CClubSystem) as CClubSystem).getBean( CClubManager ) as CClubManager;
    }

}
}
