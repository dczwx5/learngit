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
var BattleView = (function (_super) {
    __extends(BattleView, _super);
    function BattleView() {
        return _super.call(this, "BattleViewSkin") || this;
    }
    BattleView.prototype.getCardGroup = function (idx) {
        return this["cardGroup" + idx];
    };
    Object.defineProperty(BattleView.prototype, "resources", {
        get: function () {
            return [];
        },
        enumerable: true,
        configurable: true
    });
    // open(){
    // 	super.open();
    // 	for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
    // 		this.getCardGroup(i).activate();
    // 	}
    // }
    // close(){
    // 	super.close();
    // 	for(let i = 0, l = PublicConfigHelper.CARD_GROUP_COUNT; i < l; i++){
    // 		this.getCardGroup(i).deactivate();
    // 	}
    // }
    BattleView.prototype.onDestroy = function () {
    };
    return BattleView;
}(App.BaseAutoSizeView));
__reflect(BattleView.prototype, "BattleView");
//# sourceMappingURL=BattleView.js.map