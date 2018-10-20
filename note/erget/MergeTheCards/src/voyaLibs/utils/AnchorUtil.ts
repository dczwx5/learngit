namespace Utils {
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
    export class AnchorUtil {
        private static _propertyChange: any;
        private static _anchorChange: any;

        public static init(): void {
            AnchorUtil._propertyChange = Object.create(null);
            AnchorUtil._anchorChange = Object.create(null);
            AnchorUtil.injectAnchor();
        }

        public static setAnchorX(target: egret.DisplayObject, value: number): void {
            target["anchorX"] = value;
        }

        public static setAnchorY(target: egret.DisplayObject, value: number): void {
            target["anchorY"] = value;
        }

        public static setAnchor(target: egret.DisplayObject, value: number): void {
            target["anchorX"] = target["anchorY"] = value;
        }

        public static getAnchor(target: egret.DisplayObject): number {
            if (target["anchorX"] != target["anchorY"]) {
                console.log("target's anchorX != anchorY");
            }
            return target["anchorX"] || 0;
        }

        public static getAnchorY(target: egret.DisplayObject): number {
            return target["anchorY"] || 0;
        }

        public static getAnchorX(target: egret.DisplayObject): number {
            return target["anchorX"] || 0;
        }

        private static injectAnchor(): void {
            Object.defineProperty(egret.DisplayObject.prototype, "width", {
                get: function () {
                    return this.$getWidth();
                },
                set: function (value) {
                    this.$setWidth(value);
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    egret.callLater(() => {
                        AnchorUtil.changeAnchor(this);
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
                    this.$setHeight(value);
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    egret.callLater(() => {
                        AnchorUtil.changeAnchor(this);
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
                    this._anchorX = value;
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    AnchorUtil._anchorChange[this.hashCode] = true;
                    egret.callLater(() => {
                        AnchorUtil.changeAnchor(this);
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
                    this._anchorY = value;
                    AnchorUtil._propertyChange[this.hashCode] = true;
                    AnchorUtil._anchorChange[this.hashCode] = true;
                    egret.callLater(() => {
                        AnchorUtil.changeAnchor(this);
                    }, this);
                },
                enumerable: true,
                configurable: true
            });
        }

        private static changeAnchor(tar: any): void {
            if (AnchorUtil._propertyChange[tar.hashCode] && AnchorUtil._anchorChange[tar.hashCode]) {
                tar.anchorOffsetX = tar._anchorX * tar.width;
                tar.anchorOffsetY = tar._anchorY * tar.height;
                delete AnchorUtil._propertyChange[tar.hashCode];
            }
        }
    }
}