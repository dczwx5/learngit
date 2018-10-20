//------------------------------------------------------------------------------
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 *(C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by yili(guoyiligo@qq.com) on 2017/10/30.
 * Time: 11:29
 */
package kof.game.clubBoss.view {

import flash.events.Event;
import flash.events.MouseEvent;
import flash.utils.Dictionary;

import kof.data.CDataTable;
import kof.data.CDatabaseSystem;
import kof.data.KOFTableConstants;
import kof.game.bag.data.CBagData;
import kof.game.clubBoss.datas.CCBDataManager;
import kof.game.clubBoss.enums.EBossStateType;
import kof.game.clubBoss.enums.EClubBossEventType;
import kof.game.common.CLang;
import kof.game.player.CPlayerSystem;
import kof.game.player.config.CPlayerPath;
import kof.game.player.data.CPlayerHeroData;
import kof.table.ClubBossBase;
import kof.table.Item;
import kof.table.PlayerBasic;
import kof.ui.imp_common.HeroItemSmallUI;
import kof.ui.master.JueseAndEqu.RoleItem03UI;
import kof.ui.master.JueseAndEqu.RolePieceItemUI;
import kof.ui.master.clubBoss.CBBossItemUI;
import kof.ui.master.clubBoss.CBBossTipUI;
import kof.ui.master.clubBoss.CBMainUI;
import kof.ui.master.messageprompt.GoodsItemUI;

import morn.core.components.Component;
import morn.core.handlers.Handler;
import morn.core.utils.ObjectUtils;

/**
 * @author yili(guoyiligo@qq.com)
 * 2017/10/30
 */
public class CBossItemView {
    private var _mainView : CCBMainView = null;
    private var _mainUI : CBMainUI = null;
    private var _currentSelectBossId : Number = 0;
    private var _dic_bossItemToCBBase : Dictionary = new Dictionary();
    private var _cbDataManager : CCBDataManager = null;
    private var _currentHeroId : Number = 0;
    private var _pBossItemToHeroIdDic:Dictionary = new Dictionary();
    private var _pHeroItemToBossIndex:Dictionary = new Dictionary();
    private var _cbTips : CCBItemTips = null;
    private var _cbHeroTips:CCBHeroTips=null;
    private var _cbBaseArr : Array = [];
    private var _playerBasicTabel : CDataTable=null;
    //tip
    private var _bossTips:CBBossTipUI = null;

    public function get currentHeroId() : Number {
        return _currentHeroId;
    }

    public function get currentSelectBossId() : Number {
        return _currentSelectBossId;
    }

    public function CBossItemView( mainView : CCBMainView ) {
        this._mainView = mainView;
        this._mainUI = mainView.mainUI;
        this._cbDataManager = mainView.system.getBean( CCBDataManager ) as CCBDataManager;
        this._cbDataManager.addEventListener( EClubBossEventType.UPDATE_MAINUI, _updateUI );
        _cbTips = mainView.cbTips;
        _cbHeroTips = new CCBHeroTips();
        _bossTips = new CBBossTipUI();
        _init();
    }

    private function _showBossTip(bossID:int):void{
        if(bossID<=0||bossID>_cbBaseArr.length)return;
        if(_cbDataManager.vec_BossInfo.length==0)return;
        var cbBase : ClubBossBase = _cbBaseArr[ bossID-1 ] as ClubBossBase;
        _bossTips.bossName.url = "icon/role/ui/name/name_"+cbBase.heroId+".png"; //格斗家名字
        _bossTips.txt1.text = cbBase.background;
        _bossTips.txt2.text = cbBase.strategy;
        _bossTips.itemList.renderHandler = _bossTips.itemList.renderHandler || new Handler(_renderRecommend);
        var arr:Array = cbBase.recommend.split(",");
        _bossTips.itemList.dataSource = arr;
        _bossTips.firstKillClubName.text = _cbDataManager.vec_BossInfo[bossID-1].clubName;
        _bossTips.killName.text = _cbDataManager.vec_BossInfo[bossID-1].username;

        App.tip.addChild(_bossTips);
    }

    private function _renderRecommend(comp:Component,idx:int):void{
        var roleItem : RoleItem03UI = comp as RoleItem03UI;
        var heroID:int = int(comp.dataSource);
        roleItem.icon_image.url = CPlayerPath.getUIHeroIconMiddlePath( heroID );
        roleItem.icon_image.mask = roleItem.hero_icon_mask;
        roleItem.clip_intell.visible = false;
        roleItem.box_star.visible = false;
//        roleItem.clip_career.index = PlayerBasic(_playerBasicTabel.findByPrimaryKey(heroID)).Profession;
        roleItem.clip_career.visible = false;
    }

    private function _init() : void {
        //初始化表
        var dataBaseSys : CDatabaseSystem = this._mainView.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var cbBaseTabel : CDataTable = dataBaseSys.getTable( KOFTableConstants.CLUBBOSSBASE ) as CDataTable;
        _cbBaseArr = cbBaseTabel.toArray();

        _playerBasicTabel = dataBaseSys.getTable( KOFTableConstants.PLAYER_BASIC ) as CDataTable;
        for ( var i : int = 0; i < _cbBaseArr.length; i++ ) {
            var cbBase : ClubBossBase = _cbBaseArr[ i ] as ClubBossBase;
            var bossItemUI : CBBossItemUI = this._mainUI[ "bossItem" + (i + 1) ] as CBBossItemUI;
            bossItemUI.bossHeadIcon.url = cbBase.headicon + cbBase.monsterId + ".png";
//            bossItemUI.pro1.index = PlayerBasic(_playerBasicTabel.findByPrimaryKey(cbBase.heroId)).Profession;
            bossItemUI.pro1.visible = false;
            (_mainView.system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(bossItemUI.pro1);
            //推荐职业
//            bossItemUI.pro2.index = cbBase.character-1;
            bossItemUI.pro2.visible = bossItemUI.txt_pro2.visible = false;
            (_mainView.system.stage.getSystem(CPlayerSystem) as CPlayerSystem).showCareerTips(bossItemUI.pro2);

            bossItemUI.addEventListener( MouseEvent.CLICK, _selectBoss );
            bossItemUI.heroIconView.btn_add.addEventListener(MouseEvent.CLICK,_openEmbattleView);
            bossItemUI.heroIconView.item.addEventListener(MouseEvent.CLICK, _unloadHero);
            bossItemUI.heroIconView.item.toolTip = new Handler(_showHeroTips,[CLang.Get("unloadEmbattle")]);
            bossItemUI.heroIconView.base_quality_clip.visible = false;
            bossItemUI.btn.toolTip = new Handler(_showBossTip,[cbBase.bossId]);
            _pHeroItemToBossIndex[bossItemUI.heroIconView.item]=i+1;
            _dic_bossItemToCBBase[ bossItemUI ] = cbBase;
        }
        this._mainUI.bossItem1.selectedImg.visible = true;
        this._mainUI.boss.url = (cbBaseTabel.findByPrimaryKey( 1 ) as ClubBossBase).roleicon + "role_" + (cbBaseTabel.findByPrimaryKey( 1 ) as ClubBossBase).heroId + ".png";
        _currentSelectBossId = (cbBaseTabel.findByPrimaryKey( 1 ) as ClubBossBase).bossId;
        //预览奖励，默认选中可以打的那个boss
        this._mainUI.rewardPreviewList.renderHandler = new Handler(_renderRewardItem);
        _setRewardDataSource(0);//设置当前选中boss的奖励预览
    }

    private function _showHeroTips(str:String):void{
        _cbHeroTips.showRuleTips(str);
    }

    private function _setBossBlood(index:int):void{
        if(_cbDataManager.vec_BossInfo.length==0)return;
        var state : int = _cbDataManager.vec_BossInfo[index].state;
        if ( state == EBossStateType.READY||state == EBossStateType.FIGHTING) {
            this._mainUI.bloodBox.visible = true;
            this._mainUI.bloodProgress.value = _cbDataManager.vec_BossInfo[index].hp/_cbDataManager.vec_BossInfo[index].maxHP;
            this._mainUI.challengeBtn.visible = true;
        } else if ( state == EBossStateType.BEAT ) {
            this._mainUI.bloodBox.visible = false;
            this._mainUI.challengeBtn.visible = false;
        } else if ( state == EBossStateType.NOT_OPEN ) {
            this._mainUI.bloodBox.visible = false;
            this._mainUI.challengeBtn.visible = true;
        }
    }

    private function _unloadHero(e:MouseEvent):void{
        var index:int = _pHeroItemToBossIndex[e.currentTarget as HeroItemSmallUI];
        var state:int =  _cbDataManager.vec_BossInfo[ index-1 ].state;
        if(state==EBossStateType.BEAT){
            this._mainView.showPrompt( 2810 ); //已击败不能下阵
        }else{
            this._mainView.embattleView.unloadHero(index);
        }
    }
    //打开出战编制
    private function _openEmbattleView(e:MouseEvent):void{
        this._mainView.opneEmBattleFunc();
    }

    private function _setRewardDataSource(index:int):void{
        var rewardStr:String = (_cbBaseArr[index] as ClubBossBase).previewReward;
        var rewardIDArr:Array = rewardStr.split(",");
        var itemDataArr:Array=[];
        for(var j:int=0;j<rewardIDArr.length;j++){
            var itemID:Number = Number(rewardIDArr[j]);
            var itemData:Item = this._cbDataManager.getItemTableData(itemID);
            itemDataArr.push(itemData);
        }
        this._mainUI.rewardPreviewList.dataSource = itemDataArr;
    }

    private function _renderRewardItem(comp:Component,idx:int):void{
        var itemUI:RolePieceItemUI = comp as RolePieceItemUI;
        var data:Item = itemUI.dataSource as Item;
        if(!data)return;
        itemUI.qualityClip.index = data.quality;
        itemUI.icon_img.url = data.smalliconURL+".png";
        itemUI.clip_eff.visible = data.effect;

        var goods : GoodsItemUI = new GoodsItemUI();
        goods.img.url = data.bigiconURL + ".png";
        goods.quality_clip.index = data.quality;
        var bagData : CBagData = _cbDataManager.getItemNuForBag( data.ID );
        if ( bagData ) {
            goods.txt.text = bagData.num + "";
        } else {
            goods.txt.text = "0";
        }
        itemUI.toolTip = new Handler( _showItemTips, [ goods, data.ID ] );
    }

    private function _showItemTips( goods : GoodsItemUI, id : int ) : void {
        _cbTips.showItemTips( goods, this._cbDataManager.getItemTableData( id ), this._cbDataManager.getItemData( id ) );
    }

    private function _selectBoss( e : MouseEvent ) : void {
        var cbBossItem : CBBossItemUI = e.currentTarget as CBBossItemUI;
        for ( var i : int = 1; i < 6; i++ ) {
            if ( this._mainUI[ "bossItem" + i ] == cbBossItem ) {
                var cbBase : ClubBossBase = _dic_bossItemToCBBase[ cbBossItem ] as ClubBossBase;
                _currentSelectBossId = cbBase.bossId;
                _currentHeroId = _pBossItemToHeroIdDic[cbBossItem];
                _setBossState( _currentSelectBossId );
                _setRewardDataSource(i-1);
                _setBossBlood(i-1);
                break;
            }
        }
    }

    private function _getCBBase( index : int ) : ClubBossBase {
        var dataBaseSys : CDatabaseSystem = this._mainView.system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem;
        var cbBaseTabel : CDataTable = dataBaseSys.getTable( KOFTableConstants.CLUBBOSSBASE ) as CDataTable;
        return cbBaseTabel.findByPrimaryKey( index ) as ClubBossBase;
    }

    private function _setBossState( index : int ) : void {
        var bossItemUI : CBBossItemUI = null;
        for ( var i : int = 0; i < 5; i++ ) {
            bossItemUI = this._mainUI[ "bossItem" + (i + 1) ] as CBBossItemUI;
            bossItemUI.selectedImg.visible = false;
        }
        bossItemUI = this._mainUI[ "bossItem" + (index) ] as CBBossItemUI;
        bossItemUI.selectedImg.visible = true;
        this._mainUI.boss.url = _getCBBase( index ).roleicon + "role_" + _getCBBase( index ).heroId + ".png";
        _mainUI.challengeBtn.visible=true;
    }

    public function setHero( heroId : Number ) : void {
        for ( var i : int = 0; i < 5; i++ ) {
            var bossItemUI : CBBossItemUI = this._mainUI[ "bossItem" + (i + 1) ] as CBBossItemUI;
            if ( bossItemUI.selectedImg.visible ) {
                if(_currentHeroId==heroId){
                    _currentHeroId = 0;
                    unloadHero(heroId);//下阵
                }else{
                    bossItemUI.heroIconView.item.icon_image.url = CPlayerPath.getHeroSmallIconPath( heroId );
                    bossItemUI.heroIconView.item.icon_image.mask = bossItemUI.heroIconView.item.mask;
                    bossItemUI.heroIconView.btn_add.visible = false;
                    bossItemUI.heroIconView.base_quality_clip.visible = true;
                    bossItemUI.heroIconView.base_quality_clip.index = _getHeroQuality(heroId);
                    _currentHeroId = heroId;
                    _pBossItemToHeroIdDic[bossItemUI]=heroId;
                }
            }
        }
    }

    private function unloadHero(heroId : Number):void{
        for(var key:CBBossItemUI in _pBossItemToHeroIdDic){
            if(_pBossItemToHeroIdDic[key] == heroId){
                key.heroIconView.item.icon_image.url = null;
                key.heroIconView.btn_add.visible = true;
                key.heroIconView.base_quality_clip.visible = false;
                delete _pBossItemToHeroIdDic[key];
            }
        }
    }

    private function _updateUI( e : Event ) : void {
        var len : int = _cbDataManager.vec_BossInfo.length;
        for ( var i : int = 0; i < len; i++ ) {
            var bossItemUI : CBBossItemUI = this._mainUI[ "bossItem" + (i + 1) ] as CBBossItemUI;
            var state : int = _cbDataManager.vec_BossInfo[ i ].state;
            if ( state == EBossStateType.READY || state == EBossStateType.FIGHTING ) {
                bossItemUI.killImg.visible = false;
                bossItemUI.notOpen.visible = false;
                ObjectUtils.gray(bossItemUI.mcBox,false);
//                this._mainView.canChallengeBossId = i+1;
            } else if ( state == EBossStateType.BEAT ) {
                bossItemUI.killImg.visible = true;
                bossItemUI.notOpen.visible = false;
                ObjectUtils.gray(bossItemUI.mcBox,true);
            } else if ( state == EBossStateType.NOT_OPEN ) {
                bossItemUI.killImg.visible = false;
                bossItemUI.notOpen.visible = true;
                ObjectUtils.gray(bossItemUI.mcBox,false);
            }
            var heroId:int=_cbDataManager.vec_BossInfo[ i ].heroId;
            if(heroId>0){
                bossItemUI.heroIconView.item.icon_image.url = CPlayerPath.getHeroSmallIconPath( heroId );
                bossItemUI.heroIconView.item.icon_image.mask = bossItemUI.heroIconView.item.mask;
                bossItemUI.heroIconView.btn_add.visible = false;
                bossItemUI.heroIconView.base_quality_clip.visible = true;
                bossItemUI.heroIconView.base_quality_clip.index = _getHeroQuality(heroId);
            }else{
                bossItemUI.heroIconView.item.icon_image.url = null;
                bossItemUI.heroIconView.item.icon_image.mask = bossItemUI.heroIconView.item.mask;
                bossItemUI.heroIconView.btn_add.visible = true;
                bossItemUI.heroIconView.base_quality_clip.visible = false;
            }
            bossItemUI.lvlabel.text = "Lv."+_cbDataManager.vec_BossInfo[ i ].bossLevel+"";
            _pBossItemToHeroIdDic[bossItemUI] = heroId;
            if(_currentSelectBossId==i+1){
                _currentHeroId = heroId;
            }
            _setBossBlood(_currentSelectBossId-1);//设置boss血量
        }
    }

    public function getCurSelectBossItemForState():int{
        return _cbDataManager.vec_BossInfo[ _currentSelectBossId-1 ].state;
    }

    private function _getHeroQuality(heroID:Number):int{
        var arr:Array = _cbDataManager.playerData.heroList.list;
        for(var i:int=0;i<arr.length;i++){
            var data:CPlayerHeroData = arr[i];
            if(data.ID==heroID){
                return data.qualityBaseType;
            }
        }
        return 0;
    }
}
}
