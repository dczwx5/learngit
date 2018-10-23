var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var __extends = this && this.__extends || function __extends(t, e) { 
 function r() { 
 this.constructor = t;
}
for (var i in e) e.hasOwnProperty(i) && (t[i] = e[i]);
r.prototype = e.prototype, t.prototype = new r();
};
var CardSkinWindowMediator = (function (_super) {
    __extends(CardSkinWindowMediator, _super);
    function CardSkinWindowMediator() {
        var _this = _super.call(this) || this;
        _this.source = [];
        _this.skinCollection = new eui.ArrayCollection([]);
        return _this;
    }
    CardSkinWindowMediator.prototype.onViewOpen = function () {
        var view = this.view;
        var skinMng = this.getModel(PlayerModel).skinMng;
        view.btn_close.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onTap, this);
        view.dGroup_cardSkins.addEventListener(eui.ItemTapEvent.ITEM_TAP, this.onTapItem, this);
        skinMng.dg_SkinChanged.register(this.onSkinChanged, this);
        var source = this.source;
        source.length = 0;
        var cfg = app.config.getConfig(SkinConfig);
        var skinData;
        var playerLv = this.getModel(PlayerModel).lv;
        var totalCount = 0;
        var unlockedCount = 0;
        for (var idx in cfg) {
            skinData = { skinCfg: cfg[idx], playerLv: playerLv, isSelected: skinMng.skinId.toString() == idx };
            if (skinData.isSelected) {
                this.selectedItem = skinData;
            }
            source.push(skinData);
            totalCount++;
            if (playerLv >= skinData.skinCfg.unlockLv) {
                unlockedCount++;
            }
            view.lb_unlockedCount.text = unlockedCount + "/" + totalCount;
        }
        this.skinCollection.source = source;
        view.dGroup_cardSkins.dataProvider = this.skinCollection;
    };
    CardSkinWindowMediator.prototype.onViewClose = function () {
        var view = this.view;
        var skinMng = this.getModel(PlayerModel).skinMng;
        view.btn_close.removeEventListener(egret.TouchEvent.TOUCH_TAP, this.onTap, this);
        view.dGroup_cardSkins.removeEventListener(eui.ItemTapEvent.ITEM_TAP, this.onTapItem, this);
        skinMng.dg_SkinChanged.unregister(this.onSkinChanged);
        view.dGroup_cardSkins.dataProvider = null;
        this.skinCollection.source = null;
        this.selectedItem = null;
    };
    CardSkinWindowMediator.prototype.onTap = function (e) {
        var view = this.view;
        switch (e.currentTarget) {
            case view.btn_close:
                this.sendMsg(create(CardSkinModuleMsg.CloseCardSkinWindow));
                break;
        }
    };
    CardSkinWindowMediator.prototype.onTapItem = function (e) {
        var skinData = e.itemRenderer.data;
        var skinCfgId = skinData.skinCfg.Id;
        if (skinData.playerLv >= skinData.skinCfg.unlockLv) {
            var skinMng = this.getModel(PlayerModel).skinMng;
            skinMng.skinId = skinCfgId;
            this.sendMsg(create(CardSkinModuleMsg.ChangeSkin).init({ skinCfg: skinData.skinCfg }));
        }
    };
    CardSkinWindowMediator.prototype.onSkinChanged = function (data) {
        this.selectedItem.isSelected = false;
        this.skinCollection.replaceItemAt(this.selectedItem, this.skinCollection.getItemIndex(this.selectedItem));
        this.selectedItem = { isSelected: true, skinCfg: app.config.getConfig(SkinConfig)[data.skinId], playerLv: this.getModel(PlayerModel).lv };
        var idx;
        for (var i = 0, l = this.source.length; i < l; i++) {
            if (this.source[i].skinCfg.Id == data.skinId) {
                idx = i;
                break;
            }
        }
        this.skinCollection.replaceItemAt(this.selectedItem, idx);
    };
    Object.defineProperty(CardSkinWindowMediator.prototype, "viewClass", {
        get: function () {
            return SkinWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardSkinWindowMediator.prototype, "openViewMsg", {
        get: function () {
            return CardSkinModuleMsg.OpenCardSkinWindow;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(CardSkinWindowMediator.prototype, "closeViewMsg", {
        get: function () {
            return CardSkinModuleMsg.CloseCardSkinWindow;
        },
        enumerable: true,
        configurable: true
    });
    return CardSkinWindowMediator;
}(ViewMediator));
__reflect(CardSkinWindowMediator.prototype, "CardSkinWindowMediator");
//# sourceMappingURL=CardSkinWindowMediator.js.map