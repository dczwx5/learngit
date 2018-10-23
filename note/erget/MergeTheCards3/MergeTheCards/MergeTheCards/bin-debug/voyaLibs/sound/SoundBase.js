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
var VL;
(function (VL) {
    var Sound;
    (function (Sound) {
        var SoundBase = (function (_super) {
            __extends(SoundBase, _super);
            function SoundBase() {
                return _super !== null && _super.apply(this, arguments) || this;
            }
            return SoundBase;
        }(VL.ObjectCache.CacheableClass));
        Sound.SoundBase = SoundBase;
        __reflect(SoundBase.prototype, "VL.Sound.SoundBase");
    })(Sound = VL.Sound || (VL.Sound = {}));
})(VL || (VL = {}));
//# sourceMappingURL=SoundBase.js.map