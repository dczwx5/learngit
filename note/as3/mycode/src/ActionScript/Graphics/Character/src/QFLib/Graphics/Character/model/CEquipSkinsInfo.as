/**
 * Created by Administrator on 2017/3/16.
 */
package QFLib.Graphics.Character.model {
import QFLib.Foundation.CMap;
import QFLib.Foundation.CPath;
import QFLib.Interface.IDisposable;

public class CEquipSkinsInfo implements IDisposable
{
    public function CEquipSkinsInfo() {
    }

    public function dispose() : void
    {
        for each (var url : String in m_vEquipSkinURLs)
        {
            url = null;
        }
        m_vEquipSkinURLs = null;
    }

    public function get isEquipsNull() : Boolean
    {
        if (m_vEquipSkinURLs == null)
            return true;
        for each (var url : String in m_vEquipSkinURLs)
        {
            if (url != null)
                return false;
        }
        //all are null, return true
        return true;
    }

    public function get equipURLs() : Vector.<String>
    {
        if ( isEquipsNull == true)
            return null;

        var length : int;
        var urlVector : Vector.<String>  = new Vector.<String>();

        length = m_vEquipSkinURLs.length;
        for (var i : int = 0; i < length; ++i)
        {
            if (m_vEquipSkinURLs[i] != null)
                urlVector.push(m_vEquipSkinURLs[i]);
        }
        return urlVector;
    }


    public function get equipName() : String
    {
        if (isEquipsNull ==  true)
            return null;
        var length : int = m_vEquipSkinURLs.length;
        var name : String = "";
        for (var i : int = 0; i < length; ++i)
        {
            if (m_vEquipSkinURLs[i] != null)
            {
                name += "-" + CPath.name(m_vEquipSkinURLs[i]);
            }
        }
        return name;
    }

    public function addEquip(equipIndex : int, equipUrl : String) : void
    {
        if (equipUrl == null)
            return;
        if (m_vEquipSkinURLs == null)
            m_vEquipSkinURLs = new Vector.<String>();
        if (m_vEquipSkinURLs.length < equipIndex + 1)
        {
            var count : int = equipIndex + 1 - m_vEquipSkinURLs.length;
            for (var i : int = 0; i < count; ++i)
            {
                m_vEquipSkinURLs.push(null);
            }
        }
        m_vEquipSkinURLs[equipIndex] = equipUrl;
    }
    protected var m_vEquipSkinURLs : Vector.<String> = null;
}
}
