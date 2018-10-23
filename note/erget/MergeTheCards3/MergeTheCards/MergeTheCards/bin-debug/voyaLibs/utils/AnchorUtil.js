var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var Utils;
(function (Utils) {
    /**
     * ###介绍 该工具类用于解决EgretEngine2.5版本没有anchorX/anchorY属性值的问题
     *
     *###使用说明 在创建游戏场景前需要执行AnchorUtil.init();初始化工具并完成属性的注入
     *
     *方式一（推荐）：
     *
     *AnchorUtil.setAnchorX(target, anchorX); //设置对象的anchorX值
     *AnchorUtil.setAnchorY(target, anchorY); //设置对象的anchorY值
     *AnchorUtil.setAnchor(target, anchor); //同时设置对象的anchorX和anchorY值
     *方式二：
     *
     *target["anchorX"] = value; //设置对象的anchorX值
     *target["anchorY"] = value; //设置对象的anchorY值
     *target["anchor"] = value; //同时设置对象的anchorX和anchorY值
     *方式三： 修改egret.d.ts，在DisplayObject声明中添加anchorX、anchorY和anchor属性，代码的写法和引擎之前版本相同：
     *
     *target.anchorX = value; //设置对象的anchorX值
     *target.anchorY = value; //设置对象的anchorY值
     *target.anchor = value; //同时设置对象的anchorX和anchorY值
     */
    var AnchorUtil = (function () {
        function AnchorUtil() {
        }
        AnchorUtil.init = function () {
            AnchorUtil._propertyChange = Object.create(null);
            AnchorUtil._anchorChange = Object.create(null);
            AnchorUtil.injectAnchor();
        };
        AnchorUtil.setAnchorX = function (target, value) {
            target["anchorX"] = value;
        };
        AnchorUtil.setAnchorY = function (target, value) {
            target["anchorY"] = value;
        };
        AnchorUtil.setAnchor = function (target, value) {
            target["anchorX"] = target["anchorY"] = value;
        };
        AnchorUtil.getAnchor = function (target) {
            if (target["anchorX"] != target["anchorY"]) {
                console.log("target's anchorX != anchorY");
            }
            return target["anchorX"] || 0;
        };
        AnchorUtil.getAnchorY = function (target) {
            return target["anchorY"] || 0;
        };
        AnchorUtil.getAnchorX = function (target) {
            return target["anchorX"] || 0;
        };
        AnchorUtil.injectAnchor = function () {
            Object.defineProperty(egret.DisplayObject.prototype, "width", {
                get: function () {
                    return this.$getWidth();
                },
                set: function (value) {
                    var _this = this;
                    this.$setWidth(value);
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    egret.callLater(function () {
                        AnchorUtil.changeAnchor(_this);
                    }, this);
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(egret.DisplayObject.prototype, "height", {
                get: function () {
                    return this.$getHeight();
                },
                set: function (value) {
                    var _this = this;
                    this.$setHeight(value);
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    egret.callLater(function () {
                        AnchorUtil.changeAnchor(_this);
                    }, this);
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(egret.DisplayObject.prototype, "anchorX", {
                get: function () {
                    return this._anchorX;
                },
                set: function (value) {
                    var _this = this;
                    this._anchorX = value;
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    AnchorUtil._anchorChange[this.hashCode] = true;
                    egret.callLater(function () {
                        AnchorUtil.changeAnchor(_this);
                    }, this);
                },
                enumerable: true,
                configurable: true
            });
            Object.defineProperty(egret.DisplayObject.prototype, "anchorY", {
                get: function () {
                    return this._anchorY;
                },
                set: function (value) {
                    var _this = this;
                    this._anchorY = value;
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    AnchorUtil._anchorChange[this.hashCode] = true;
                    egret.callLater(function () {
                        AnchorUtil.changeAnchor(_this);
                    }, this);
                },
                enumerable: true,
                configurable: true
            });
        };
        AnchorUtil.changeAnchor = function (tar) {
            if (AnchorUtil._propertyChange[tar.hashCode] && AnchorUtil._anchorChange[tar.hashCode]) {
                tar.anchorOffsetX = tar._anchorX * tar.width;
                tar.anchorOffsetY = tar._anchorY * tar.height;
                delete AnchorUtil._propertyChange[tar.hashCode];
            }
        };
        return AnchorUtil;
    }());
    Utils.AnchorUtil = AnchorUtil;
    __reflect(AnchorUtil.prototype, "Utils.AnchorUtil");
})(Utils || (Utils = {}));
//# sourceMappingURL=AnchorUtil.js.map