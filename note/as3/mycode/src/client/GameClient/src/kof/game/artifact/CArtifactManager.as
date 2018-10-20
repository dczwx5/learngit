//------------------------------------------------------------------------------
// Copyright (C) 2018 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------------------------
// (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
// Craeted by Tim.Wei 2018-05-25
//----------------------------------------------------------------------------------------------------------------------
package kof.game.artifact {

import flash.utils.setTimeout;

import kof.SYSTEM_ID;
import kof.data.CDatabaseSystem;
import kof.data.CObjectListData;
import kof.data.KOFTableConstants;
import kof.framework.CAbstractHandler;
import kof.framework.IDataTable;
import kof.framework.IDatabase;
import kof.game.KOFSysTags;
import kof.game.artifact.data.CArtifactData;
import kof.game.artifact.data.CArtifactSoulData;
import kof.game.artifact.view.CArtifactViewHandler;
import kof.game.bag.CBagManager;
import kof.game.bag.CBagSystem;
import kof.game.bag.data.CBagData;
import kof.game.bundle.CBundleSystem;
import kof.game.bundle.ISystemBundle;
import kof.game.bundle.ISystemBundleContext;
import kof.game.character.property.CBasePropertyData;
import kof.game.common.CLang;
import kof.game.equipCard.util.CEquipCardUtil;
import kof.game.player.CPlayerSystem;
import kof.game.player.data.CPlayerData;
import kof.game.shop.CShopSystem;
import kof.game.shop.data.CShopItemData;
import kof.game.shop.enum.EShopType;
import kof.game.shop.view.CShopBuyViewHandler;
import kof.table.ArtifactBreakthrough;
import kof.table.ArtifactColour;
import kof.table.ArtifactConstant;
import kof.table.ArtifactSuit;
import kof.ui.CMsgAlertHandler;
import kof.ui.CUISystem;
import kof.ui.IUICanvas;

/**
 * 神器管理器
 * 原来的代码没有对服务器的数据包装（存的都是object），此类实现了包装，需求改动时方便改动一些
 *@author tim
 *@create 2018-05-25 10:31
 **/
public class CArtifactManager extends CAbstractHandler {

    public var artifactListData:CObjectListData;
    public function CArtifactManager() {
        super();
    }

    override protected function onSetup(): Boolean {
        var ret : Boolean = super.onSetup();
        artifactListData = new CObjectListData(CArtifactData, CArtifactData._artifactID);
        artifactListData.databaseSystem = system.stage.getSystem(CDatabaseSystem) as IDatabase;
        return ret;
    }

    public function get m_data() : Array {
        return artifactListData.list;
    }

    public function set m_data( value : Array ) : void {
        artifactListData.updateDataByData(value);
        _updateView();
    }

    private function _updateView():void {
        (system.getBean( CArtifactViewHandler ) as CArtifactViewHandler).update();
        (system as CArtifactSystem).onRedPoint();
    }

    //更新一个神器
    public function update(data:Object):void {
        artifactListData.updateItemData(data);
        _updateView();
    }

    //更新一个神灵
    public function updateSoul(data:Object):void {
        var artifactData:CArtifactData = getArtifactByID(data.artifactID);
        if (artifactData != null) {
                artifactData.soulListData.updateItemData(data);
        }
    }

    //突破一个神灵
    public function breakSoul(artifactID:int, artifactSoulID:int):void {
        var artifactData:CArtifactData = getArtifactByID(artifactID);
        if (artifactData != null) {
            var soul:CArtifactSoulData =  artifactData.getSoulDataById(artifactSoulID)
            soul.isShowBreachResult = true;
        }
    }

    //解锁一个神灵
    public function unLockSoul(artifactID:int, artifactSoulID:int):void {
        var artifactData:CArtifactData = getArtifactByID(artifactID);
        if (artifactData != null) {
            var soul:CArtifactSoulData =  artifactData.getSoulDataById(artifactSoulID);
            if (soul) {
                (system.stage.getSystem( IUICanvas ) as CUISystem).showMsgAlert(CLang.Get("artifact_soul_unlock_success"),  CMsgAlertHandler.NORMAL );//todo
                setTimeout(function():void{
                    (system.getBean( CArtifactViewHandler ) as CArtifactViewHandler).showPurifyView(soul);
                }, 3000);
            }
        }
    }

    public function getArtifactByID( id : int ) : CArtifactData {
        return artifactListData.getByPrimary(id) as CArtifactData;
    }

    //获取神灵数据
    public function getSoulData( artifactID : int, soulID : int ) : CArtifactSoulData {
        var artifactData:CArtifactData = getArtifactByID(artifactID);
        if (artifactData != null) {
            return artifactData.getSoulDataById(soulID);
        }
        return null;
    }

    //神灵属性变化resposeHandler中被调用，用于显示“xx属性 + xxx”
    public function showSoulPropertyChangeMsg( obj : Object ) : void {
        var newSoulData:CArtifactSoulData = new CArtifactSoulData();
        newSoulData.databaseSystem = system.stage.getSystem(CDatabaseSystem) as IDatabase;
        newSoulData.updateDataByData(obj);
        var propertyNameTable : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.PASSIVE_SKILL_PRO );

        var propertyArray : Array = newSoulData.propertyValue;

        var oldPropertyArray : Array = getSoulData( newSoulData.artifactID, newSoulData.artifactSoulID ).propertyValue;
        var len : int = propertyArray.length;
        var value : int;
        var name : String;
        for ( var i : int = 0; i < len; i++ ) {
            value = int( propertyArray[ i ] ) - int( oldPropertyArray[ i ] );
            name = propertyNameTable.findByPrimaryKey( newSoulData.soulCfg[ "propertyID" + (i + 1) ] ).name;
            if (value > 0) {
                (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(name, value, CMsgAlertHandler.NORMAL);
            }
        }
    }

    //神器培养、突破resposeHandler中被调用，用于显示“xx属性 + xxx”
    public function showArtifactPropertyChangeMsg( data : Object ) : Boolean {
        var newArtData:CArtifactData = new CArtifactData();
        newArtData.databaseSystem = system.stage.getSystem(CDatabaseSystem) as IDatabase;
        newArtData.updateDataByData(data);
        var newPropertyArray : Array = newArtData.intensifyCfg.propertyValue;

        var oldArtData : CArtifactData = getArtifactByID(newArtData.artifactID);
        var oldPropertyArray : Array = oldArtData.intensifyCfg.propertyValue;

        var propertyCfg : IDataTable = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem).getTable( KOFTableConstants.PASSIVE_SKILL_PRO );

        var len : int = newPropertyArray.length;
        var value : int;
        var name : String;
        var hasChange:Boolean = false;
        for ( var i : int = 0; i < len; i++ ) {
            value = int( newPropertyArray[i] ) - int( oldPropertyArray[i] );
            name = propertyCfg.findByPrimaryKey( newArtData.baseCfg.propertyID[i] ).name;
            if (value > 0) {
                (system.stage.getSystem(IUICanvas) as CUISystem).showPropMsgAlert(name, value, CMsgAlertHandler.NORMAL);
                hasChange = true;
            }
        }
        return hasChange;
    }

    //返回该神器是否能升级（用于小红点）
    //forMainCityBtn：是否用于主界面按钮的小红点
    //（主界面小红点要求可以升一级才显示，界面内只要可以培养就显示小红点）
    public function canUpgrade(data:CArtifactData, forMainCityBtn:Boolean = true) : Boolean {
        if ( data.isLock ) {
            return data.isCanUnLock;
        }

        var bool : Boolean;
        var _playerData:CPlayerData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        var artifactEnergy: int = _playerData.currency.artifactEnergy;
        bool = data.artifactExp < data.intensifyCfg.upgradeLevelExp;
        bool &&= forMainCityBtn ? artifactEnergy >= data.levelUpCostItemCount : artifactEnergy >= constantCfg.onceConsume;
        return bool;
    }

    //返回神器是否可以突破
    public function canBreak(data:CArtifactData):Boolean {
        var _playerData:CPlayerData = (system.stage.getSystem( CPlayerSystem ) as CPlayerSystem).playerData;
        if (data.isCanBreak && _playerData.teamData.level >= data.getBreakThroughCfg().Level) {
            var breakCfg:ArtifactBreakthrough = data.getBreakThroughCfg();
            var ownNum:int = getOwnItemNum(breakCfg.breakthroughItem);
            var costNum:int = breakCfg.nums;
            return ownNum >= costNum;
        }
        return false;
    }

    public function hasRedPoint() : Boolean {
        var bool : Boolean;
        artifactListData.loopChild(function(item:CArtifactData):void {
            if (canUpgrade(item) || canBreak(item) || item.isAnySoulCanBreak()) {
                bool = true;
            }
        });
        return bool;
    }

    public function getOwnItemNum(itemId:int):int {
        var bagData:CBagData = (system.stage.getSystem(CBagSystem).getBean(CBagManager) as CBagManager).getBagItemByUid(itemId);
        return bagData == null ? 0 : bagData.num;
    }

    //返回指定套装ID的战力
    public function getSuitFighting(a_iSuitId:int):int {
        var databaseSystem:CDatabaseSystem = (system.stage.getSystem( CDatabaseSystem ) as CDatabaseSystem)
        var table:IDataTable = databaseSystem.getTable(KOFTableConstants.ARTIFACTSUIT);
        var a_pSuitCfg:ArtifactSuit = (table.findByPrimaryKey(a_iSuitId) as ArtifactSuit);
        if (a_pSuitCfg == null) {
            return 0;
        }
        var propertyData : CBasePropertyData = new CBasePropertyData();
        propertyData.databaseSystem = databaseSystem;
        for ( var i : int = 0; i < 3; i++ ) {
            var attrName : String = propertyData.getAttrNameEN(a_pSuitCfg.propertyID[i]);
            if ( propertyData.hasOwnProperty( attrName ) ) {
                propertyData[ attrName ] = a_pSuitCfg.propertyValue[i];
            }
        }
        return propertyData.getBattleValue();
    }

    private function _showTipInfo(str:String, type:int):void
    {
        (system.stage.getSystem( IUICanvas ) as IUICanvas).showMsgAlert( str, type );
    }

    //弹出商店快速购买物品界面
    public function showQuickBuyShop(itemId: int, buyNum:int):void
    {
        var shopData:CShopItemData = CEquipCardUtil.getShopData(itemId);
        if(shopData == null)
        {
            _showTipInfo(CLang.Get("playerCard_swpz"),CMsgAlertHandler.WARNING);
            return;
        }

        var buyViewHandler:CShopBuyViewHandler = system.stage.getSystem(CShopSystem).getHandler(CShopBuyViewHandler )
                as CShopBuyViewHandler;
        buyViewHandler.show(0,shopData,buyNum);
    }

    //打开商店
    public function openShop(shopType:int = EShopType.SHOP_TYPE_19):void
    {
        var bundleCtx:ISystemBundleContext = system.stage.getSystem(ISystemBundleContext) as ISystemBundleContext;
        var systemBundle:ISystemBundle = bundleCtx.getSystemBundle(SYSTEM_ID(KOFSysTags.MALL));
        bundleCtx.setUserData(systemBundle, "shop_type", [shopType]);
        bundleCtx.setUserData(systemBundle, CBundleSystem.ACTIVATED, true);
    }

    public function get totalFighing():int {
        var artifactData:CArtifactData;
        var result:int = 0;
        for (var i:int = 0; i < artifactListData.list.length; i++) {
            artifactData = artifactListData.list[i];
            if (!artifactData.isLock) {
                result += artifactData.fighting;
                result += artifactData.soulFighting;
                result += getSuitFighting(artifactData.suitID);
            }
        }
        return result;
    }

    //=============================================配置表获取===================================
    //获取常量表
    public function get constantCfg():ArtifactConstant {
        var artifactConstantTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTCONSTANT);
        var constant:ArtifactConstant = artifactConstantTable.findByPrimaryKey(1) as ArtifactConstant;
        return constant;
    }

    //获取颜色配置 ID:1~7
    public function getColorCfg(ID:int): ArtifactColour {
        var colorTable:IDataTable = (system.stage.getSystem(CDatabaseSystem) as CDatabaseSystem).getTable(KOFTableConstants.ARTIFACTCOLOUR);
        var result:ArtifactColour = colorTable.findByPrimaryKey(ID) as ArtifactColour;
        return result;
    }
}
}
