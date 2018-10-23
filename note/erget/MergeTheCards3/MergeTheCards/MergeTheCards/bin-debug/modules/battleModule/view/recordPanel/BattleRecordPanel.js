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
var BattleRecordPanel = (function (_super) {
    __extends(BattleRecordPanel, _super);
    function BattleRecordPanel() {
        var _this = _super.call(this) || this;
        _this._skinId = 1;
        _this.skinName = "BattleRecordPanelSkin";
        return _this;
    }
    Object.defineProperty(BattleRecordPanel.prototype, "currExp", {
        set: function (exp) {
            this._exp = exp;
            var currLv = LvConfigHelper.getLvByExp(exp);
            var currLvExp = LvConfigHelper.getExpByLv(currLv);
            var nextLvExp = LvConfigHelper.getExpByLv(currLv + 1);
            this.lvBlock_curr.lv = currLv;
            this.lvBlock_next.lv = currLv + 1;
            this.expPgBar.setProgress(exp - currLvExp, nextLvExp - currLvExp);
            this.expPgBar.displayColor = SkinConfigHelper.getLvColor(this._skinId, currLv);
        },
        enumerable: true,
        configurable: true
    });
    BattleRecordPanel.prototype.updateSkin = function (skinId) {
        var lv = LvConfigHelper.getLvByExp(this._exp);
        this.expPgBar.displayColor = SkinConfigHelper.getLvColor(skinId, lv);
        this.lvBlock_curr.skinId = skinId;
        this.lvBlock_next.skinId = skinId;
        this.rect_bg_scoreMultiple.fillColor = SkinConfigHelper.getScoreMultipleBgColor(skinId);
    };
    Object.defineProperty(BattleRecordPanel.prototype, "highScore", {
        set: function (value) {
            this.lb_highScore.text = Utils.NumberToUnitStringUtil.convert(value);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleRecordPanel.prototype, "currScore", {
        set: function (value) {
            this.lb_currScore.text = Utils.NumberToUnitStringUtil.convert(value);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(BattleRecordPanel.prototype, "scoreMultiple", {
        set: function (value) {
            this.lb_scoreMultiple.text = "X" + value;
        },
        enumerable: true,
        configurable: true
    });
    return BattleRecordPanel;
}(eui.Component));
__reflect(BattleRecordPanel.prototype, "BattleRecordPanel", ["eui.UIComponent", "egret.DisplayObject"]);
window['BattleRecordPanel'] = BattleRecordPanel;
//# sourceMappingURL=BattleRecordPanel.js.map