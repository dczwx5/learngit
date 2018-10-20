//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

package kof.framework {

[Suite]
[RunWith("org.flexunit.runners.Suite")]
public class CAppLifeCycleTestSuite {

    public var appStageTester : CAppStageTester;
    public var appSystemTester : CAppSystemTester;

    public function CAppLifeCycleTestSuite() {
    }

}
}
