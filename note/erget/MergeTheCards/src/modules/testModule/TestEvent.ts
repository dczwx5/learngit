class TestEvent implements VoyaMVC.IEvent {
    
    /**
     * @description Test dg of test event
     */
    public readonly testDg = new VL.Delegate<{ testNum: number ; testStr: string;}>();
    
    /**
     * @description Test dg1 of test event
     */
    public readonly testDg1 = new VL.Delegate<{ testStr: string ; testNum: number; }>();
    
    /**
     * @description Test dg2 of test event
     */
    public readonly testDg2 = new VL.Delegate<{ testNum1: number;testStr1: string ;}>();
    
    /**
     * @description Test dg3 of test event
     */
    public readonly testDg3 = new VL.Delegate<{ testStr1: string ;}>();
}