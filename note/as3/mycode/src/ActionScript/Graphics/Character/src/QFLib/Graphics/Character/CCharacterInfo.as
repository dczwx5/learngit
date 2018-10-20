//----------------------------------------------------------------------
//(C) 2016 Shenzhen Qifun Network Co.Ltd.All Rights Reserved.
// Created by VINCENT on 2016/3/28.
//----------------------------------------------------------------------

package QFLib.Graphics.Character
{
    import QFLib.Graphics.Character.model.CEquipSkinsInfo;

    public class CCharacterInfo
    {
        public function CCharacterInfo(sSkeletonUrl : String, sAtlasUrl : String, vSkinUrls : Vector.<String> = null, theEquipSkinsInfo : CEquipSkinsInfo = null , sAnimationUrl : String = null, sCollisionUrl : String = null)
        {
            m_sSkeletonUrl = sSkeletonUrl;
            m_sAtlasUrl = sAtlasUrl;
            m_vSkinUrls = vSkinUrls;
            m_theEquipSkinsInfo = theEquipSkinsInfo;
            m_sAnimationUrl = sAnimationUrl;
            m_sCollisionUrl = sCollisionUrl;
        }

        public function dispose() : void
        {
            m_sSkeletonUrl = null;
            m_sAtlasUrl = null;
            m_vSkinUrls = null;
            if (m_theEquipSkinsInfo != null)
                m_theEquipSkinsInfo.dispose();
            m_sAnimationUrl = null;
        }

        public function get skeletonUrl() : String
        {
            return m_sSkeletonUrl;
        }

        public function get atlasUrl() : String
        {
            return m_sAtlasUrl;
        }

        public function get skinURLs() : Vector.<String>
        {
            return m_vSkinUrls;
        }

        public function set skinURLs(value : Vector.<String> ) : void
        {
            m_vSkinUrls = value;
        }

        public function get equipSkinUrls () : Vector.<String>
        {
            if (m_theEquipSkinsInfo.equipURLs)
                return m_theEquipSkinsInfo.equipURLs;
            return null;
        }

        public function get equipSkinName() : String
        {
            if (m_theEquipSkinsInfo != null)
                return m_theEquipSkinsInfo.equipName;
            return null;
        }

        public function get equipSkinsInfo() : CEquipSkinsInfo
        {
            return m_theEquipSkinsInfo;
        }
        public function set equipSkinsInfo(value : CEquipSkinsInfo) : void
        {
            m_theEquipSkinsInfo = value;
        }

        public function get animationUrl() : String
        {
            return m_sAnimationUrl;
        }

        public function get collisionUrl() : String
        {
            return m_sCollisionUrl;
        }

        public function set collisionUrl(value : String) : void
        {
            m_sCollisionUrl = value;
        }
        //
        //
        private var m_sSkeletonUrl : String;
        private var m_sAtlasUrl : String;
        private var m_vSkinUrls : Vector.<String>;
        private var m_theEquipSkinsInfo : CEquipSkinsInfo;
        private var m_sAnimationUrl : String;
        private var m_sCollisionUrl : String;

    }

}
