/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleModifier {
public class CParticleModifierData {
    private var m_iTypeId:int;
    private var m_sTypeName:String;
    public function CParticleModifierData(iTypeId:int, sTypeName:String) {
        m_iTypeId = iTypeId;
        m_sTypeName = sTypeName;
    }

    public virtual function dispose():void
    {

    }

    /**
     *  Type id
     */
    public function get iTypeId():int { return m_iTypeId; }

    /**
     *  Type name
     */
    public function get sTypeName():String { return m_sTypeName; }

    /**
     * The value of the two modifier data is equal. this member function is used by factory.
     * @param target
     * @return
     */
    public function isEqual(theTarget:CParticleModifierData):Boolean
    {
        return _isEqual(theTarget);
    }
    /**
     * Load json data to init
     * @param theData
     */
    public function loadFromJson(theData:Object):void
    {
        _loadFromJson(theData);
    }

    /**
     * Save data to json data
     * @param theResultData
     * @return
     */
    public function saveToJson(theResultData:Object):Object
    {
        return _saveToJson(theResultData);
    }

    /**
     * The value of the two modifier data is equal. this member function is used by factory.
     * Subclass override this member function to add judgement condition
     * @param target
     * @return
     */
    protected virtual function _isEqual(theTarget:CParticleModifierData):Boolean
    {
        return m_iTypeId == theTarget.m_iTypeId;
    }

    /**
     * Override this member function to init data from json data
     * @param theData
     */
    protected virtual function _loadFromJson(theData:Object):void
    {
        m_sTypeName = theData["type_name"];
    }

    /**
     * Override this member function to save data to json data
     * @param theResultData
     * @return
     */
    protected virtual function _saveToJson(theResultData:Object):Object
    {
        if(theResultData == null)theResultData = new Object();
        theResultData["type_name"] = m_sTypeName;
        return theResultData;
    }
}
}
