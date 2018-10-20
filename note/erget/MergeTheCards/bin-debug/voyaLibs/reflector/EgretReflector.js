var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var VL;
(function (VL) {
    var Reflector;
    (function (Reflector) {
        var EgretReflector = (function () {
            function EgretReflector() {
            }
            EgretReflector.prototype.getClassName = function (classOrEntity) {
                return egret.getQualifiedClassName(classOrEntity);
            };
            EgretReflector.prototype.getClass = function (className) {
                return egret.getDefinitionByName(className);
            };
            EgretReflector.prototype.getClassByEntity = function (entity) {
                if (!entity) {
                    return null;
                }
                return entity['__proto__'].constructor;
            };
            EgretReflector.prototype.isExtends = function (extClass, baseClassName) {
                var extClassNmae = this.getClassName(extClass);
                return baseClassName != extClassNmae && extClass['prototype']['__types__'].indexOf(baseClassName) >= 0;
            };
            return EgretReflector;
        }());
        Reflector.EgretReflector = EgretReflector;
        __reflect(EgretReflector.prototype, "VL.Reflector.EgretReflector", ["VL.Reflector.IReflector"]);
    })(Reflector = VL.Reflector || (VL.Reflector = {}));
})(VL || (VL = {}));
//# sourceMappingURL=EgretReflector.js.map