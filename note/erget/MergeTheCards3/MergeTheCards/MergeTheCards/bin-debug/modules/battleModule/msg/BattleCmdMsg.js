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
var BattleMsg;
(function (BattleMsg) {
    var cmd;
    (function (cmd) {
        /**进入战斗*/
        var EnterBattle = (function (_super) {
            __extends(EnterBattle, _super);
            function EnterBattle() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return EnterBattle;
        }(VoyaMVC.Msg));
        cmd.EnterBattle = EnterBattle;
        __reflect(EnterBattle.prototype, "BattleMsg.cmd.EnterBattle");
        /**打开战斗界面*/
        var OpenBattleView = (function (_super) {
            __extends(OpenBattleView, _super);
            function OpenBattleView() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return OpenBattleView;
        }(VoyaMVC.Msg));
        cmd.OpenBattleView = OpenBattleView;
        __reflect(OpenBattleView.prototype, "BattleMsg.cmd.OpenBattleView");
        /**关闭战斗界面*/
        var CloseBattleView = (function (_super) {
            __extends(CloseBattleView, _super);
            function CloseBattleView() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CloseBattleView;
        }(VoyaMVC.Msg));
        cmd.CloseBattleView = CloseBattleView;
        __reflect(CloseBattleView.prototype, "BattleMsg.cmd.CloseBattleView");
        /**打开战斗菜单界面*/
        var OpenBattleMenu = (function (_super) {
            __extends(OpenBattleMenu, _super);
            function OpenBattleMenu() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return OpenBattleMenu;
        }(VoyaMVC.Msg));
        cmd.OpenBattleMenu = OpenBattleMenu;
        __reflect(OpenBattleMenu.prototype, "BattleMsg.cmd.OpenBattleMenu");
        /**关闭战斗菜单界面*/
        var CloseBattleMenu = (function (_super) {
            __extends(CloseBattleMenu, _super);
            function CloseBattleMenu() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CloseBattleMenu;
        }(VoyaMVC.Msg));
        cmd.CloseBattleMenu = CloseBattleMenu;
        __reflect(CloseBattleMenu.prototype, "BattleMsg.cmd.CloseBattleMenu");
        /**打开战斗菜单界面*/
        var OpenBattleSettleView = (function (_super) {
            __extends(OpenBattleSettleView, _super);
            function OpenBattleSettleView() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return OpenBattleSettleView;
        }(VoyaMVC.Msg));
        cmd.OpenBattleSettleView = OpenBattleSettleView;
        __reflect(OpenBattleSettleView.prototype, "BattleMsg.cmd.OpenBattleSettleView");
        /**关闭战斗菜单界面*/
        var CloseBattleSettleView = (function (_super) {
            __extends(CloseBattleSettleView, _super);
            function CloseBattleSettleView() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CloseBattleSettleView;
        }(VoyaMVC.Msg));
        cmd.CloseBattleSettleView = CloseBattleSettleView;
        __reflect(CloseBattleSettleView.prototype, "BattleMsg.cmd.CloseBattleSettleView");
        /**打开复活窗口*/
        var OpenRebirthWindow = (function (_super) {
            __extends(OpenRebirthWindow, _super);
            function OpenRebirthWindow() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return OpenRebirthWindow;
        }(VoyaMVC.Msg));
        cmd.OpenRebirthWindow = OpenRebirthWindow;
        __reflect(OpenRebirthWindow.prototype, "BattleMsg.cmd.OpenRebirthWindow");
        /**关闭复活窗口*/
        var CloseRebirthWindow = (function (_super) {
            __extends(CloseRebirthWindow, _super);
            function CloseRebirthWindow() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return CloseRebirthWindow;
        }(VoyaMVC.Msg));
        cmd.CloseRebirthWindow = CloseRebirthWindow;
        __reflect(CloseRebirthWindow.prototype, "BattleMsg.cmd.CloseRebirthWindow");
        /**从战斗中回到主界面*/
        var BackToMainView = (function (_super) {
            __extends(BackToMainView, _super);
            function BackToMainView() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return BackToMainView;
        }(VoyaMVC.Msg));
        cmd.BackToMainView = BackToMainView;
        __reflect(BackToMainView.prototype, "BattleMsg.cmd.BackToMainView");
        /**重新开一局*/
        var PlayAgain = (function (_super) {
            __extends(PlayAgain, _super);
            function PlayAgain() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return PlayAgain;
        }(VoyaMVC.Msg));
        cmd.PlayAgain = PlayAgain;
        __reflect(PlayAgain.prototype, "BattleMsg.cmd.PlayAgain");
        /**将当前卡牌添加到组*/
        var AppendHandCardToGroup = (function (_super) {
            __extends(AppendHandCardToGroup, _super);
            function AppendHandCardToGroup() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return AppendHandCardToGroup;
        }(VoyaMVC.Msg));
        cmd.AppendHandCardToGroup = AppendHandCardToGroup;
        __reflect(AppendHandCardToGroup.prototype, "BattleMsg.cmd.AppendHandCardToGroup");
        /** 将当前手牌扔到垃圾箱 */
        var DropCurrCardToRubbishBin = (function (_super) {
            __extends(DropCurrCardToRubbishBin, _super);
            function DropCurrCardToRubbishBin() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return DropCurrCardToRubbishBin;
        }(VoyaMVC.Msg));
        cmd.DropCurrCardToRubbishBin = DropCurrCardToRubbishBin;
        __reflect(DropCurrCardToRubbishBin.prototype, "BattleMsg.cmd.DropCurrCardToRubbishBin");
        /** 清理一个垃圾格子 */
        var ClearOneRubbishCell = (function (_super) {
            __extends(ClearOneRubbishCell, _super);
            function ClearOneRubbishCell() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return ClearOneRubbishCell;
        }(VoyaMVC.Msg));
        cmd.ClearOneRubbishCell = ClearOneRubbishCell;
        __reflect(ClearOneRubbishCell.prototype, "BattleMsg.cmd.ClearOneRubbishCell");
        /** 刷新手牌 */
        var RefreshHandCard = (function (_super) {
            __extends(RefreshHandCard, _super);
            function RefreshHandCard() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return RefreshHandCard;
        }(VoyaMVC.Msg));
        cmd.RefreshHandCard = RefreshHandCard;
        __reflect(RefreshHandCard.prototype, "BattleMsg.cmd.RefreshHandCard");
        /** 复活 */
        var Rebirth = (function (_super) {
            __extends(Rebirth, _super);
            function Rebirth() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return Rebirth;
        }(VoyaMVC.Msg));
        cmd.Rebirth = Rebirth;
        __reflect(Rebirth.prototype, "BattleMsg.cmd.Rebirth");
    })(cmd = BattleMsg.cmd || (BattleMsg.cmd = {}));
})(BattleMsg || (BattleMsg = {}));
//# sourceMappingURL=BattleCmdMsg.js.map