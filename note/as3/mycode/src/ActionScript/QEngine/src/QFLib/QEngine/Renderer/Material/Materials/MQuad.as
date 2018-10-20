/*
 * Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
 */

/**
 * Created by david on 2017/1/24.
 */
package QFLib.QEngine.Renderer.Material.Materials
{
    import QFLib.QEngine.Renderer.Material.IMaterial;

    public class MQuad extends MaterialBase implements IMaterial
    {
        public function MQuad( passCount : int = 1 )
        {
            super( passCount );
        }

        public function equal( other : IMaterial ) : Boolean
        {
            return false;
        }
    }
}
