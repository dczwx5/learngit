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
var RankListItem = (function (_super) {
    __extends(RankListItem, _super);
    function RankListItem() {
        var _this = _super.call(this) || this;
        _this._isInit = false;
        _this.init();
        return _this;
    }
    RankListItem.prototype.init = function () {
        this.width = RankListItem.WIDTH;
        this.height = RankListItem.HEIGHT;
        var bg = this.bg = new egret.Shape();
        bg.graphics.beginFill(0xF9C602);
        bg.graphics.drawRect(0, 0, this.width, this.height);
        bg.graphics.endFill();
        this.addChild(bg);
        var tf_rank = this.tf_rank = new egret.TextField();
        tf_rank.size = 30;
        tf_rank.textColor = 0x439B9E;
        tf_rank.x = 10;
        tf_rank.y = this.height - tf_rank.size >> 1;
        this.addChild(tf_rank);
        var img_head = this.img_head = new Img();
        img_head.height = img_head.width = 72;
        img_head.x = 70;
        img_head.y = this.height - img_head.height >> 1;
        this.addChild(img_head);
        var tf_name = this.tf_name = new egret.TextField();
        tf_name.size = 24;
        tf_name.textColor = 0x439B9E;
        tf_name.x = 170;
        tf_name.y = 18;
        this.addChild(tf_name);
        var tf_score = this.tf_score = new egret.TextField();
        tf_score.size = 24;
        tf_score.textColor = 0x439B9E;
        tf_score.x = 170;
        tf_score.y = 48;
        this.addChild(tf_score);
        this._isInit = true;
    };
    RankListItem.prototype.onDataChanged = function () {
        var data = this.data;
        if (data) {
            this.tf_name.text = data.nickName;
            this.tf_rank.text = (this.index + 1).toString();
            data.KVList.every(function (kv, idx, arr) {
                if (kv.key == "score") {
                    this.tf_score.text = kv.value;
                    return false;
                }
                return true;
            }, this);
            this.img_head.url = data.avatarUrl;
            this.visible = true;
        }
        else {
            this.visible = false;
        }
    };
    /**
     * 被从列表移除
     */
    RankListItem.prototype.onRemoved = function () {
        this.removeChildren();
        this.bg
            = this.tf_rank
                = this.tf_name
                    = this.tf_score
                        = this.img_head
                            = null;
        this._isInit = false;
    };
    Object.defineProperty(RankListItem.prototype, "index", {
        get: function () {
            return this._index;
        },
        set: function (value) {
            this._index = value;
        },
        enumerable: true,
        configurable: true
    });
    Object.defineProperty(RankListItem.prototype, "data", {
        get: function () {
            return this._data;
        },
        set: function (value) {
            this._data = value;
            this.onDataChanged();
        },
        enumerable: true,
        configurable: true
    });
    RankListItem.WIDTH = 370;
    RankListItem.HEIGHT = 90;
    return RankListItem;
}(ListItem));
__reflect(RankListItem.prototype, "RankListItem");
window["RankListItem"] = RankListItem;
//# sourceMappingURL=RankListItem.js.map