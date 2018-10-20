/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
public class CParticleValue {
    private var m_iTypeId:int;
    private var m_sTypeName:String;
    public function CParticleValue(iTypeId:int, sTypeName:String) {
        m_iTypeId = iTypeId;
        m_sTypeName = sTypeName;
    }

    public virtual function dispose():void
    {

    }

    /**
     * Caculate and get its runtime value.
     * @return
     */
    public function getValue():Object
    {
        return _calculateValue();
    }

    /**
     * Caculate and get its runtime value.
     * @param life intepolated coefficent, range is [0, 1]
     * @return
     */
    public function getValueInLife(life:Number):Object
    {
        return _calculateValue(life);
    }

    /**
     * Type id
     */
    public function get iTypeId():int { return m_iTypeId; }

    /**
     * Type name
     */
    public function get sTypeName():String { return m_sTypeName; }

    /**
     * The value of the two particle value is equal.
     * @param theTarget
     * @return
     */
    public function isEqual(theTarget:CParticleValue):Boolean
    {
        return _isEqual(theTarget);
    }

    /**
     * Load json data to init or reeset
     * @param theData json data
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
    public function saveToJson(theResultData:Object = null):Object
    {
        return _saveToJson(theResultData);
    }

    /**
     * Ovveride this member function to complete real caculation
     * @param life intepolated coefficent, range is [0, 1]
     * @return final result value
     */
    protected virtual function _calculateValue(life:Number = 0):Object
    {
        return null;
    }

    /**
     * The value of the two particle value is equal.
     * Subclass override this member function to add judgement condition.
     * @param theTarget
     * @return
     */
    protected virtual function _isEqual(theTarget:CParticleValue):Boolean
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
     * Override this memeber function to save data to josn data
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
