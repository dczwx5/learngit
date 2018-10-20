/**
 * 看视频关联的业务标识
 */
// class Enum_WxWatchVideoFlag{
//     /**
//      * 刷新手牌
//      * @type {string}
//      */
//     public static readonly REFRESH_HAND_CARD = 'REFRESH_HAND_CARD';
//     /**
//      * 复活
//      * @type {string}
//      */
//     public static readonly REBIRTH = 'REBIRTH';
// }
/**
 * 看视频关联的业务标识
 */
enum Enum_WxWatchVideoFlag{
    /**刷新手牌*/
    REFRESH_HAND_CARD = 1,
        /**复活*/
    REBIRTH = 2
}