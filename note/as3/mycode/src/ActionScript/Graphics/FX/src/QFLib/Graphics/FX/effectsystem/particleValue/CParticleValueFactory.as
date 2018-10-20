/**
 * (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved
 * Created by Again on 2016/11/23.
 */
package QFLib.Graphics.FX.effectsystem.particleValue {
    import QFLib.Graphics.FX.utils.SlotPool;

    public class CParticleValueFactory {
    public static const TYPE_FIXED:int = 0;
    public static const TYPE_DYN_RANDOM:int = 1;
    public static const TYPE_FIXED_BOOL:int = 2;
    public static const TYPE_FIXED_COLOR:int = 3;
    public static const TYPE_DYN_RANDOM_COLOR:int = 4;
    public static const TYPE_LINEAR_COLOR:int = 5;
    public static const TYPE_CURVE:int = 6;

    private static const ArrValueType_TYPE_NAME:int = 0;
    private static const ArrValueType_VALUE_TYPE:int = 1;

    private static const m_arrValueTypes:Array = [["fixed", CFixedValue],
                                                     ["dyn_random", CDynRandomValue],
                                                     ["fixed_boolean", CBooleanFixedValue],
                                                     ["fixed_color", CColorFixedValue],
                                                     ["dyn_random_color", CColorDynRandomValue],
                                                     ["linear_color", CColorLinearValue],
                                                     ["curve", CCurveValue]
                                                   ];
    private static var m_thePools:SlotPool = new SlotPool(m_arrValueTypes.length, m_createParticleValue);
    /**
     * Allocate a new ParticleValue reference. if it is not useful later, you should call ParticleValueFactory::deallocate
     * to deallocate this reference.
     * @param theData ParticleValue config data object
     * @return new ParticleValue reference
     */
    public static function allocate(theData:Object):CParticleValue
    {
        var sTypeName:String = theData["type_name"];
        var theValue:CParticleValue;
        for(var i:int = 0, l:int = m_arrValueTypes.length; i < l; ++i)
        {
            if(m_arrValueTypes[i][ArrValueType_TYPE_NAME] == sTypeName)
            {
                var thePools:SlotPool = m_thePools;
                theValue = thePools.allocate(i) as CParticleValue;
                theValue.loadFromJson(theData);
                break ;
            }
        }
        return theValue;
    }

    /**
     * Deallocate the ParticleValue reference that will be is unvalid, so you should not use it again.
     * @param theValue ParticleValue reference
     */
    public static function deallocate(theValue:CParticleValue):void
    {
        var thePools:SlotPool = m_thePools;
        thePools.deallocate(theValue.iTypeId, theValue);
        theValue = null;
    }

    /**
     * Get total count of value type
     * @return
     */
    public static function getValueTypeCount():uint
    {
        return m_arrValueTypes.length;
    }

    /**
     * Get value type name at index, you can use this class static memmber "TYPE"
     * @param index
     * @return
     */
    public static function getValueTypeNameAt(index:uint):String
    {
        if(index < m_arrValueTypes.length)
                return m_arrValueTypes[index][ArrValueType_TYPE_NAME];
        return null;
    }


    private static function m_createParticleValue(slot:uint):CParticleValue
    {
        var sTypeName:String = m_arrValueTypes[slot][ArrValueType_TYPE_NAME];
        return new m_arrValueTypes[slot][ArrValueType_VALUE_TYPE](slot, sTypeName);
    }

    public function CParticleValueFactory() {
    }


}
}
