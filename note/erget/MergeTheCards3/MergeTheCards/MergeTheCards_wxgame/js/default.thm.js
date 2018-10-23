var egret = window.egret;window.skins={};
                function __extends(d, b) {
                    for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
                        function __() {
                            this.constructor = d;
                        }
                    __.prototype = b.prototype;
                    d.prototype = new __();
                };
                window.generateEUI = {};
                generateEUI.paths = {};
                generateEUI.styles = undefined;
                generateEUI.skins = {"eui.Button":"resource/eui_skins/ButtonSkin.exml","eui.CheckBox":"resource/eui_skins/CheckBoxSkin.exml","eui.HScrollBar":"resource/eui_skins/HScrollBarSkin.exml","eui.HSlider":"resource/eui_skins/HSliderSkin.exml","eui.Panel":"resource/eui_skins/PanelSkin.exml","eui.TextInput":"resource/eui_skins/TextInputSkin.exml","eui.ProgressBar":"resource/eui_skins/ProgressBarSkin.exml","eui.RadioButton":"resource/eui_skins/RadioButtonSkin.exml","eui.Scroller":"resource/eui_skins/ScrollerSkin.exml","eui.ToggleSwitch":"resource/eui_skins/ToggleSwitchSkin.exml","eui.VScrollBar":"resource/eui_skins/VScrollBarSkin.exml","eui.VSlider":"resource/eui_skins/VSliderSkin.exml","eui.ItemRenderer":"resource/eui_skins/ItemRendererSkin.exml","BattleView":"resource/eui_skins/BattleViewSkin.exml","MainView":"resource/eui_skins/mainModule/MainViewSkin.exml","BattleRecordPanel":"resource/eui_skins/battle/BattleRecordPanelSkin.exml","Card":"resource/eui_skins/battle/CardSkin.exml","CardGroup":"resource/eui_skins/battle/CardGroupSkin.exml","RefreshBtn":"resource/eui_skins/battle/RefreshBtnSkin.exml","RubbishBin":"resource/eui_skins/battle/RubbishBinSkin.exml","RubbishBinCell":"resource/eui_skins/battle/RubbishBinCellSkin.exml","LvBlock":"resource/eui_skins/battle/LvBlock.exml","ExpPgBar":"resource/eui_skins/battle/ExpPgBarSkin.exml","FlyScoreTip":"resource/eui_skins/battle/FlyScoreTipSkin.exml","HelpWindow":"resource/eui_skins/help/HelpWindowSkin.exml","BattleMenuWindow":"resource/eui_skins/battle/BattleMenuWindowSkin.exml","BattleSettleView":"resource/battle/eui_skins/BattleSettleViewSkin.exml","ShareCanvasView":"resource/eui_skins/sdk/wx/ShareCanvasViewSkin.exml","WxOtherGameIcon":"resource/eui_skins/sdk/wx/WxOtherGameIconSkin.exml","PopupWindow":"resource/eui_skins/common/PopupWindowSkin.exml","RebirthConfirmWindow":"resource/eui_skins/battle/RebirthConfirmWindowSkin.exml","SkinWindow":"resource/eui_skins/cardSkin/SkinWindowSkin.exml","CardSkinItemRenderer":"resource/eui_skins/cardSkin/CardSkinItemRendererSkin.exml"};generateEUI.paths['resource/eui_skins/battle/BattleMenuWindowSkin.exml'] = window.BattleMenuWindowSkin = (function (_super) {
	__extends(BattleMenuWindowSkin, _super);
	function BattleMenuWindowSkin() {
		_super.call(this);
		this.skinParts = ["icon_backHome","icon_continue","icon_reset"];
		
		this.height = 352;
		this.width = 600;
		this.elementsContent = [this._Rect1_i(),this._Image1_i(),this.icon_backHome_i(),this.icon_continue_i(),this.icon_reset_i(),this._Label1_i()];
	}
	var _proto = BattleMenuWindowSkin.prototype;

	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillColor = 0xffffff;
		t.left = 0;
		t.right = 0;
		t.strokeAlpha = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 5;
		t.top = 0;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.right = -70;
		t.source = "btn_close_png";
		t.top = -70;
		t.visible = false;
		return t;
	};
	_proto.icon_backHome_i = function () {
		var t = new eui.Image();
		this.icon_backHome = t;
		t.left = 40;
		t.source = "icon_backHome_png";
		t.verticalCenter = 50;
		return t;
	};
	_proto.icon_continue_i = function () {
		var t = new eui.Image();
		this.icon_continue = t;
		t.horizontalCenter = 0;
		t.source = "icon_continue_png";
		t.verticalCenter = 50;
		return t;
	};
	_proto.icon_reset_i = function () {
		var t = new eui.Image();
		this.icon_reset = t;
		t.right = 40;
		t.source = "icon_reset_png";
		t.verticalCenter = 50;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0.5;
		t.size = 60;
		t.text = "游戏菜单";
		t.textColor = 0x000000;
		t.top = 30;
		return t;
	};
	return BattleMenuWindowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/LvBlockSkin.exml'] = window.LvBlockSkin = (function (_super) {
	__extends(LvBlockSkin, _super);
	function LvBlockSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","lb_lv"];
		
		this.height = 100;
		this.width = 100;
		this.elementsContent = [this.rect_bg_i(),this.lb_lv_i()];
	}
	var _proto = LvBlockSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillColor = 0xb26565;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.lb_lv_i = function () {
		var t = new eui.Label();
		this.lb_lv = t;
		t.horizontalCenter = 0;
		t.size = 50;
		t.text = "20";
		t.verticalCenter = 0;
		return t;
	};
	return LvBlockSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/BattleRecordPanelSkin.exml'] = window.BattleRecordPanelSkin = (function (_super) {
	__extends(BattleRecordPanelSkin, _super);
	function BattleRecordPanelSkin() {
		_super.call(this);
		this.skinParts = ["lb_highScore","lb_currScore","lvBlock_curr","lvBlock_next","expPgBar","rect_bg_scoreMultiple","lb_scoreMultiple"];
		
		this.height = 234;
		this.width = 1080;
		this.elementsContent = [this._Image1_i(),this.lb_highScore_i(),this.lb_currScore_i(),this.lvBlock_curr_i(),this.lvBlock_next_i(),this.expPgBar_i(),this._Group1_i()];
	}
	var _proto = BattleRecordPanelSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 55;
		t.left = 32;
		t.source = "img_crown_png";
		t.verticalCenter = -60;
		t.width = 82;
		return t;
	};
	_proto.lb_highScore_i = function () {
		var t = new eui.Label();
		this.lb_highScore = t;
		t.bold = true;
		t.left = 123;
		t.size = 40;
		t.text = "3000";
		t.textColor = 0x000000;
		t.verticalCenter = -60;
		return t;
	};
	_proto.lb_currScore_i = function () {
		var t = new eui.Label();
		this.lb_currScore = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 50;
		t.text = "5000";
		t.textColor = 0x000000;
		t.verticalCenter = -60;
		return t;
	};
	_proto.lvBlock_curr_i = function () {
		var t = new LvBlock();
		this.lvBlock_curr = t;
		t.left = 60;
		t.skinName = "LvBlockSkin";
		t.verticalCenter = 40;
		return t;
	};
	_proto.lvBlock_next_i = function () {
		var t = new LvBlock();
		this.lvBlock_next = t;
		t.right = 60;
		t.skinName = "LvBlockSkin";
		t.verticalCenter = 40;
		return t;
	};
	_proto.expPgBar_i = function () {
		var t = new ExpPgBar();
		this.expPgBar = t;
		t.horizontalCenter = 0;
		t.verticalCenter = 40;
		t.width = 760;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.horizontalCenter = 249.5;
		t.verticalCenter = -60;
		t.elementsContent = [this.rect_bg_scoreMultiple_i(),this.lb_scoreMultiple_i()];
		return t;
	};
	_proto.rect_bg_scoreMultiple_i = function () {
		var t = new eui.Rect();
		this.rect_bg_scoreMultiple = t;
		t.bottom = 0;
		t.ellipseHeight = 15;
		t.ellipseWidth = 15;
		t.fillColor = 0xf7f2f2;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.lb_scoreMultiple_i = function () {
		var t = new eui.Label();
		this.lb_scoreMultiple = t;
		t.bold = true;
		t.bottom = 5;
		t.horizontalCenter = 0;
		t.left = 5;
		t.right = 5;
		t.text = "X100";
		t.textColor = 0x000000;
		t.top = 5;
		t.verticalCenter = 0;
		return t;
	};
	return BattleRecordPanelSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/BattleSettleViewSkin.exml'] = window.BattleSettleViewSkin = (function (_super) {
	__extends(BattleSettleViewSkin, _super);
	function BattleSettleViewSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","lb_lv","lb_battleScore","lb_highScore","btn_playAgain","btn_backHome","grp_content"];
		
		this.height = 1920;
		this.width = 1080;
		this.elementsContent = [this.rect_bg_i(),this.grp_content_i()];
	}
	var _proto = BattleSettleViewSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.fillColor = 0xe8e8e8;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.grp_content_i = function () {
		var t = new eui.Group();
		this.grp_content = t;
		t.height = 1920;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.width = 1080;
		t.elementsContent = [this._Group1_i(),this.lb_battleScore_i(),this._Label1_i(),this.lb_highScore_i(),this._Label2_i(),this._Image1_i(),this.btn_playAgain_i(),this.btn_backHome_i()];
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.verticalCenter = -700;
		t.elementsContent = [this._Rect1_i(),this.lb_lv_i()];
		return t;
	};
	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillColor = 0x4b9de0;
		t.height = 80;
		t.width = 450;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.lb_lv_i = function () {
		var t = new eui.Label();
		this.lb_lv = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 60;
		t.text = "等级 15";
		t.textColor = 0xffffff;
		t.verticalCenter = 0;
		return t;
	};
	_proto.lb_battleScore_i = function () {
		var t = new eui.Label();
		this.lb_battleScore = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 150;
		t.text = "8000";
		t.textColor = 0x000000;
		t.x = 351;
		t.y = 572;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 150;
		t.text = "本局得分";
		t.textColor = 0x000000;
		t.x = 361;
		t.y = 409;
		return t;
	};
	_proto.lb_highScore_i = function () {
		var t = new eui.Label();
		this.lb_highScore = t;
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 80;
		t.text = "8000";
		t.textColor = 0x000000;
		t.x = 429;
		t.y = 1008;
		return t;
	};
	_proto._Label2_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 80;
		t.text = "最高记录";
		t.textColor = 0x000000;
		t.x = 439;
		t.y = 812;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "img_crown_png";
		t.x = 438;
		t.y = 894;
		return t;
	};
	_proto.btn_playAgain_i = function () {
		var t = new eui.Image();
		this.btn_playAgain = t;
		t.horizontalCenter = -200;
		t.source = "icon_reset_png";
		t.verticalCenter = 345.5;
		return t;
	};
	_proto.btn_backHome_i = function () {
		var t = new eui.Image();
		this.btn_backHome = t;
		t.horizontalCenter = 200;
		t.source = "icon_backHome_png";
		t.verticalCenter = 345.5;
		return t;
	};
	return BattleSettleViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/BattleViewSkin.exml'] = window.BattleViewSkin = (function (_super) {
	__extends(BattleViewSkin, _super);
	function BattleViewSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","battlePanel","cardGroup0","cardGroup1","cardGroup2","cardGroup3","btn_refreshHandCard","grp_handCards","rubbishBin","btn_menu","btn_help","grp_content"];
		
		this.height = 1920;
		this.width = 1080;
		this.elementsContent = [this.rect_bg_i(),this.grp_content_i()];
	}
	var _proto = BattleViewSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.fillColor = 0xe8e8e8;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0xe8e8e8;
		t.top = 0;
		return t;
	};
	_proto.grp_content_i = function () {
		var t = new eui.Group();
		this.grp_content = t;
		t.height = 1920;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.width = 1080;
		t.elementsContent = [this.battlePanel_i(),this._Group1_i(),this._Group2_i(),this._Image1_i()];
		return t;
	};
	_proto.battlePanel_i = function () {
		var t = new BattleRecordPanel();
		this.battlePanel = t;
		t.horizontalCenter = 0;
		t.top = 0;
		t.width = 1080;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.anchorOffsetX = 0;
		t.horizontalCenter = 0;
		t.width = 1080;
		t.y = 248;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this.cardGroup0_i(),this.cardGroup1_i(),this.cardGroup2_i(),this.cardGroup3_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		t.gap = 1;
		t.horizontalAlign = "left";
		t.paddingLeft = 0;
		t.paddingRight = 0;
		return t;
	};
	_proto.cardGroup0_i = function () {
		var t = new CardGroup();
		this.cardGroup0 = t;
		t.x = 78;
		t.y = 72;
		return t;
	};
	_proto.cardGroup1_i = function () {
		var t = new CardGroup();
		this.cardGroup1 = t;
		t.x = 48;
		t.y = 42;
		return t;
	};
	_proto.cardGroup2_i = function () {
		var t = new CardGroup();
		this.cardGroup2 = t;
		t.x = 58;
		t.y = 52;
		return t;
	};
	_proto.cardGroup3_i = function () {
		var t = new CardGroup();
		this.cardGroup3 = t;
		t.x = 68;
		t.y = 62;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.bottom = 92;
		t.height = 400;
		t.horizontalCenter = 0;
		t.width = 1080;
		t.elementsContent = [this.btn_refreshHandCard_i(),this.grp_handCards_i(),this.rubbishBin_i(),this.btn_menu_i(),this.btn_help_i()];
		return t;
	};
	_proto.btn_refreshHandCard_i = function () {
		var t = new RefreshBtn();
		this.btn_refreshHandCard = t;
		t.bottom = 23;
		t.left = 30;
		t.touchChildren = false;
		t.touchEnabled = true;
		return t;
	};
	_proto.grp_handCards_i = function () {
		var t = new eui.Group();
		this.grp_handCards = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 384;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.width = 456;
		return t;
	};
	_proto.rubbishBin_i = function () {
		var t = new RubbishBin();
		this.rubbishBin = t;
		t.right = 29;
		t.touchChildren = false;
		t.touchEnabled = true;
		t.verticalCenter = 0;
		return t;
	};
	_proto.btn_menu_i = function () {
		var t = new eui.Image();
		this.btn_menu = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.left = 30;
		t.source = "icon_menu_png";
		t.verticalCenter = -113;
		return t;
	};
	_proto.btn_help_i = function () {
		var t = new eui.Image();
		this.btn_help = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.left = 161;
		t.source = "icon_help_png";
		t.verticalCenter = -113;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "img_cutPartLine_png";
		t.verticalCenter = 453;
		t.width = 1028;
		t.x = 108;
		t.y = 1353;
		return t;
	};
	return BattleViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/CardGroupSkin.exml'] = window.CardGroupSkin = (function (_super) {
	__extends(CardGroupSkin, _super);
	function CardGroupSkin() {
		_super.call(this);
		this.skinParts = ["img_border","img_dropArea"];
		
		this.height = 1150;
		this.width = 270;
		this.elementsContent = [this.img_border_i(),this._Rect1_i(),this.img_dropArea_i()];
	}
	var _proto = CardGroupSkin.prototype;

	_proto.img_border_i = function () {
		var t = new eui.Image();
		this.img_border = t;
		t.bottom = -10;
		t.left = -10;
		t.right = -10;
		t.scale9Grid = new egret.Rectangle(44,44,7,7);
		t.source = "dropBorder_png";
		t.top = -10;
		t.visible = false;
		return t;
	};
	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bottom = 10;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xe8e8e8;
		t.left = 10;
		t.right = 10;
		t.top = 10;
		return t;
	};
	_proto.img_dropArea_i = function () {
		var t = new eui.Image();
		this.img_dropArea = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 384;
		t.horizontalCenter = 0;
		t.source = "img_cardArea_png";
		t.top = 10;
		t.width = 250;
		return t;
	};
	return CardGroupSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/CardSkin.exml'] = window.CardSkin = (function (_super) {
	__extends(CardSkin, _super);
	function CardSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","img_bg","lb_value"];
		
		this.height = 384;
		this.width = 250;
		this.elementsContent = [this.rect_bg_i(),this.img_bg_i(),this.lb_value_i()];
	}
	var _proto = CardSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.top = 0;
		return t;
	};
	_proto.img_bg_i = function () {
		var t = new eui.Image();
		this.img_bg = t;
		t.bottom = 0;
		t.left = 0;
		t.right = 0;
		t.source = "";
		t.top = 0;
		t.visible = false;
		return t;
	};
	_proto.lb_value_i = function () {
		var t = new eui.Label();
		this.lb_value = t;
		t.left = 11;
		t.size = 70;
		t.text = "2048";
		t.top = 12;
		return t;
	};
	return CardSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/ExpPgBarSkin.exml'] = window.ExpPgBarSkin = (function (_super) {
	__extends(ExpPgBarSkin, _super);
	function ExpPgBarSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","rect_value"];
		
		this.height = 20;
		this.width = 400;
		this.elementsContent = [this.rect_bg_i(),this.rect_value_i()];
	}
	var _proto = ExpPgBarSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.fillColor = 0xcccccc;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.rect_value_i = function () {
		var t = new eui.Rect();
		this.rect_value = t;
		t.bottom = 0;
		t.fillColor = 0xf90404;
		t.left = 0;
		t.top = 0;
		t.width = 400;
		return t;
	};
	return ExpPgBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/FlyScoreTipSkin.exml'] = window.FlyScoreTipSkin = (function (_super) {
	__extends(FlyScoreTipSkin, _super);
	function FlyScoreTipSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","lb_score"];
		
		this.elementsContent = [this.rect_bg_i(),this.lb_score_i()];
	}
	var _proto = FlyScoreTipSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.ellipseHeight = 20;
		t.ellipseWidth = 20;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.lb_score_i = function () {
		var t = new eui.Label();
		this.lb_score = t;
		t.bottom = 10;
		t.left = 10;
		t.right = 10;
		t.size = 50;
		t.text = "+ 30";
		t.top = 10;
		return t;
	};
	return FlyScoreTipSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/RebirthConfirmWindowSkin.exml'] = window.RebirthConfirmWindowSkin = (function (_super) {
	__extends(RebirthConfirmWindowSkin, _super);
	function RebirthConfirmWindowSkin() {
		_super.call(this);
		this.skinParts = ["btn_close","lb_content","btn_rebirth"];
		
		this.height = 400;
		this.width = 600;
		this.elementsContent = [this._Rect1_i(),this.btn_close_i(),this._Group1_i()];
	}
	var _proto = RebirthConfirmWindowSkin.prototype;

	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillAlpha = 1;
		t.fillColor = 0xFFFFFF;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 5;
		t.top = 0;
		return t;
	};
	_proto.btn_close_i = function () {
		var t = new eui.Image();
		this.btn_close = t;
		t.right = -40;
		t.source = "btn_close_png";
		t.top = -40;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.bottom = 50;
		t.left = 50;
		t.right = 50;
		t.top = 100;
		t.layout = this._VerticalLayout1_i();
		t.elementsContent = [this.lb_content_i(),this.btn_rebirth_i()];
		return t;
	};
	_proto._VerticalLayout1_i = function () {
		var t = new eui.VerticalLayout();
		t.gap = 100;
		t.horizontalAlign = "center";
		return t;
	};
	_proto.lb_content_i = function () {
		var t = new eui.Label();
		this.lb_content = t;
		t.size = 55;
		t.text = "难道就这么结束了？";
		t.textColor = 0x000000;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.btn_rebirth_i = function () {
		var t = new eui.Group();
		this.btn_rebirth = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.touchChildren = false;
		t.touchEnabled = true;
		t.x = 64;
		t.y = 93;
		t.elementsContent = [this._Rect2_i(),this._Label1_i()];
		return t;
	};
	_proto._Rect2_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0x0abd49;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bottom = 20;
		t.horizontalCenter = 0;
		t.left = 20;
		t.right = 20;
		t.size = 40;
		t.text = "我不服~!";
		t.top = 20;
		t.verticalCenter = 0;
		t.wordWrap = false;
		return t;
	};
	return RebirthConfirmWindowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/RefreshBtnSkin.exml'] = window.RefreshBtnSkin = (function (_super) {
	__extends(RefreshBtnSkin, _super);
	function RefreshBtnSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","icon_refresh","icon_playVideo"];
		
		this.height = 200;
		this.width = 250;
		this.elementsContent = [this.rect_bg_i(),this._Label1_i(),this.icon_refresh_i(),this.icon_playVideo_i()];
	}
	var _proto = RefreshBtnSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillColor = 0x00ff00;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.anchorOffsetX = 0;
		t.bold = true;
		t.bottom = 16;
		t.horizontalCenter = 0;
		t.size = 40;
		t.text = "刷新手牌";
		return t;
	};
	_proto.icon_refresh_i = function () {
		var t = new eui.Image();
		this.icon_refresh = t;
		t.height = 100;
		t.horizontalCenter = 0;
		t.source = "icon_resetHandCard_png";
		t.verticalCenter = -24;
		t.width = 100;
		return t;
	};
	_proto.icon_playVideo_i = function () {
		var t = new eui.Image();
		this.icon_playVideo = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.horizontalCenter = 0;
		t.source = "icon_playVideo_png";
		t.verticalCenter = -24;
		t.visible = false;
		return t;
	};
	return RefreshBtnSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/RubbishBinCellSkin.exml'] = window.RubbishBinCellSkin = (function (_super) {
	__extends(RubbishBinCellSkin, _super);
	function RubbishBinCellSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","img_icon"];
		
		this.height = 192;
		this.width = 250;
		this.elementsContent = [this.rect_bg_i(),this.img_icon_i()];
	}
	var _proto = RubbishBinCellSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.fillColor = 0xc6c4c4;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.img_icon_i = function () {
		var t = new eui.Image();
		this.img_icon = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.horizontalCenter = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "icon_rubbishBin_png";
		t.verticalCenter = 0;
		t.x = 63;
		t.y = 55;
		return t;
	};
	return RubbishBinCellSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/battle/RubbishBinSkin.exml'] = window.RubbishBinSkin = (function (_super) {
	__extends(RubbishBinSkin, _super);
	function RubbishBinSkin() {
		_super.call(this);
		this.skinParts = ["img_border","rect_mask","cell0","cell1","grp_cell"];
		
		this.height = 384;
		this.width = 250;
		this.elementsContent = [this.img_border_i(),this.rect_mask_i(),this.grp_cell_i(),this._Label1_i()];
	}
	var _proto = RubbishBinSkin.prototype;

	_proto.img_border_i = function () {
		var t = new eui.Image();
		this.img_border = t;
		t.bottom = -20;
		t.left = -20;
		t.right = -20;
		t.scale9Grid = new egret.Rectangle(44,44,8,7);
		t.source = "dropBorder_png";
		t.top = -20;
		t.visible = false;
		return t;
	};
	_proto.rect_mask_i = function () {
		var t = new eui.Rect();
		this.rect_mask = t;
		t.bottom = 0;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xfc0202;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.grp_cell_i = function () {
		var t = new eui.Group();
		this.grp_cell = t;
		t.x = 0;
		t.y = 0;
		t.elementsContent = [this.cell0_i(),this.cell1_i()];
		return t;
	};
	_proto.cell0_i = function () {
		var t = new RubbishBinCell();
		this.cell0 = t;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.cell1_i = function () {
		var t = new RubbishBinCell();
		this.cell1 = t;
		t.x = 0;
		t.y = 192;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.horizontalCenter = 0;
		t.size = 60;
		t.text = "丢弃区";
		t.textColor = 0x000000;
		t.touchEnabled = false;
		t.verticalCenter = 0;
		return t;
	};
	return RubbishBinSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/ButtonSkin.exml'] = window.skins.ButtonSkin = (function (_super) {
	__extends(ButtonSkin, _super);
	function ButtonSkin() {
		_super.call(this);
		this.skinParts = ["labelDisplay","iconDisplay"];
		
		this.minHeight = 50;
		this.minWidth = 100;
		this.elementsContent = [this._Image1_i(),this.labelDisplay_i(),this.iconDisplay_i()];
		this.states = [
			new eui.State ("up",
				[
				])
			,
			new eui.State ("down",
				[
					new eui.SetProperty("_Image1","source","button_down_png")
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("_Image1","alpha",0.5)
				])
		];
	}
	var _proto = ButtonSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		this._Image1 = t;
		t.percentHeight = 100;
		t.scale9Grid = new egret.Rectangle(1,3,8,8);
		t.source = "button_up_png";
		t.percentWidth = 100;
		return t;
	};
	_proto.labelDisplay_i = function () {
		var t = new eui.Label();
		this.labelDisplay = t;
		t.bottom = 8;
		t.left = 8;
		t.right = 8;
		t.size = 20;
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.top = 8;
		t.verticalAlign = "middle";
		return t;
	};
	_proto.iconDisplay_i = function () {
		var t = new eui.Image();
		this.iconDisplay = t;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		return t;
	};
	return ButtonSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardSkin/CardSkinItemRendererSkin.exml'] = window.CardSkinItemRendererSkin = (function (_super) {
	__extends(CardSkinItemRendererSkin, _super);
	function CardSkinItemRendererSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","rect_cardBg0","lb_cardValue0","rect_cardBg1","lb_cardValue1","rect_cardBg2","lb_cardValue2","rect_cardBg3","lb_cardValue3","rect_cardBg4","lb_cardValue4","rect_cardBg5","lb_cardValue5","grp_cards","rect_mask","icon_locked","rect_statusBg","lb_status"];
		
		this.height = 366;
		this.minHeight = 50;
		this.minWidth = 100;
		this.width = 233;
		this.elementsContent = [this.rect_bg_i(),this.grp_cards_i(),this.rect_mask_i(),this.icon_locked_i(),this._Group7_i()];
		this.states = [
			new eui.State ("using",
				[
					new eui.SetProperty("rect_bg","strokeColor",0x30e930),
					new eui.SetProperty("icon_locked","visible",false),
					new eui.SetProperty("rect_statusBg","fillColor",0x30e930),
					new eui.SetProperty("lb_status","size",40)
				])
			,
			new eui.State ("enabled",
				[
					new eui.SetProperty("rect_bg","strokeColor",0x1464a0),
					new eui.SetProperty("icon_locked","visible",false),
					new eui.SetProperty("rect_statusBg","fillColor",0x1464a0),
					new eui.SetProperty("lb_status","text","可使用"),
					new eui.SetProperty("lb_status","size",40)
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("rect_bg","strokeColor",0x999999),
					new eui.SetProperty("rect_bg","strokeWeight",10),
					new eui.SetProperty("grp_cards","visible",false),
					new eui.SetProperty("rect_statusBg","fillColor",0x999999),
					new eui.SetProperty("lb_status","text","10级解锁"),
					new eui.SetProperty("lb_status","size",40)
				])
		];
	}
	var _proto = CardSkinItemRendererSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 20;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xffffff;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 10;
		t.top = 0;
		return t;
	};
	_proto.grp_cards_i = function () {
		var t = new eui.Group();
		this.grp_cards = t;
		t.bottom = 60;
		t.left = 17;
		t.right = 16;
		t.scrollEnabled = true;
		t.scrollRect = new egret.Rectangle(0,0,200,291);
		t.top = 15;
		t.layout = this._VerticalLayout1_i();
		t.elementsContent = [this._Group1_i(),this._Group2_i(),this._Group3_i(),this._Group4_i(),this._Group5_i(),this._Group6_i()];
		return t;
	};
	_proto._VerticalLayout1_i = function () {
		var t = new eui.VerticalLayout();
		t.gap = -54;
		t.horizontalAlign = "center";
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.scrollRect = new egret.Rectangle(0,0,200,286);
		t.x = 22;
		t.y = -6;
		t.elementsContent = [this.rect_cardBg0_i(),this.lb_cardValue0_i()];
		return t;
	};
	_proto.rect_cardBg0_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg0 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue0_i = function () {
		var t = new eui.Label();
		this.lb_cardValue0 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto._Group2_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 32;
		t.y = 4;
		t.elementsContent = [this.rect_cardBg1_i(),this.lb_cardValue1_i()];
		return t;
	};
	_proto.rect_cardBg1_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg1 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue1_i = function () {
		var t = new eui.Label();
		this.lb_cardValue1 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto._Group3_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 42;
		t.y = 14;
		t.elementsContent = [this.rect_cardBg2_i(),this.lb_cardValue2_i()];
		return t;
	};
	_proto.rect_cardBg2_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg2 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue2_i = function () {
		var t = new eui.Label();
		this.lb_cardValue2 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto._Group4_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 52;
		t.y = 24;
		t.elementsContent = [this.rect_cardBg3_i(),this.lb_cardValue3_i()];
		return t;
	};
	_proto.rect_cardBg3_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg3 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue3_i = function () {
		var t = new eui.Label();
		this.lb_cardValue3 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto._Group5_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 62;
		t.y = 34;
		t.elementsContent = [this.rect_cardBg4_i(),this.lb_cardValue4_i()];
		return t;
	};
	_proto.rect_cardBg4_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg4 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue4_i = function () {
		var t = new eui.Label();
		this.lb_cardValue4 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto._Group6_i = function () {
		var t = new eui.Group();
		t.scaleX = 1;
		t.scaleY = 1;
		t.x = 72;
		t.y = 44;
		t.elementsContent = [this.rect_cardBg5_i(),this.lb_cardValue5_i()];
		return t;
	};
	_proto.rect_cardBg5_i = function () {
		var t = new eui.Rect();
		this.rect_cardBg5 = t;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0xE21414;
		t.height = 100;
		t.scaleX = 1;
		t.scaleY = 1;
		t.strokeColor = 0x000000;
		t.strokeWeight = 2;
		t.width = 200;
		t.x = 0;
		return t;
	};
	_proto.lb_cardValue5_i = function () {
		var t = new eui.Label();
		this.lb_cardValue5 = t;
		t.size = 40;
		t.text = "64";
		t.x = 13;
		t.y = 6;
		return t;
	};
	_proto.rect_mask_i = function () {
		var t = new eui.Rect();
		this.rect_mask = t;
		t.bottom = 60;
		t.fillAlpha = 1;
		t.left = 17;
		t.right = 16;
		t.top = 15;
		return t;
	};
	_proto.icon_locked_i = function () {
		var t = new eui.Image();
		this.icon_locked = t;
		t.horizontalCenter = 0;
		t.source = "icon_locked_png";
		t.verticalCenter = -20;
		return t;
	};
	_proto._Group7_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.touchChildren = false;
		t.touchEnabled = true;
		t.x = 42;
		t.y = 316;
		t.elementsContent = [this.rect_statusBg_i(),this.lb_status_i()];
		return t;
	};
	_proto.rect_statusBg_i = function () {
		var t = new eui.Rect();
		this.rect_statusBg = t;
		t.bottom = 0;
		t.ellipseHeight = 50;
		t.ellipseWidth = 50;
		t.fillColor = 0x30E930;
		t.height = 50;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.lb_status_i = function () {
		var t = new eui.Label();
		this.lb_status = t;
		t.bottom = 10;
		t.horizontalCenter = 0;
		t.left = 15;
		t.multiline = false;
		t.right = 15;
		t.size = 40;
		t.text = "使用中";
		t.top = 10;
		t.verticalCenter = 0;
		t.wordWrap = false;
		return t;
	};
	return CardSkinItemRendererSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/cardSkin/SkinWindowSkin.exml'] = window.SkinWindowSkin = (function (_super) {
	__extends(SkinWindowSkin, _super);
	function SkinWindowSkin() {
		_super.call(this);
		this.skinParts = ["dGroup_cardSkins","btn_close","lb_unlockedCount"];
		
		this.height = 1400;
		this.width = 800;
		this.elementsContent = [this._Rect1_i(),this._Scroller1_i(),this.btn_close_i(),this._Label1_i(),this._Group1_i()];
	}
	var _proto = SkinWindowSkin.prototype;

	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillAlpha = 1;
		t.fillColor = 0xFFFFFF;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 5;
		t.top = 0;
		return t;
	};
	_proto._Scroller1_i = function () {
		var t = new eui.Scroller();
		t.bottom = 25;
		t.left = 25;
		t.right = 25;
		t.scrollPolicyH = "off";
		t.scrollPolicyV = "auto";
		t.top = 200;
		t.viewport = this.dGroup_cardSkins_i();
		return t;
	};
	_proto.dGroup_cardSkins_i = function () {
		var t = new eui.List();
		this.dGroup_cardSkins = t;
		t.height = 200;
		t.itemRendererSkinName = CardSkinItemRendererSkin;
		t.width = 200;
		t.x = 748;
		t.y = 126;
		t.layout = this._TileLayout1_i();
		return t;
	};
	_proto._TileLayout1_i = function () {
		var t = new eui.TileLayout();
		t.columnWidth = 233;
		t.horizontalGap = 25;
		t.orientation = "rows";
		t.requestedColumnCount = 3;
		t.requestedRowCount = 3;
		t.rowHeight = 366;
		t.verticalGap = 25;
		return t;
	};
	_proto.btn_close_i = function () {
		var t = new eui.Image();
		this.btn_close = t;
		t.right = -40;
		t.source = "btn_close_png";
		t.top = -40;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.bold = true;
		t.horizontalCenter = 0;
		t.size = 60;
		t.text = "卡牌皮肤";
		t.textAlign = "center";
		t.textColor = 0x000000;
		t.top = 30;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.y = 103;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this._Image1_i(),this.lb_unlockedCount_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		t.gap = 20;
		t.verticalAlign = "middle";
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.source = "icon_unlocked_png";
		t.x = 0;
		t.y = 0;
		return t;
	};
	_proto.lb_unlockedCount_i = function () {
		var t = new eui.Label();
		this.lb_unlockedCount = t;
		t.bold = true;
		t.size = 60;
		t.text = "3/20";
		t.textAlign = "center";
		t.textColor = 0x000000;
		t.x = 137.06;
		t.y = 7;
		return t;
	};
	return SkinWindowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/CheckBoxSkin.exml'] = window.skins.CheckBoxSkin = (function (_super) {
	__extends(CheckBoxSkin, _super);
	function CheckBoxSkin() {
		_super.call(this);
		this.skinParts = ["labelDisplay"];
		
		this.elementsContent = [this._Group1_i()];
		this.states = [
			new eui.State ("up",
				[
				])
			,
			new eui.State ("down",
				[
					new eui.SetProperty("_Image1","alpha",0.7)
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("_Image1","alpha",0.5)
				])
			,
			new eui.State ("upAndSelected",
				[
					new eui.SetProperty("_Image1","source","checkbox_select_up_png")
				])
			,
			new eui.State ("downAndSelected",
				[
					new eui.SetProperty("_Image1","source","checkbox_select_down_png")
				])
			,
			new eui.State ("disabledAndSelected",
				[
					new eui.SetProperty("_Image1","source","checkbox_select_disabled_png")
				])
		];
	}
	var _proto = CheckBoxSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.percentHeight = 100;
		t.percentWidth = 100;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		t.verticalAlign = "middle";
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		this._Image1 = t;
		t.alpha = 1;
		t.fillMode = "scale";
		t.source = "checkbox_unselect_png";
		return t;
	};
	_proto.labelDisplay_i = function () {
		var t = new eui.Label();
		this.labelDisplay = t;
		t.fontFamily = "Tahoma";
		t.size = 20;
		t.textAlign = "center";
		t.textColor = 0x707070;
		t.verticalAlign = "middle";
		return t;
	};
	return CheckBoxSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/common/PopupWindowSkin.exml'] = window.PopupWindowSkin = (function (_super) {
	__extends(PopupWindowSkin, _super);
	function PopupWindowSkin() {
		_super.call(this);
		this.skinParts = ["btn_close","lb_content","lb_title"];
		
		this.elementsContent = [this._Rect1_i(),this.btn_close_i(),this.lb_content_i(),this.lb_title_i()];
	}
	var _proto = PopupWindowSkin.prototype;

	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillAlpha = 1;
		t.fillColor = 0xFFFFFF;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 5;
		t.top = 0;
		return t;
	};
	_proto.btn_close_i = function () {
		var t = new eui.Image();
		this.btn_close = t;
		t.right = -40;
		t.source = "btn_close_png";
		t.top = -40;
		return t;
	};
	_proto.lb_content_i = function () {
		var t = new eui.Label();
		this.lb_content = t;
		t.bottom = 100;
		t.left = 50;
		t.right = 50;
		t.size = 36;
		t.text = "Label";
		t.textColor = 0x000000;
		t.top = 120;
		return t;
	};
	_proto.lb_title_i = function () {
		var t = new eui.Label();
		this.lb_title = t;
		t.left = 120;
		t.right = 120;
		t.size = 60;
		t.text = "标题";
		t.textAlign = "center";
		t.textColor = 0x000000;
		t.y = 22;
		return t;
	};
	return PopupWindowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/help/HelpWindowSkin.exml'] = window.HelpWindowSkin = (function (_super) {
	__extends(HelpWindowSkin, _super);
	function HelpWindowSkin() {
		_super.call(this);
		this.skinParts = ["btn_close","lb_context"];
		
		this.height = 767;
		this.width = 750;
		this.elementsContent = [this._Rect1_i(),this.btn_close_i(),this._Scroller1_i(),this._Label1_i()];
	}
	var _proto = HelpWindowSkin.prototype;

	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.bottom = 0;
		t.ellipseHeight = 30;
		t.ellipseWidth = 30;
		t.fillAlpha = 1;
		t.fillColor = 0xffffff;
		t.left = 0;
		t.right = 0;
		t.strokeColor = 0x000000;
		t.strokeWeight = 5;
		t.top = 0;
		return t;
	};
	_proto.btn_close_i = function () {
		var t = new eui.Image();
		this.btn_close = t;
		t.right = -40;
		t.source = "btn_close_png";
		t.top = -40;
		return t;
	};
	_proto._Scroller1_i = function () {
		var t = new eui.Scroller();
		t.bottom = 50;
		t.left = 50;
		t.right = 50;
		t.scrollPolicyH = "off";
		t.scrollPolicyV = "auto";
		t.top = 150;
		t.viewport = this._Group1_i();
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.elementsContent = [this.lb_context_i()];
		return t;
	};
	_proto.lb_context_i = function () {
		var t = new eui.Label();
		this.lb_context = t;
		t.left = 0;
		t.right = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.size = 36;
		t.text = "1、将相同面值的卡牌合并成更大面值的卡牌，获得积分。  \n\n2、将炸弹牌与相同面值的卡牌合并，会将整列的卡牌都消除。  \n\n3、万能牌真的是万能的，它可以和任意面值的卡牌合并。  \n\n4、当前的手牌不理想？不用担心，你可以将它拖动到右下角的丢弃区进行丢弃。  \n\n5、所有的手牌都很糟糕！怎么办？快点击左下角的刷新按钮，重新获取一副手牌。  \n\n6、每当你合并出一张面值2048的卡牌时，会将整列的卡牌都消除，同时还能为你重置刷新手牌和丢弃区的使用权，更能成倍提升你后续获得积分的效率！  \n\n7、当你升级时，同样能为你重置刷新按钮和丢弃区的使用权。  \n\n那么，祝你好运！";
		t.textColor = 0x000000;
		t.top = 5;
		t.y = 0;
		return t;
	};
	_proto._Label1_i = function () {
		var t = new eui.Label();
		t.horizontalCenter = 0;
		t.size = 60;
		t.text = "游戏说明";
		t.textColor = 0x000000;
		t.top = 50;
		return t;
	};
	return HelpWindowSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/HScrollBarSkin.exml'] = window.skins.HScrollBarSkin = (function (_super) {
	__extends(HScrollBarSkin, _super);
	function HScrollBarSkin() {
		_super.call(this);
		this.skinParts = ["thumb"];
		
		this.minHeight = 8;
		this.minWidth = 20;
		this.elementsContent = [this.thumb_i()];
	}
	var _proto = HScrollBarSkin.prototype;

	_proto.thumb_i = function () {
		var t = new eui.Image();
		this.thumb = t;
		t.height = 8;
		t.scale9Grid = new egret.Rectangle(3,3,2,2);
		t.source = "roundthumb_png";
		t.verticalCenter = 0;
		t.width = 30;
		return t;
	};
	return HScrollBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/HSliderSkin.exml'] = window.skins.HSliderSkin = (function (_super) {
	__extends(HSliderSkin, _super);
	function HSliderSkin() {
		_super.call(this);
		this.skinParts = ["track","thumb"];
		
		this.minHeight = 8;
		this.minWidth = 20;
		this.elementsContent = [this.track_i(),this.thumb_i()];
	}
	var _proto = HSliderSkin.prototype;

	_proto.track_i = function () {
		var t = new eui.Image();
		this.track = t;
		t.height = 6;
		t.scale9Grid = new egret.Rectangle(1,1,4,4);
		t.source = "track_sb_png";
		t.verticalCenter = 0;
		t.percentWidth = 100;
		return t;
	};
	_proto.thumb_i = function () {
		var t = new eui.Image();
		this.thumb = t;
		t.source = "thumb_png";
		t.verticalCenter = 0;
		return t;
	};
	return HSliderSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/ItemRendererSkin.exml'] = window.skins.ItemRendererSkin = (function (_super) {
	__extends(ItemRendererSkin, _super);
	function ItemRendererSkin() {
		_super.call(this);
		this.skinParts = ["labelDisplay"];
		
		this.minHeight = 50;
		this.minWidth = 100;
		this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
		this.states = [
			new eui.State ("up",
				[
				])
			,
			new eui.State ("down",
				[
					new eui.SetProperty("_Image1","source","button_down_png")
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("_Image1","alpha",0.5)
				])
		];
		
		eui.Binding.$bindProperties(this, ["hostComponent.data"],[0],this.labelDisplay,"text");
	}
	var _proto = ItemRendererSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		this._Image1 = t;
		t.percentHeight = 100;
		t.scale9Grid = new egret.Rectangle(1,3,8,8);
		t.source = "button_up_png";
		t.percentWidth = 100;
		return t;
	};
	_proto.labelDisplay_i = function () {
		var t = new eui.Label();
		this.labelDisplay = t;
		t.bottom = 8;
		t.fontFamily = "Tahoma";
		t.left = 8;
		t.right = 8;
		t.size = 20;
		t.textAlign = "center";
		t.textColor = 0xFFFFFF;
		t.top = 8;
		t.verticalAlign = "middle";
		return t;
	};
	return ItemRendererSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/mainModule/MainViewSkin.exml'] = window.MainViewSkin = (function (_super) {
	__extends(MainViewSkin, _super);
	var MainViewSkin$Skin1 = 	(function (_super) {
		__extends(MainViewSkin$Skin1, _super);
		function MainViewSkin$Skin1() {
			_super.call(this);
			this.skinParts = ["labelDisplay"];
			
			this.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
			this.states = [
				new eui.State ("up",
					[
					])
				,
				new eui.State ("down",
					[
						new eui.SetProperty("_Image1","source","MainView_json.btn_start_png")
					])
				,
				new eui.State ("disabled",
					[
						new eui.SetProperty("_Image1","source","MainView_json.btn_start_png")
					])
			];
		}
		var _proto = MainViewSkin$Skin1.prototype;

		_proto._Image1_i = function () {
			var t = new eui.Image();
			this._Image1 = t;
			t.percentHeight = 100;
			t.source = "MainView_json.btn_start_png";
			t.percentWidth = 100;
			return t;
		};
		_proto.labelDisplay_i = function () {
			var t = new eui.Label();
			this.labelDisplay = t;
			t.horizontalCenter = 0;
			t.verticalCenter = 0;
			return t;
		};
		return MainViewSkin$Skin1;
	})(eui.Skin);

	function MainViewSkin() {
		_super.call(this);
		this.skinParts = ["btn_start","btn_shop","btn_rank","btn_share","wxOtherGameIcon0","wxOtherGameIcon1","grp_content"];
		
		this.height = 1920;
		this.width = 1080;
		this.elementsContent = [this.grp_content_i()];
	}
	var _proto = MainViewSkin.prototype;

	_proto.grp_content_i = function () {
		var t = new eui.Group();
		this.grp_content = t;
		t.height = 1920;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		t.width = 1080;
		t.elementsContent = [this.btn_start_i(),this._Group1_i(),this.wxOtherGameIcon0_i(),this.wxOtherGameIcon1_i(),this._Image1_i()];
		return t;
	};
	_proto.btn_start_i = function () {
		var t = new eui.Button();
		this.btn_start = t;
		t.horizontalCenter = 0;
		t.label = "";
		t.verticalCenter = 157.5;
		t.skinName = MainViewSkin$Skin1;
		return t;
	};
	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.horizontalCenter = 0;
		t.verticalCenter = -274;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this.btn_shop_i(),this.btn_rank_i(),this.btn_share_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		t.gap = 138;
		return t;
	};
	_proto.btn_shop_i = function () {
		var t = new eui.Image();
		this.btn_shop = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "MainView_json.btn_freeSkin_png";
		t.x = -94;
		t.y = -182;
		return t;
	};
	_proto.btn_rank_i = function () {
		var t = new eui.Image();
		this.btn_rank = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "MainView_json.btn_rank_png";
		t.x = -84;
		t.y = -172;
		return t;
	};
	_proto.btn_share_i = function () {
		var t = new eui.Image();
		this.btn_share = t;
		t.scaleX = 1;
		t.scaleY = 1;
		t.source = "MainView_json.btn_share_png";
		t.x = -74;
		t.y = -162;
		return t;
	};
	_proto.wxOtherGameIcon0_i = function () {
		var t = new WxOtherGameIcon();
		this.wxOtherGameIcon0 = t;
		t.left = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.verticalCenter = 350;
		t.y = 1330;
		return t;
	};
	_proto.wxOtherGameIcon1_i = function () {
		var t = new WxOtherGameIcon();
		this.wxOtherGameIcon1 = t;
		t.right = 0;
		t.scaleX = 1;
		t.scaleY = 1;
		t.verticalCenter = 350;
		t.x = 1080;
		t.y = 1363;
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.horizontalCenter = 0;
		t.source = "img_logo_png";
		t.verticalCenter = -610.5;
		return t;
	};
	return MainViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/PanelSkin.exml'] = window.skins.PanelSkin = (function (_super) {
	__extends(PanelSkin, _super);
	function PanelSkin() {
		_super.call(this);
		this.skinParts = ["titleDisplay","moveArea","closeButton"];
		
		this.minHeight = 230;
		this.minWidth = 450;
		this.elementsContent = [this._Image1_i(),this.moveArea_i(),this.closeButton_i()];
	}
	var _proto = PanelSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.bottom = 0;
		t.left = 0;
		t.right = 0;
		t.scale9Grid = new egret.Rectangle(2,2,12,12);
		t.source = "border_png";
		t.top = 0;
		return t;
	};
	_proto.moveArea_i = function () {
		var t = new eui.Group();
		this.moveArea = t;
		t.height = 45;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		t.elementsContent = [this._Image2_i(),this.titleDisplay_i()];
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		t.bottom = 0;
		t.left = 0;
		t.right = 0;
		t.source = "header_png";
		t.top = 0;
		return t;
	};
	_proto.titleDisplay_i = function () {
		var t = new eui.Label();
		this.titleDisplay = t;
		t.fontFamily = "Tahoma";
		t.left = 15;
		t.right = 5;
		t.size = 20;
		t.textColor = 0xFFFFFF;
		t.verticalCenter = 0;
		t.wordWrap = false;
		return t;
	};
	_proto.closeButton_i = function () {
		var t = new eui.Button();
		this.closeButton = t;
		t.bottom = 5;
		t.horizontalCenter = 0;
		t.label = "close";
		return t;
	};
	return PanelSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/ProgressBarSkin.exml'] = window.skins.ProgressBarSkin = (function (_super) {
	__extends(ProgressBarSkin, _super);
	function ProgressBarSkin() {
		_super.call(this);
		this.skinParts = ["thumb","labelDisplay"];
		
		this.minHeight = 18;
		this.minWidth = 30;
		this.elementsContent = [this._Image1_i(),this.thumb_i(),this.labelDisplay_i()];
	}
	var _proto = ProgressBarSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.percentHeight = 100;
		t.scale9Grid = new egret.Rectangle(1,1,4,4);
		t.source = "track_pb_png";
		t.verticalCenter = 0;
		t.percentWidth = 100;
		return t;
	};
	_proto.thumb_i = function () {
		var t = new eui.Image();
		this.thumb = t;
		t.percentHeight = 100;
		t.source = "thumb_pb_png";
		t.percentWidth = 100;
		return t;
	};
	_proto.labelDisplay_i = function () {
		var t = new eui.Label();
		this.labelDisplay = t;
		t.fontFamily = "Tahoma";
		t.horizontalCenter = 0;
		t.size = 15;
		t.textAlign = "center";
		t.textColor = 0x707070;
		t.verticalAlign = "middle";
		t.verticalCenter = 0;
		return t;
	};
	return ProgressBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/RadioButtonSkin.exml'] = window.skins.RadioButtonSkin = (function (_super) {
	__extends(RadioButtonSkin, _super);
	function RadioButtonSkin() {
		_super.call(this);
		this.skinParts = ["labelDisplay"];
		
		this.elementsContent = [this._Group1_i()];
		this.states = [
			new eui.State ("up",
				[
				])
			,
			new eui.State ("down",
				[
					new eui.SetProperty("_Image1","alpha",0.7)
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("_Image1","alpha",0.5)
				])
			,
			new eui.State ("upAndSelected",
				[
					new eui.SetProperty("_Image1","source","radiobutton_select_up_png")
				])
			,
			new eui.State ("downAndSelected",
				[
					new eui.SetProperty("_Image1","source","radiobutton_select_down_png")
				])
			,
			new eui.State ("disabledAndSelected",
				[
					new eui.SetProperty("_Image1","source","radiobutton_select_disabled_png")
				])
		];
	}
	var _proto = RadioButtonSkin.prototype;

	_proto._Group1_i = function () {
		var t = new eui.Group();
		t.percentHeight = 100;
		t.percentWidth = 100;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this._Image1_i(),this.labelDisplay_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		t.verticalAlign = "middle";
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		this._Image1 = t;
		t.alpha = 1;
		t.fillMode = "scale";
		t.source = "radiobutton_unselect_png";
		return t;
	};
	_proto.labelDisplay_i = function () {
		var t = new eui.Label();
		this.labelDisplay = t;
		t.fontFamily = "Tahoma";
		t.size = 20;
		t.textAlign = "center";
		t.textColor = 0x707070;
		t.verticalAlign = "middle";
		return t;
	};
	return RadioButtonSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/ScrollerSkin.exml'] = window.skins.ScrollerSkin = (function (_super) {
	__extends(ScrollerSkin, _super);
	function ScrollerSkin() {
		_super.call(this);
		this.skinParts = ["horizontalScrollBar","verticalScrollBar"];
		
		this.minHeight = 20;
		this.minWidth = 20;
		this.elementsContent = [this.horizontalScrollBar_i(),this.verticalScrollBar_i()];
	}
	var _proto = ScrollerSkin.prototype;

	_proto.horizontalScrollBar_i = function () {
		var t = new eui.HScrollBar();
		this.horizontalScrollBar = t;
		t.bottom = 0;
		t.percentWidth = 100;
		return t;
	};
	_proto.verticalScrollBar_i = function () {
		var t = new eui.VScrollBar();
		this.verticalScrollBar = t;
		t.percentHeight = 100;
		t.right = 0;
		return t;
	};
	return ScrollerSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sdk/wx/ShareCanvasViewSkin.exml'] = window.ShareCanvasViewSkin = (function (_super) {
	__extends(ShareCanvasViewSkin, _super);
	function ShareCanvasViewSkin() {
		_super.call(this);
		this.skinParts = ["rect_bg","grp_canvasLayer","btn_back","grp_topLayer"];
		
		this.height = 1920;
		this.width = 1080;
		this.elementsContent = [this.rect_bg_i(),this.grp_canvasLayer_i(),this.grp_topLayer_i()];
	}
	var _proto = ShareCanvasViewSkin.prototype;

	_proto.rect_bg_i = function () {
		var t = new eui.Rect();
		this.rect_bg = t;
		t.bottom = 0;
		t.fillAlpha = 0.5;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		return t;
	};
	_proto.grp_canvasLayer_i = function () {
		var t = new eui.Group();
		this.grp_canvasLayer = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bottom = 0;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		t.touchThrough = true;
		return t;
	};
	_proto.grp_topLayer_i = function () {
		var t = new eui.Group();
		this.grp_topLayer = t;
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.bottom = 0;
		t.left = 0;
		t.right = 0;
		t.top = 0;
		t.elementsContent = [this.btn_back_i()];
		return t;
	};
	_proto.btn_back_i = function () {
		var t = new eui.Group();
		this.btn_back = t;
		t.horizontalCenter = 422;
		t.touchChildren = false;
		t.touchEnabled = true;
		t.verticalCenter = -260;
		t.layout = this._HorizontalLayout1_i();
		t.elementsContent = [this._Image1_i()];
		return t;
	};
	_proto._HorizontalLayout1_i = function () {
		var t = new eui.HorizontalLayout();
		return t;
	};
	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.anchorOffsetX = 0;
		t.anchorOffsetY = 0;
		t.height = 60;
		t.right = 0;
		t.source = "btn_close1_png";
		t.verticalCenter = 0;
		t.width = 60;
		return t;
	};
	return ShareCanvasViewSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/sdk/wx/WxOtherGameIconSkin.exml'] = window.WxOtherGameIconSkin = (function (_super) {
	__extends(WxOtherGameIconSkin, _super);
	function WxOtherGameIconSkin() {
		_super.call(this);
		this.skinParts = ["img_gameIcon"];
		
		this.elementsContent = [this.img_gameIcon_i()];
	}
	var _proto = WxOtherGameIconSkin.prototype;

	_proto.img_gameIcon_i = function () {
		var t = new eui.Image();
		this.img_gameIcon = t;
		t.horizontalCenter = 0;
		t.verticalCenter = 0;
		return t;
	};
	return WxOtherGameIconSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/TextInputSkin.exml'] = window.skins.TextInputSkin = (function (_super) {
	__extends(TextInputSkin, _super);
	function TextInputSkin() {
		_super.call(this);
		this.skinParts = ["textDisplay","promptDisplay"];
		
		this.minHeight = 40;
		this.minWidth = 300;
		this.elementsContent = [this._Image1_i(),this._Rect1_i(),this.textDisplay_i()];
		this.promptDisplay_i();
		
		this.states = [
			new eui.State ("normal",
				[
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("textDisplay","textColor",0xff0000)
				])
			,
			new eui.State ("normalWithPrompt",
				[
					new eui.AddItems("promptDisplay","",1,"")
				])
			,
			new eui.State ("disabledWithPrompt",
				[
					new eui.AddItems("promptDisplay","",1,"")
				])
		];
	}
	var _proto = TextInputSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		t.percentHeight = 100;
		t.scale9Grid = new egret.Rectangle(1,3,8,8);
		t.source = "button_up_png";
		t.percentWidth = 100;
		return t;
	};
	_proto._Rect1_i = function () {
		var t = new eui.Rect();
		t.fillColor = 0xffffff;
		t.percentHeight = 100;
		t.percentWidth = 100;
		return t;
	};
	_proto.textDisplay_i = function () {
		var t = new eui.EditableText();
		this.textDisplay = t;
		t.height = 24;
		t.left = "10";
		t.right = "10";
		t.size = 20;
		t.textColor = 0x000000;
		t.verticalCenter = "0";
		t.percentWidth = 100;
		return t;
	};
	_proto.promptDisplay_i = function () {
		var t = new eui.Label();
		this.promptDisplay = t;
		t.height = 24;
		t.left = 10;
		t.right = 10;
		t.size = 20;
		t.textColor = 0xa9a9a9;
		t.touchEnabled = false;
		t.verticalCenter = 0;
		t.percentWidth = 100;
		return t;
	};
	return TextInputSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/ToggleSwitchSkin.exml'] = window.skins.ToggleSwitchSkin = (function (_super) {
	__extends(ToggleSwitchSkin, _super);
	function ToggleSwitchSkin() {
		_super.call(this);
		this.skinParts = [];
		
		this.elementsContent = [this._Image1_i(),this._Image2_i()];
		this.states = [
			new eui.State ("up",
				[
					new eui.SetProperty("_Image1","source","off_png")
				])
			,
			new eui.State ("down",
				[
					new eui.SetProperty("_Image1","source","off_png")
				])
			,
			new eui.State ("disabled",
				[
					new eui.SetProperty("_Image1","source","off_png")
				])
			,
			new eui.State ("upAndSelected",
				[
					new eui.SetProperty("_Image2","horizontalCenter",18)
				])
			,
			new eui.State ("downAndSelected",
				[
					new eui.SetProperty("_Image2","horizontalCenter",18)
				])
			,
			new eui.State ("disabledAndSelected",
				[
					new eui.SetProperty("_Image2","horizontalCenter",18)
				])
		];
	}
	var _proto = ToggleSwitchSkin.prototype;

	_proto._Image1_i = function () {
		var t = new eui.Image();
		this._Image1 = t;
		t.source = "on_png";
		return t;
	};
	_proto._Image2_i = function () {
		var t = new eui.Image();
		this._Image2 = t;
		t.horizontalCenter = -18;
		t.source = "handle_png";
		t.verticalCenter = 0;
		return t;
	};
	return ToggleSwitchSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/VScrollBarSkin.exml'] = window.skins.VScrollBarSkin = (function (_super) {
	__extends(VScrollBarSkin, _super);
	function VScrollBarSkin() {
		_super.call(this);
		this.skinParts = ["thumb"];
		
		this.minHeight = 20;
		this.minWidth = 8;
		this.elementsContent = [this.thumb_i()];
	}
	var _proto = VScrollBarSkin.prototype;

	_proto.thumb_i = function () {
		var t = new eui.Image();
		this.thumb = t;
		t.height = 30;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(3,3,2,2);
		t.source = "roundthumb_png";
		t.width = 8;
		return t;
	};
	return VScrollBarSkin;
})(eui.Skin);generateEUI.paths['resource/eui_skins/VSliderSkin.exml'] = window.skins.VSliderSkin = (function (_super) {
	__extends(VSliderSkin, _super);
	function VSliderSkin() {
		_super.call(this);
		this.skinParts = ["track","thumb"];
		
		this.minHeight = 30;
		this.minWidth = 25;
		this.elementsContent = [this.track_i(),this.thumb_i()];
	}
	var _proto = VSliderSkin.prototype;

	_proto.track_i = function () {
		var t = new eui.Image();
		this.track = t;
		t.percentHeight = 100;
		t.horizontalCenter = 0;
		t.scale9Grid = new egret.Rectangle(1,1,4,4);
		t.source = "track_png";
		t.width = 7;
		return t;
	};
	_proto.thumb_i = function () {
		var t = new eui.Image();
		this.thumb = t;
		t.horizontalCenter = 0;
		t.source = "thumb_png";
		return t;
	};
	return VSliderSkin;
})(eui.Skin);