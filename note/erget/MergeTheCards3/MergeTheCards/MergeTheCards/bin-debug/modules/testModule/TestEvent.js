var __reflect = (this && this.__reflect) || function (p, c, t) {
    p.__class__ = c, t ? t.push(c) : t = [c], p.__types__ = p.__types__ ? t.concat(p.__types__) : t;
};
var TestEvent = (function () {
    function TestEvent() {
        /**
         * @description Test dg of test event
         */
        this.testDg = new VL.Delegate();
        /**
         * @description Test dg1 of test event
         */
        this.testDg1 = new VL.Delegate();
        /**
         * @description Test dg2 of test event
         */
        this.testDg2 = new VL.Delegate();
        /**
         * @description Test dg3 of test event
         */
        this.testDg3 = new VL.Delegate();
    }
    return TestEvent;
}());
__reflect(TestEvent.prototype, "TestEvent", ["VoyaMVC.IEvent"]);
//# sourceMappingURL=TestEvent.js.map