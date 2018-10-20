//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by eddy on 2017/5/31.
 * 俱乐部大厅的基本信息
 */
package kof.game.club.view.clubview {

import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.framework.CViewHandler;
import kof.framework.IDataTable;
import kof.game.club.CClubHandler;
import kof.game.club.CClubManager;
import kof.game.club.data.CClubConst;
import kof.game.club.data.CClubPath;
import kof.game.club.view.CClubIconViewHandler;
import kof.table.ClubConstant;
import kof.table.ClubUpgradeBasic;
import kof.ui.master.club.ClubInfoViewUI;

import morn.core.handlers.Handler;

public class CClubBaseInfoViewHandler extends CViewHandler {

    private var clubInfoViewUI : ClubInfoViewUI;

    public function CClubBaseInfoViewHandler() {
        super();
    }

    public function updateView( clubInfoViewUI : ClubInfoViewUI ):void{
        if( !_pClubManager.selfClubData )
                return;
        this.clubInfoViewUI = clubInfoViewUI;
        clubInfoViewUI.txt_name.text = _pClubManager.selfClubData.name;
        clubInfoViewUI.txt_level.text = _pClubManager.clubLevel + '级';
        clubInfoViewUI.kof_battleValue.num = _pClubManager.selfClubData.battleValue;
        clubInfoViewUI.txt_rank.text = String( _pClubManager.selfClubData.rank );
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
        clubInfoViewUI.txt_member.text = _pClubManager.selfClubData.memberCount + '/' + clubUpgradeBasic.memberCountMax;
        clubInfoViewUI.txt_condition.text = CClubConst.joinConditionStr( _pClubManager.selfClubData.joinCondition ,_pClubManager.selfClubData.levelCondition  ) ;
        clubInfoViewUI.txt_announcement.text = _pClubManager.selfClubData.announcement ;
        clubInfoViewUI.img_icon.url = CClubPath.getBigClubIconUrByID( _pClubManager.selfClubData.clubSignID );

//        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBUPGRADEBASIC );
//        var clubUpgradeBasic : ClubUpgradeBasic =  pTable.findByPrimaryKey( _pClubManager.clubLevel );
//        clubInfoViewUI.pro.value = int(( _pClubManager.selfClubData.fund/clubUpgradeBasic.upgradeExp)*100)/100;
//        clubInfoViewUI.txt_pro.text = _pClubManager.selfClubData.fund + "/" + clubUpgradeBasic.upgradeExp;

        clubInfoViewUI.btn_changeCondition.clickHandler = new Handler( _onChangeCondition );
        clubInfoViewUI.btn_changeIcon.clickHandler = new Handler( _onChangeIcon );
        clubInfoViewUI.btn_changeName.clickHandler = new Handler( _onChangeName );
        clubInfoViewUI.btn_exit.clickHandler = new Handler( _onClubExit );

        clubInfoViewUI.btn_changeIcon.visible =
                clubInfoViewUI.btn_changeName.visible =
                        clubInfoViewUI.btn_changeCondition.visible =
                                clubInfoViewUI.txt_announcement.editable =
                                        _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4;
        _onBuffTips();

    }

    private function _onBuffTips():void{
        var clubUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _pClubManager.clubLevel );
        var nextUpgradeBasic : ClubUpgradeBasic = _pClubManager.getClubUpgradeBasicByLevel( _pClubManager.clubLevel + 1 );
        if(nextUpgradeBasic)
        {
            clubInfoViewUI.box_buff.toolTip =
                    "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>----下一级属性预览----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + nextUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + nextUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + nextUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
        else
        {
            clubInfoViewUI.box_buff.toolTip = "<font color='#FFA500'>----" + _pClubManager.clubLevel + "级俱乐部buff----\n</font>" +
                    "<font color='#00FA9A'>          生命+" + clubUpgradeBasic.buffPropertyValue[0] + "\n" +
                    "          攻击+" + clubUpgradeBasic.buffPropertyValue[1] + "\n" +
                    "          防御+" + clubUpgradeBasic.buffPropertyValue[2] + "\n</font>" +
                    "\n" +
                    "<font color='#FFA500'>已达到最高俱乐部等级\n</font>" +
                    "<font color='#FFA500'>----buff对全员生效----</font>";
        }
    }
    private function _onChangeCondition():void{
        _pClubApplyConditionViewHandler.addDisplay();
    }
    private function _onChangeIcon():void{
        _pClubIconViewHandler.addDisplay();
    }
    private function _onChangeName():void{
        _pClubChangeNameViewHandler.addDisplay();
    }
    private function _onClubExit():void{
        var str : String = '';
        var pTable : IDataTable = _pCDatabaseSystem.getTable( KOFTableConstants.CLUBCONSTANT );
        var clubConstant : ClubConstant =  pTable.findByPrimaryKey(1);
        if( _pClubManager.clubPosition == CClubConst.CLUB_POSITION_4  && _pClubManager.selfClubMemBerList.length >= 2 ){
//            str = "您是<font color='#ff8282'>" + _pClubManager.selfClubData.name + "</font>的会长，确定要退出俱乐部吗？主动退出后" +
//                        "<font color='#ff8282'>24小时内</font>不能申请加入其他俱乐部。";
            str = "很抱歉，您是会长，请先转让会长才能退出俱乐部。";
            uiCanvas.showMsgBox(str );
        } else{
            str = "您确定要退出<font color='#ff8282'>" + _pClubManager.selfClubData.name + "</font>吗？主动退出后" +
                    "<font color='#ff8282'>" + clubConstant.joinOtherClubTimeLimit + "小时内</font>不能申请加入其他俱乐部。";
            uiCanvas.showMsgBox(str,onExitClubRequest );
            function onExitClubRequest():void{
                _pClubHandler.onExitClubRequest( _pClubManager.selfClubData.id );
            }
        }

    }

    private function get _pClubHandler(): CClubHandler{
        return system.getBean( CClubHandler ) as CClubHandler;
    }
    private function get _pClubManager(): CClubManager{
        return system.getBean( CClubManager ) as CClubManager;
    }
    private function get _pClubApplyConditionViewHandler(): CClubApplyConditionViewHandler{
        return system.getBean( CClubApplyConditionViewHandler ) as CClubApplyConditionViewHandler;
    }
    private function get _pClubIconViewHandler(): CClubIconViewHandler{
        return system.getBean( CClubIconViewHandler ) as CClubIconViewHandler;
    }
    private function get _pClubChangeNameViewHandler(): CClubChangeNameViewHandler{
        return system.getBean( CClubChangeNameViewHandler ) as CClubChangeNameViewHandler;
    }
    private function get _pCDatabaseSystem():CDatabaseSystem{
        return system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem;
    }
}
}
