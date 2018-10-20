//------------------------------------------------------------------------------
// Copyright (C) 2016 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
//------------------------------------------------------------------------------

/**
 * Created by david on 2016/6/30.
 */
package QFLib.Framework.CharacterExtData
{

    import QFLib.Foundation;
    import QFLib.Foundation.CMap;
    import QFLib.Foundation.CPath;

    public class CCharacterFXData
    {
        private static const sFxUrl : String = "assets/fx/";
        private static var sCustomFXPath : String = null;

        public function CCharacterFXData ()
        {

        }

        public function dispose () : void
        {
            if ( _data != null )
            {
                _data.clear ();
                _data = null;
            }

            sCustomFXPath = null;
        }

        public static function set customFXPath ( path : String ) : void
        {
            sCustomFXPath = path;
            sCustomFXPath = CPath.addRightSlash ( sCustomFXPath );
        }

        public function getData () : CMap
        {
            return _data;
        }

        public function get dataLinked () : Boolean
        {
            return _bDataLinked;
        }

        public function set dataLinked ( bLinked : Boolean ) : void
        {
            _bDataLinked = bLinked;
        }

        public function getValue ( keyName : String ) : Vector.<CCharacterFXKey>
        {
            return _data[ keyName ];
        }

        /**
         *
         * @param keyName 动作名
         * @param skillName 技能名（"default"默认为普通动作，其他为技能动作）
         * @return
         */
        public function getValueByName ( keyName : String, skillName : String = "default" ) : Vector.<CCharacterFXKey>
        {
            var fxMaps : CMap = _data[ skillName ];
            if ( fxMaps == null )return null;
            var fxKeys : Vector.<CCharacterFXKey> = fxMaps[ keyName ];
            return fxKeys;
        }

        public function loadFromData ( data : Object ) : CMap
        {
            if ( _data == null )
            {
                //内存可优化，相同角色的数据是一样的
                _data = new CMap ();
            }

            var keyTime : Number = 0.0;
            var loopTimes : int = 1;
            var keyData : Object = null;

            for ( var key : * in data )
            {
                var fxMap : CMap = new CMap ();
                var mapKey : String = key.toString ();
                _data.add ( mapKey, fxMap );

                var nodes : Array = [];
                if ( mapKey == "default" )
                {
                    //普通动作
                    var defaultObj : Object = data[ mapKey ];
                    nodes.push ( defaultObj );
                }
                else
                {
                    //技能动作
                    nodes = data[ mapKey ];
                }

                if ( nodes == null || nodes.length == 0 ) continue;
                for ( var i : int = 0, n : int = nodes.length; i < n; i++ )
                {
                    var actionNode : Object = nodes[ i ];
                    for ( var actionKey : * in actionNode )
                    {
                        var fxKeys : Vector.<CCharacterFXKey> = new Vector.<CCharacterFXKey> ();
                        var keyId : String = actionKey.toString ();
                        fxMap.add ( actionKey, fxKeys );

                        var subNode : Object = actionNode[ keyId ];
                        if ( subNode == null ) continue;

                        if ( !subNode.hasOwnProperty ( "length" ) )
                        {
                            Foundation.Log.logWarningMsg ( "[CCharacterFXData] load animfx failed:  请检查技能特效json不是最新的格式" + this.fileName );
                            return null;
                        }

                        for ( var l : int = 0, m : int = subNode.length; l < m; l++ )
                        {
                            var keyNode : Object = subNode[ l ];
                            if ( keyNode == null ) continue;

                            if ( checkObejct ( keyNode, "keytime" ) )
                            {
                                keyTime = keyNode.keytime;
                            }

                            if ( checkObejct ( keyNode, "looptimes" ) )
                            {
                                loopTimes = keyNode.looptimes;
                            }

                            if ( checkObejct ( keyNode, "keydata" ) )
                            {
                                keyData = keyNode.keydata;
                                if ( keyData == null ) continue;

                                for ( var j : int = 0, k : int = keyData.length; j < k; j++ )
                                {
                                    var fxKey : CCharacterFXKey = new CCharacterFXKey ();
                                    fxKey.keyTime = keyTime;
                                    fxKey.loopTimes = loopTimes - 1;

                                    if ( checkObejct ( keyData[ j ], "effect" ) )
                                    {
                                        var url : String = null;
                                        if ( sCustomFXPath != null )
                                        {
                                            url = sCustomFXPath + keyData[ j ].effect + ".json";
                                        }
                                        else
                                        {
                                            url = sFxUrl + keyData[ j ].effect + ".json";
                                        }
                                        fxKey.fxURL = url.toLowerCase ();
                                    }

                                    if ( checkObejct ( keyData[ j ], "bone" ) )
                                    {
                                        fxKey.boneName = keyData[ j ].bone;
                                        //fxKey.boneIndex = _theBelongCharacter.findBoneIndex(boneName);
                                    }

                                    if ( checkObejct ( keyData[ j ], "playTime" ) &&
                                            keyData[ j ].playTime > 0.0 )
                                    {
                                        fxKey.playTime = keyData[ j ].playTime;
                                    }

                                    if ( checkObejct ( keyData[ j ], "fadeWithAnimation" ) )
                                    {
                                        fxKey.fadeWithAnimation = keyData[ j ].fadeWithAnimation;
                                    }

                                    //fx attach to bone oncetime
                                    fxKey.loadFromData ( keyData[ j ] );

                                    fxKeys.push ( fxKey );

                                    ++FxCount;
                                }
                            }
                        }

                    }
                }

            }

            return _data;
        }

        private static function checkObejct ( node : Object, name : String ) : Boolean
        {
            if ( node.hasOwnProperty ( name ) )
            {
                return true;
            }
            else
            {
                return false;
                //throw new CCharacterFXDataError(name);
            }
        }

        public function get fileName () : String
        {
            return _fileName;
        }

        public function set fileName ( value : String ) : void
        {
            _fileName = value;
        }

        public var FxCount : int = 0;

        private var _data : CMap = null;
        private var _fileName : String;
        private var _bDataLinked : Boolean = false;
    }
}