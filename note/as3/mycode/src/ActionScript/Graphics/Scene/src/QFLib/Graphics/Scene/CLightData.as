/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 * Created by Curry on 2017/1/5.
 */
package QFLib.Graphics.Scene
{

public class CLightData
    {
        public function CLightData( index : int,  aColorInfo : Array ) // A, R, G, B and Contrast
        {
            m_iIndex = index;
            m_aColorInfo = aColorInfo;
        }

        public function dispose() : void
        {

        }

        public var m_iIndex : int = 0;
        public var m_aColorInfo : Array = null;
    }

}
