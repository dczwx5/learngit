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
var ListPanel = (function (_super) {
    __extends(ListPanel, _super);
    function ListPanel(width, height, pageSize) {
        if (width === void 0) { width = 370; }
        if (height === void 0) { height = 550; }
        if (pageSize === void 0) { pageSize = 5; }
        var _this = _super.call(this) || this;
        _this._isInited = false;
        _this.init(width, height, pageSize);
        _this.createItems();
        return _this;
    }
    ListPanel.prototype.init = function (width, height, pageSize) {
        if (width === void 0) { width = 370; }
        if (height === void 0) { height = 550; }
        if (pageSize === void 0) { pageSize = 5; }
        this._pageSize = pageSize;
        this._pageIdx = 0;
        this.itemList = [];
        this._dataList = [];
        this.vGap = 5;
        this.width = width;
        this.height = height;
        var bg = this.bg = new egret.Shape();
        bg.graphics.beginFill(0xE3F5EA);
        bg.graphics.drawRect(0, 0, this.width, this.height);
        bg.graphics.endFill();
        this.addChild(bg);
        this.initHeadArea();
        this.initListArea();
        this.initFootArea();
        this._isInited = true;
        this.setPosistion();
    };
    ListPanel.prototype.setPosistion = function () {
        this.x = Main.stage.stageWidth - this.width >> 1;
        this.y = Main.stage.stageHeight - this.height >> 1;
    };
    ListPanel.prototype.initHeadArea = function () {
        var headArea = this.headArea = new egret.DisplayObjectContainer();
        headArea.width = this.width;
        headArea.height = 50;
        {
            var headBg = this.headBg = new egret.Shape();
            headBg.graphics.beginFill(0x7CD3D6);
            headBg.graphics.drawRect(0, 0, headArea.width, headArea.height);
            headBg.graphics.endFill();
            headArea.addChild(headBg);
            var tf_title = this.tf_title = new egret.TextField();
            tf_title.size = 30;
            tf_title.textColor = 0xffffff;
            tf_title.text = this.titleText;
            tf_title.x = headArea.width - tf_title.textWidth >> 1;
            tf_title.y = headArea.height - tf_title.textHeight >> 1;
            headArea.addChild(tf_title);
        }
        this.addChild(headArea);
    };
    ListPanel.prototype.initListArea = function () {
        var listArea = this.listArea = new egret.DisplayObjectContainer();
        listArea.width = this.width;
        listArea.height = this.listHeight;
        listArea.y = this.headArea.y + this.headArea.height;
        this.addChild(listArea);
    };
    ListPanel.prototype.initFootArea = function () {
        var footArea = this.footArea = new egret.DisplayObjectContainer();
        footArea.width = this.width;
        footArea.height = 50;
        footArea.y = this.listArea.y + this.listArea.height;
        {
            var footBg = this.footBg = new egret.Shape();
            footBg.graphics.beginFill(0x7CD3D6);
            footBg.graphics.drawRect(0, 0, footArea.width, footArea.height);
            footBg.graphics.endFill();
            footArea.addChild(footBg);
            var tf_prePage = this.tf_prePage = new egret.TextField();
            tf_prePage.touchEnabled = true;
            tf_prePage.size = 30;
            tf_prePage.textColor = 0xffffff;
            tf_prePage.text = "上一页";
            tf_prePage.x = 60;
            tf_prePage.y = footArea.height - tf_prePage.textHeight >> 1;
            footArea.addChild(tf_prePage);
            tf_prePage.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onPrePage, this);
            var tf_nextPage = this.tf_nextPage = new egret.TextField();
            tf_nextPage.touchEnabled = true;
            tf_nextPage.size = 30;
            tf_nextPage.textColor = 0xffffff;
            tf_nextPage.text = "下一页";
            tf_nextPage.x = footArea.width - tf_nextPage.textWidth - 60;
            tf_nextPage.y = footArea.height - tf_nextPage.textHeight >> 1;
            footArea.addChild(tf_nextPage);
            tf_nextPage.addEventListener(egret.TouchEvent.TOUCH_TAP, this.onNextPage, this);
        }
        this.addChild(footArea);
    };
    ListPanel.prototype.createItems = function () {
        if (!this.isInited) {
            egret.warn(" ListPanel \u5C1A\u672A\u521D\u59CB\u5316 \uFF01");
            return;
        }
        this.removeAllItems();
        var item;
        var listArea = this.listArea;
        for (var i = 0, l = this.pageSize; i < l; i++) {
            item = this.createItem();
            listArea.addChild(item);
            item.x = listArea.width - item.width >> 1;
            item.y = i == 0 ? 0 : (item.height + this.vGap) * i;
            this.itemList.push(item);
        }
    };
    ListPanel.prototype.updateByData = function () {
        this.pageIdx = 0;
        this.updateCurrPage();
    };
    ListPanel.prototype.updateCurrPage = function () {
        var beginDataIdx = this.pageSize * this.pageIdx;
        var endDataIdx = beginDataIdx + this.pageSize - 1;
        var item;
        for (var i = beginDataIdx; i <= endDataIdx; i++) {
            item = this.itemList[i - beginDataIdx];
            item.index = i;
            item.data = this.dataList[i];
        }
    };
    ListPanel.prototype.removeAllItems = function () {
        var item;
        while (this.itemList.length > 0) {
            item = this.itemList.pop();
            item.onRemoved();
            if (item.parent) {
                item.parent.removeChild(item);
            }
        }
    };
    ListPanel.prototype.onPrePage = function (e) {
        if (this.pageIdx <= 0) {
            return;
        }
        this.pageIdx--;
    };
    ListPanel.prototype.onNextPage = function (e) {
        if (this.pageIdx >= this.pageCount - 1) {
            return;
        }
        this.pageIdx++;
    };
    Object.defineProperty(ListPanel.prototype, "dataList", {
        get: function () {
            return this._dataList;
        },
        set: function (value) {
            this._dataList = value;
            this.updateByData();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListPanel.prototype, "pageIdx", {
        get: function () {
            return this._pageIdx;
        },
        set: function (val) {
            this._pageIdx = Math.max(0, Math.min(this.pageCount - 1, val));
            this.updateCurrPage();
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListPanel.prototype, "pageSize", {
        // public set pageSize(val:number){
        //     if(this.pageSize == val){
        //         return;
        //     }
        //     this._pageSize = val;
        //
        //     this.createItems();
        //     this.pageIdx = this.pageIdx;
        // }
        get: function () {
            return this._pageSize;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListPanel.prototype, "pageCount", {
        get: function () {
            return Math.max(Math.ceil(this.dataList.length / this.pageSize), 1);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListPanel.prototype, "listHeight", {
        get: function () {
            return this.pageSize * (this.vGap + this.itemHeight);
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(ListPanel.prototype, "isInited", {
        get: function () {
            return this._isInited;
        },
        enumerable: true,
        configurable: true
    });
    return ListPanel;
}(egret.DisplayObjectContainer));
__reflect(ListPanel.prototype, "ListPanel");
//# sourceMappingURL=ListPanel.js.map